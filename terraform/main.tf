terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  # Nonaktifkan registrasi otomatis Resource Provider
  skip_provider_registration = true

  # Kredensial dibaca dari environment variable atau Azure CLI login
  # Jalankan: az login
}
