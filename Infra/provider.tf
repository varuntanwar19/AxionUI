terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  tenant_id       = "f8163445-6c70-454f-8963-bfc99239ca72"
  subscription_id = "160d534d-afc6-40f6-9ca6-1ba9dc7b8ca4"
}

