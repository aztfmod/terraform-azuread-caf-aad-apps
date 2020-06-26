# output aad_apps {
#   sensitive = true
#   value = azuread_application.aad_apps
# }

output aad_apps {
  value = local.aad_apps_output
}