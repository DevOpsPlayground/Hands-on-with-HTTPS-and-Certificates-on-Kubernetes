# Provision atendee workstations and 

## Prerequisites
Must have built aks-cluster and resource group from other directory.

## Login to Azure

  az login

## Create workstations using Terraform

  terraform init
  terraform apply -target random_pet.pet -auto-approve # use -target flag to first apply only the
resources that the for_each depends on.
  terraform apply -auto-approve

Note: May need to perform `terraform refresh` if `azure_vm_public_ips` are not generated on initial apply.




