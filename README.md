# Hands-on-with-Kubernetes-on-Azure-managing-certificates-with-Helm

## Introduction 
Ever wonder how certificates and HTTPS actually work ?
I know I have for a long time. For years I pretended that I understood, as it seemed to either be expected as prior knowledge when at work or simply glossed over in many tutorials when you take the initiative to do some self learning.

And nowadays, simply knowing how certificates work is not enough. We need to know how to do something useful with this knowledge. Such as deploying HTTPS applications on modern platform of choice, Kubernetes.

Hopefully all hope is not lost...This hands on session aims to explain what certificate are, how they are used for secure commication and also how we can leverage Kubernetes to deploy HTTPS applications with relative ease. 

## Tutorial
This tutorial covers the steps required to deploy a HTTPS application on a pre-existing Kubernetes cluster built on on Azure Kubernetes Service (AKS).

In order to deploy our HTTPS application, we will leverage the Ingress resource, available by default, in Kubernetes 

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.

![alt text](assets/simple_ingress_k8s.png "Simple Ingress Example Kubernetes")

### Initial setup
SSH into your workstation

    ssh <username>@<ip_address>

Clone down this repoistory

    git clone <this_repo>
    cd <repo_name>

Login to Azure using service principal 

    az login --service-principal -u $APP_ID -p $APP_PW --tenant $TENANT_ID

### Deploy an HTTPS ingress controller using Helm
In order for the Ingress resource to work, the cluster must have an ingress controller running. 

We can declaratively define Ingress resources using manifests, however it is the ingress controller that determines how this will be fulfilled. The Ingress controller watches for new Ingress rules and fulfills the mapping from services within the cluster to particular URLs/domain names for public consumption. 

Unlike other types of controllers which run as part of the kube-controller-manager binary, Ingress controllers are not started automatically with a cluster. The most popular controller is provided by NGINX, we can add this to our cluster using Helm.

Helm is a package manager purpose built for Kubernetes. Helm has been pre-installed on your workstations.

Add the ingress-nginx repository
    
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

Use Helm to deploy an NGINX ingress controller
    
    helm install ingress-nginx ingress-nginx/ingress-nginx \
        --set controller.scope.enabled=true \
        --set controller.admissionWebhooks.enabled=false \
        --set rbac.scope=true

Once this is deployed, we can view the created service and assocaited EXTERNAL_IP (may take a minute to generate the IP)

    kubectl get services ingress-nginx-controller

### Configure a FQDN for the ingress controller EXTERNAL_IP

During the installation, an Azure public IP address is created for the ingress controller which we can associate with a Fully Qualified Domain Name.

    # Public IP address of your ingress controller
    IP=$(kubectl get services ingress-nginx-controller | awk 'NR==2 {print $4}')

    # Associate Public IP address with DNS name, we will use the hostname of our workstation as an example
    DNSNAME=$(hostname)

    # Get the resource-id of the public ip (Note may need to wait a few minutes for this to work)
    PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$IP')].[id]" --output tsv)

    # Update public ip address with DNS name
    az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME

    # Display the FQDN
    az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv

    # Set FQDN as variable
    FQDN=$(az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv)

### Deploy demo application to Kubernetes cluster
Deploy the demo application using `kubectl apply`

    kubectl apply -f aks-helloworld.yaml

### Issue Certificates and configure Ingress
Prior to this interactive session, the kubernetes cert-manager controller has been pre-installed onto the Kubernetes cluster. See `aks-cluster` directory for details.

Cert-manager is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources (i.e External CAs such as Let's Encrypt, Self Signed certificates or HashiCorp Vault).

Create Issuer

    kubectl apply -f issuer.yaml

Create an Ingress route 

    sed -i "s/<REPLACE_ME>/$FQDN/g" hello-world-ingress.yaml
    kubectl apply -f hello-world-ingress.yaml 

Verify that the certificate was created successfully by checking READY is True, which may take a minute

    kubectl get certificate

### View HTTPS applicaiton in browser
Finally navigate to the the Fully Qualified Domain Name, copy the result of the echo command to your browser

    echo $FQDN 
