data "azurerm_client_config" "current" {
}

data "terraform_remote_state" "aks-cluster" {
  backend = "local"

  config = {
    path = "../aks-cluster/terraform.tfstate"
  }
}
