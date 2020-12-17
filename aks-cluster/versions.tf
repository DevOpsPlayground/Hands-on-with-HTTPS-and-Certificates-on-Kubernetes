terraform {
  required_version = ">= 0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.1.1"
    }
  }
}
