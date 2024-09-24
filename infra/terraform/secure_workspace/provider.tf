terraform {
  backend "azurerm" {      
      use_oidc = true  # Can also be set via `ARM_USE_OIDC` environment variable.}

  } 
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.99.0"
    }

    azureml = {
      source = "registry.terraform.io/orobix/azureml"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  skip_provider_registration = "true"
  features {
  }
}