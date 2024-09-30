variable "sa_name" {
  description = "The name of the storage account"
  type        = string
  
}

variable "rg_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resource group"
  type        = string
  default = "westeurope"
}

variable "sc_name" {
  description = "The name of the storage container"
  type        = string
}

variable "kv_name" {
  description = "The name of the key vault"
  type        = string
}