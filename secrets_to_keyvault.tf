locals {
  secrets_to_store_in_keyvault = {
    for aad_app in
    flatten(
      [
        for key, app in local.aad_apps : {
          keyvault_key  = app.keyvault.keyvault_key
          secret_prefix = lookup(app.keyvault, "secret_prefix", app.ad_application_name)
          aad_app_key   = key
        } if lookup(app, "keyvault", null) != null
      ]
    ) : aad_app.aad_app_key => aad_app
  }
}


output secrets_to_store_in_keyvault {
  value = local.secrets_to_store_in_keyvault
}

resource "azurerm_key_vault_secret" "aad_app_client_id" {
  depends_on = [azuread_service_principal_password.aad_apps]

  for_each = local.secrets_to_store_in_keyvault

  name            = format("%s-client-id", local.secrets_to_store_in_keyvault[each.key].secret_prefix)
  value           = azuread_application.aad_apps[each.key].application_id
  key_vault_id    = var.keyvaults[local.secrets_to_store_in_keyvault[each.key].keyvault_key].id
  expiration_date = timeadd(timestamp(), azuread_service_principal_password.aad_apps[each.key].end_date_relative)

  lifecycle {
    ignore_changes = [
      expiration_date
    ]
  }
}

resource "azurerm_key_vault_secret" "aad_app_client_secret" {
  depends_on = [azuread_service_principal_password.aad_apps]

  for_each = local.secrets_to_store_in_keyvault

  name            = format("%s-client-secret", local.secrets_to_store_in_keyvault[each.key].secret_prefix)
  value           = azuread_service_principal_password.aad_apps[each.key].value
  key_vault_id    = var.keyvaults[local.secrets_to_store_in_keyvault[each.key].keyvault_key].id
  expiration_date = timeadd(timestamp(), azuread_service_principal_password.aad_apps[each.key].end_date_relative)

  lifecycle {
    ignore_changes = [
      expiration_date, value
    ]
  }
}

resource "azurerm_key_vault_secret" "aad_app_tenant_id" {
  depends_on = [azuread_service_principal_password.aad_apps]

  for_each = local.secrets_to_store_in_keyvault

  name            = format("%s-tenant-id", local.secrets_to_store_in_keyvault[each.key].secret_prefix)
  value           = data.azurerm_client_config.current.tenant_id
  key_vault_id    = var.keyvaults[local.secrets_to_store_in_keyvault[each.key].keyvault_key].id
  expiration_date = timeadd(timestamp(), azuread_service_principal_password.aad_apps[each.key].end_date_relative)

  lifecycle {
    ignore_changes = [
      expiration_date
    ]
  }
}