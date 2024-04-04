locals {
  env         = var.environment
  name        = var.client_name
  name_prefix = "${local.env}${local.name}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name_prefix}rg"
  location = var.location
  tags     = var.extra_tags
}

module "storage_account" {
  source = "git::https://github.com/tothenew/terraform-azure-storageaccount.git"

  account_name               = "cloudscrapertesting2"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  log_analytics_workspace_id = module.log_analytics.workspace_id

  account_kind = "BlobStorage"
}

module "log_analytics" {
  source = "git::https://github.com/tothenew/terraform-azure-loganalytics.git"

  workspace_name      = "${local.name_prefix}-log"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.extra_tags
}

resource "random_password" "admin_password" {
  special          = true
  override_special = "#$%&-_+{}<>:"
  upper            = true
  lower            = true
  numeric           = true
  length           = 32
}

# Single Database

module "sql_single" {
  source  = "../../"

  client_name         = var.client_name
  environment         = var.environment
  location            = var.location
  location_short      = var.location
  stack               = var.stack
  resource_group_name = azurerm_resource_group.rg.name
  administrator_login    = "adminsqltest"
  administrator_password = random_password.admin_password.result
  create_databases_users = true

  elastic_pool_enabled = false
  public_network_access_enabled = true
  allowed_cidr_list = ["182.71.160.186/32", "61.12.91.218/32"]

  logs_destinations_ids = [
    module.log_analytics.workspace_id,
    module.storage_account.account_id,
  ]

  databases = [
    {
      name        = "db1"
      max_size_gb = 50
    }
  ]

  custom_users = [
    {
      database = "db1"
      name     = "db1_custom1"
      roles    = ["db_accessadmin", "db_securityadmin"]
    }
  ]

  extra_tags = var.extra_tags
}
