resource "azurecaf_naming_convention" "aad_apps" {
  for_each = local.aad_apps

  name          = each.value.ad_application_name
  resource_type = "rg" # workaround until support for aad apps
  convention    = each.value.convention
  prefix        = each.value.useprefix ? var.prefix : null
}

resource "azuread_application" "aad_apps" {
  for_each = {
    for key, app in local.aad_apps : key => app
  }

  name = azurecaf_naming_convention.aad_apps[each.key].result

  owners = [
    data.azurerm_client_config.current.object_id
  ]

  reply_urls = lookup(each.value, "reply_urls", null)

  dynamic "required_resource_access" {
    for_each = {
      for key, permission in lookup(var.aad_api_permissions, each.key, []) : key => permission
    }

    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = {
          for key, resource in required_resource_access.value.resource_access : key => resource
        }

        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      owners
    ]
  }
}

resource "azuread_service_principal" "aad_apps" {
  for_each = local.aad_apps

  application_id = azuread_application.aad_apps[each.key].application_id
}

resource "azuread_service_principal_password" "aad_apps" {
  for_each = local.aad_apps

  service_principal_id = azuread_service_principal.aad_apps[each.key].id
  value                = random_password.aad_apps[each.key].result
  end_date_relative    = "${each.value.password_expire_in_days * 24}h"
}

resource "random_password" "aad_apps" {
  for_each = local.aad_apps

  length  = 250
  special = false
  upper   = true
  number  = true
}
