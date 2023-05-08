# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
  }
  required_version = ">= 0.14.9"
}
provider "azurerm" {
  features {}
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "alan-resource-group"
  location = "westeurope"
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "alan-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp-back" {
  name                  = "alan-webapp-back"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true
  site_config { 
    application_stack {
      node_version = "16-lts"
    }
  }
}

resource "azurerm_linux_web_app" "webapp-front" {
  name                  = "alan-webapp-front"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true
  site_config { 
    application_stack {
      node_version = "16-lts"
    }
  }
}

#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol-1" {
  app_id             = azurerm_linux_web_app.webapp-back.id
  repo_url           = "https://github.com/Alandla/web-back"
  branch             = "master"
  use_manual_integration = true
  use_mercurial      = false
}

#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol-2" {
  app_id             = azurerm_linux_web_app.webapp-front.id
  repo_url           = "https://github.com/Alandla/web-front"
  branch             = "master"
  use_manual_integration = true
  use_mercurial      = false
}

output "app_url_back" {
  value = "https://${azurerm_linux_web_app.webapp-back.default_hostname}"
}

output "app_url_front" {
  value = "https://${azurerm_linux_web_app.webapp-front.default_hostname}"
}