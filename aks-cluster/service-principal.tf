
resource "azuread_application" "app" {
  name                       = "vault"
  homepage                   = "https://homepage"
  identifier_uris            = ["https://uri"]
  reply_urls                 = ["https://replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
  type                       = "webapp/api"
  owners                     = [data.azurerm_client_config.current.object_id]

  app_role {
    allowed_member_types = [
      "User",
      "Application",
    ]

    description  = "Admins can manage roles and perform all task actions"
    display_name = "Admin"
    is_enabled   = true
    value        = "Admin"
  }

  oauth2_permissions {
    admin_consent_description  = "Allow the application to access example on behalf of the signed-in user."
    admin_consent_display_name = "Access example"
    is_enabled                 = true
    type                       = "User"
    user_consent_description   = "Allow the application to access example on your behalf."
    user_consent_display_name  = "Access example"
    value                      = "user_impersonation"
  }

  oauth2_permissions {
    admin_consent_description  = "Administer the example application"
    admin_consent_display_name = "Administer"
    is_enabled                 = true
    type                       = "Admin"
    value                      = "administer"
  }
}

resource "azuread_service_principal" "sp" {
  application_id               = azuread_application.app.application_id
  app_role_assignment_required = false
}


resource "azuread_application_password" "pw" {
  application_object_id = azuread_application.app.id
  description           = "My managed password"
  value                 = var.app_password
  end_date              = "2099-01-01T01:02:03Z"
}