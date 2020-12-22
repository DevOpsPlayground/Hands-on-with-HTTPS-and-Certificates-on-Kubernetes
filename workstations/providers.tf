provider "azurerm" {
  features {}
}

provider "azuread" {
}

provider "kubernetes" {
  load_config_file = false

  host     = data.terraform_remote_state.aks-cluster.outputs.host
  username = data.terraform_remote_state.aks-cluster.outputs.cluster_username
  password = data.terraform_remote_state.aks-cluster.outputs.cluster_password

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.aks-cluster.outputs.cluster_ca_certificate,
  )
  client_certificate = base64decode(
    data.terraform_remote_state.aks-cluster.outputs.client_certificate,
  )
  client_key = base64decode(
    data.terraform_remote_state.aks-cluster.outputs.client_key,
  )
}

