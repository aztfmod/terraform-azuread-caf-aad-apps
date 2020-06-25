# Register the community providers

terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }
}

provider azurerm {
  features {}
}


locals {
  # check structure, add missing fields
  aad_apps = {
    for key, aad_app in var.aad_apps : key => merge(var.aad_app, aad_app)
  }
}

data "azurerm_client_config" "current" {}