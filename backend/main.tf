terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.3.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
}

resource "azurerm_resource_group" "rg_backend" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_storage_account" "sa_backend" {
  name                     = var.sa_name
  resource_group_name      = azurerm_resource_group.rg_backend.name
  location                 = azurerm_resource_group.rg_backend.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "sc_backend" {
  name                  = var.sc_name
  storage_account_name  = azurerm_storage_account.sa_backend.name
  container_access_type = "private"
}




