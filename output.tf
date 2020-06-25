# output aad_apps {
#   sensitive = true
#   value = azuread_application.aad_apps
# }

# output service_principals {
#   sensitive = true
#   value = azuread_service_principal.aad_apps
# }

output aad_apps {
  sensitive = true
  value = {
    for aad_app_keyvault in
    flatten(
      [
        for key, aad_app in local.secrets_to_store_in_keyvault : {
          aad_app_key = key
          tenant_id   = data.azurerm_client_config.current.tenant_id
          azuread_application = {
            id             = azuread_application.aad_apps[key].id
            object_id      = azuread_application.aad_apps[key].object_id
            application_id = azuread_application.aad_apps[key].application_id
            name           = azuread_application.aad_apps[key].name
          }
          azuread_service_principal = {
            id                     = azuread_service_principal.aad_apps[key].id
            object_id              = azuread_service_principal.aad_apps[key].object_id
            keyvault_id            = azurerm_key_vault_secret.aad_app_client_secret[key].key_vault_id
            keyvault_name          = var.keyvaults[aad_app.keyvault_key].name
            keyvault_client_secret = azurerm_key_vault_secret.aad_app_client_secret[key].name
          }
        } if(lookup(azuread_application.aad_apps, key, null) != null) && (lookup(azuread_service_principal.aad_apps, key, null) != null)
      ]
    ) : aad_app_keyvault.aad_app_key => aad_app_keyvault
  }
}

output local_aad_apps {
  value = local.aad_apps
}