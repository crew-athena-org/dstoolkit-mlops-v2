locals {
  suffixs = var.environment != "" ? [var.deployment_name, var.environment] : [var.deployment_name]
  tags = {
    deployedBy : "IAC"
    deploymentName : var.deployment_name
  }
}

data "azurerm_client_config" "current" {}

module "naming" {
  source        = "Azure/naming/azurerm"
  suffix        = local.suffixs
  unique-length = 3
}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name
  location = var.location

  tags = local.tags
}