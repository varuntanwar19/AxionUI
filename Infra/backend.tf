# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg_prod_1"
#     storage_account_name = "storagergprod1"
#     container_name       = "storageprodcontainer1"
#     key                  = "terraform.tfstate"
#   }
# }