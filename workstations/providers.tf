provider "azurerm" {
  version = "=2.40.0"
  features {}
}

provider "azuread" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider to be used
  version = "=1.1.0"
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

