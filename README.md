# Hands-on-with-Kubernetes-on-Azure-managing-certificates-with-Helm

## Introduction 
Ever wonder how certificates and HTTPS actually work ?
I know I have for a long time. For years I pretended that I understood as it seems to be either expected as prior knowledge when at work or simply glossed over in many tutorials when you take the initiative to do a bit of self learning.

And nowadays all applications need to run as containerised workloads on scaleable platforms such as (the buzz word of all buzz words) Kubernetes.

So simply knowing how certificates work is not enough, we need to know how to do something useful with this knowledge...like deploying HTTPS applications on the covetted Kubernetes.

Hopefully all hope is not lost...This hands on session aims to explain what certificate are, how they are used for secure commication and also how we can leverage Kubernetes to deploy HTTPS applications with relative ease. 

## Tutorial
This tutorial covers the steps required to deploy a HTTPS application on a pre-existing Kubernetes cluster build on on Azure Kubernetes Service (AKS)

### Initial setup
SSH into your workstation

    ssh <username>@<ip_address>

Clone down this repoistory

    git clone <this_repo>
    cd <repo_name>

Login to Azure using service principal 

    az login --service-principal -u <app_id> -p password --tenant <tenant_id>

### Deploy an HTTPS ingress controller using Helm
Helm is a package manager purpose built for Kubernetes. Helm has been pre-installed on your workstations.

Add the ingress-nginx repository (as this is not added to default Helm installation)
    
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

Use Helm to deploy an NGINX ingress controller
    
    helm install ingress-nginx ingress-nginx/ingress-nginx \
        --set controller.scope.enabled=true \
        --set controller.admissionWebhooks.enabled=false \
        --set rbac.scope=true

Once this is deployed, we can view the created service and assocaited EXTERNAL_IP (may take a minute to generate the IP)

    kubectl get services ingress-nginx-controller

Configure an FQDN for the ingress controller `EXTERNAL_IP`

    # Public IP address of your ingress controller
    IP=$(kubectl get services ingress-nginx-controller | awk 'NR==2 {print $4}')

    # Associate public IP address with DNS name, we will use the hostname of our workstation as an example
    DNSNAME=$(hostname)

    # Get the resource-id of the public ip (Note may need to wait a few minutes for this to work)
    PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$IP')].[id]" --output tsv)

    # Update public ip address with DNS name
    az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME

    # Display the FQDN
    az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv

    # Set FQDN as variable
    FQDN=$(az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv)

Prior to this interactive session, the kubernetes cert-manager has been pre-installed onto the Kubernetes cluster. See `aks-cluster` directory for details.
Cert-manager is a native Kubernetes certificate management controller. It can help with issuing certificates from a variety of sources, such as Let’s Encrypt, HashiCorp Vault or self signed certificates.

Create cluster issuer

    kubectl apply -f issuer.yaml

Run the two demo applications using `kubectl apply`

    kubectl apply -f aks-helloworld.yaml

Create an ingress route 

    sed -i "s/<REPLACE_ME>/$FQDN/g" hello-world-ingress.yaml
    kubectl apply -f hello-world-ingress.yaml 

Verify that the certificate was created successfully by checking READY is True, which may take several minutes.

    kubectl get certificate

