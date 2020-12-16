# Provision AKS Cluster

## Login to Azure

  az login


## Create AKS cluster using Terraform

    terraform init
    terraform apply -auto-approve

When promted enter a password of your choice.

## Configure kubectl

To configure kubetcl run the following command:

```shell
$ az aks get-credentials --resource-group $(terraform output resource_group_name) --name $(terraform output kubernetes_cluster_name)
```

## Deploy Cert-Manager via Helm


