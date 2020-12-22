##############################################################################
# Create service principal with access to only the public-ip resouce in Azure
##############################################################################
resource "azuread_application" "app" {
  name                       = "dpg"
  homepage                   = "https://dpg"
  identifier_uris            = ["https://dpg"]
  reply_urls                 = ["https://replydpg"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
  type                       = "webapp/api"
  owners                     = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "sp" {
  application_id               = azuread_application.app.application_id
  app_role_assignment_required = false
}

resource "azuread_application_password" "pw" {
  application_object_id = azuread_application.app.object_id
  description           = "My managed password"
  value                 = var.app_password
  end_date              = "2099-01-01T01:02:03Z"
}

resource "azurerm_role_definition" "public-ips" {
  name        = "public-ips"
  scope       = data.azurerm_subscription.primary.id
  description = "This role gives full access to public-ips resource within Azure"

  permissions {
    actions = ["Microsoft.Network/publicIPAddresses/read", "Microsoft.Network/publicIPAddresses/write", "Microsoft.Network/publicIPAddresses/delete"]
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

resource "azurerm_role_assignment" "public-ips" {
  scope                            = data.azurerm_subscription.primary.id
  role_definition_name             = azurerm_role_definition.public-ips.name
  principal_id                     = azuread_service_principal.sp.id
  skip_service_principal_aad_check = true
}