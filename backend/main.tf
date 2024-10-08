# Terraform Configuration
data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tf-backend-davidsdo"                                     # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
    storage_account_name = "rgdavidsdo" # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "sc-tf-backend-davidsdo"                                     # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "sa-tf-backend-davidsdo-access-key"                          # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.subscription_id
}

# Random String
resource "random_string" "random_string" {
  length  = 8
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "rg_backend" {
  name     = var.rg_name
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "sa_backend" {
  name                     = "${lower(var.sa_name)}${random_string.random_string.result}"
  resource_group_name      = azurerm_resource_group.rg_backend.name
  location                 = azurerm_resource_group.rg_backend.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

# Storage Container
resource "azurerm_storage_container" "sc_backend" {
  name                  = var.sc_name
  storage_account_name  = azurerm_storage_account.sa_backend.name
  container_access_type = "private"
}

# Key Vault
resource "azurerm_key_vault" "kv_backend" {
  name                        = "${lower(var.kv_name)}${random_string.random_string.result}"
  location                    = azurerm_resource_group.rg_backend.location
  resource_group_name         = azurerm_resource_group.rg_backend.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create",
    ]

    secret_permissions = [
      "Get", "Set", "List",
    ]

    storage_permissions = [
      "Get", "Set", "List",
    ]
  }
}

# Key Vault Secret
resource "azurerm_key_vault_secret" "sa_backend_access_key" {
  name         = var.sa_backend_access_key_name
  value        = azurerm_storage_account.sa_backend.primary_access_key
  key_vault_id = azurerm_key_vault.kv_backend.id
}


