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


data "azurerm_client_config" "current" {}