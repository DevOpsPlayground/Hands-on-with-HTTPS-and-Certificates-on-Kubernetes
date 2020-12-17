data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "primary" {
}

data "terraform_remote_state" "aks-cluster" {
  backend = "local"

  config = {
    path = "../aks-cluster/terraform.tfstate"
  }
}

# data "azurerm_resource_group" "default" {
#   backend = "local"

#   config = {
#     path = "../aks-cluster/terraform.tfstate"
#   }
# }