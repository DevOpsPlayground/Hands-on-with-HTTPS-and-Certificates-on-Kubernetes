# Introduction 
Ever wonder how certificates and HTTPS actually work ? I know I did for a long time...

For years I pretended that I understood, as it seemed to either be expected as prior knowledge or simply glossed over in many tutorials.

Nowadays, simply knowing how certificates work is not enough. We need to know how to do something useful with this knowledge. Such as deploying HTTPS applications onto the modern platform of choice, Kubernetes.

This hands on session aims to explain what certificates are, how they are used for secure communication and also how we can leverage Kubernetes to deploy HTTPS applications with relative ease. 

# Hands-on Certificates on Kubernetes
This tutorial covers the steps required to deploy both an internal and production ready HTTPS application on a pre-existing Kubernetes cluster built on on Azure Kubernetes Service (AKS).

### Initial setup
SSH into your workstation

    ssh <username>@<ip_address>

Or, alternatively, navigate to `<ip_address>/wetty` in your browser.

Clone down this repoistory

    git clone <this_repo>
    cd <repo_name>

### Deploy a HTTPS Ingress Controller using Helm
In order to deploy our HTTPS application we will utilise the **Ingress** resource, available by default in Kubernetes. 

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.

![alt text](assets/simple_ingress_k8s.png "Simple Ingress Example Kubernetes")

For the built in Ingress resource to work, the cluster must have an **Ingress Controller** running. 

We can declaratively define Ingress resources using Kubernetes manifests, however it is the Ingress Controller that determines how this will be fulfilled. The Ingress Controller watches for new Ingress rules and fulfills the mapping from services within the cluster to public URLs/domain names outside the cluster.

Unlike other types of controllers which run as part of the kube-controller-manager binary, Ingress Controllers are not started automatically with a cluster. The most popular controller is provided by NGINX, we can add this to our cluster using **Helm**.

Helm is a package manager purpose built for Kubernetes. Helm has been pre-installed on your workstations.

Add the ingress-nginx repository
    
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

Use Helm to deploy an NGINX Ingress Controller
    
    helm install ingress-nginx ingress-nginx/ingress-nginx \
        --set controller.scope.enabled=true \
        --set controller.admissionWebhooks.enabled=false \
        --set rbac.scope=true

Once this is deployed, we can view the created service and assocaited EXTERNAL_IP (Note: may take a minute to generate the IP)

    kubectl get services ingress-nginx-controller

Set the EXTERNAL_IP as a variable for later use

    EXTERNAL_IP=$(kubectl get services ingress-nginx-controller | awk 'NR==2 {print $4}')

The EXTERNAL_IP of this service acts as an entry point from the outside world.<!--  Using Ingress rules we can route requests to services within the cluster.     -->

## Self-Signed Certificates 

Generate TLS certificates using openssl self-signed (or alternatively use Vault as CA, see `vault-ca` dir).

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -out /tmp/tls.crt \
        -keyout /tmp/tls.key \
        -subj "/CN=dpg.com"

Create Kubernetes secret for the TLS certificate

    kubectl create secret tls internal-tls-secret \
        --key /tmp/tls.key \
        --cert /tmp/tls.crt

Run the demo application using `kubectl apply`

    kubectl apply -f self-signed/internal-app.yaml

Create the ingress resource (remember to modify the host to be the CN, Common Name, you have configured)

    kubectl apply -f self-signed/internal-ingress.yaml

Test the ingress configuration (self-signed)

    curl -v -k --resolve dpg.com:443:$EXTERNAL_IP https://dpg.com # Trusts any certificates

    curl -v --cacert /tmp/tls.crt --resolve dpg.com:443:$EXTERNAL_IP https://dpg.com # Trusts on certificate specified in command

Alternatively on your own machine (not your workstation) modify hosts file and view in browser. (Note: this will require sudo access)

`Windows c:\windows\system32\drivers\etc\hosts`
`Mac     /etc/hosts`
 

(Note: If the browser prevents you from proceeding type "thisisunsafe" into the browser window. This should bypass the browsers built in security checks.)


## Automated Certificates signed by LetsEncypt

Login to Azure using service principal 

    az login --service-principal -u $APP_ID -p $APP_PW --tenant $TENANT_ID

### Configure a FQDN for the Ingress Controller EXTERNAL_IP

During the installation of the Ingress Controller, an Azure Public IP address is created that corresponds with Ingress Controller service in Kubernetes. We can associate the Azure Public IP with a Fully Qualified Domain Name.

    # Public IP address of your Ingress Controller
    EXTERNAL_IP=$(kubectl get services ingress-nginx-controller | awk 'NR==2 {print $4}')

    # Associate Public IP address with DNS name, we will use the hostname of our workstation as an example
    DNSNAME=$(hostname)

    # Get the Azure resource-id of the Public IP address
    PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$EXTERNAL_IP')].[id]" --output tsv)

    # Update Public IP address with DNS name
    az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME

    # Display the FQDN
    az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv

    # Set FQDN as variable
    FQDN=$(az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv)

### Deploy demo application to Kubernetes cluster
Deploy the demo application using `kubectl apply`

    kubectl apply -f LetsEncrypt/prod-app.yaml

### Issue Certificates and configure Ingress
Prior to this interactive session, the kubernetes **cert-manager** controller has been pre-installed onto the Kubernetes cluster. See `aks-cluster` directory for details.

Cert-manager is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources, including external CAs.

Create Issuer

    kubectl apply -f LetsEncrypt/issuer.yaml

Create an Ingress route 

    sed -i "s/<REPLACE_ME>/$FQDN/g" LetsEncrypt/prod-ingress.yaml
    kubectl apply -f LetsEncrypt/prod-ingress.yaml 

Verify that the certificate was created successfully by checking READY is True, which may take a minute

    kubectl get certificate

### View HTTPS applicaiton in browser
Finally navigate to the the Fully Qualified Domain Name, copy the result of the echo command to your browser

    echo $FQDN 
