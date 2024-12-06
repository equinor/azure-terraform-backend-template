# 💪 Terraform Backend

[![SCM Compliance](https://scm-compliance-api.radix.equinor.com/repos/equinor/terraform-backend/badge)](https://developer.equinor.com/governance/scm-policy/)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)

[![Deploy to Azure](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fequinor%2Fterraform-backend%2Fmain%2Fazuredeploy.json)

Bicep template that creates an Azure Storage account to store Terraform state files:

- Creates a storage account with the specified name.
- Configures the storage account according to [security recommendations](https://learn.microsoft.com/en-us/azure/storage/blobs/security-recommendations).
- Creates a storage container `tfstate`.
- Grants access to the storage account for specified user, group and service principals.
- Creates a read-only lock to prevent changes to the storage account.

## Prerequisites

- Sign up for an [Azure account](https://azure.microsoft.com/en-us/pricing/purchase-options/azure-account).
- Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) version 2.20 or later.
- Install [Terraform](https://developer.hashicorp.com/terraform/install).

## Usage

### Create Azure Storage account

1. Login to Azure:

   ```console
   az login
   ```

1. Set active subscription:

   ```console
   az account set --name <SUBSCRIPTION_NAME>
   ```

1. Create resource group:

   ```console
   az group create --name tfstate
   ```

   Requires Azure role `Contributor` at subscription.

1. Create a deployment at resource group from the template file:

   ```console
   az deployment group create --name terraform-backend --resource-group tfstate --template-file main.bicep --parameters storageAccountName=<STORAGE_ACCOUNT_NAME>
   ```

   Alternatively, create a deployment at resource group from the template URI:

   ```console
   az deployment group create --name terraform-backend --resource-group tfstate --template-uri https://raw.githubusercontent.com/equinor/terraform-backend/refs/heads/main/azuredeploy.json --parameters storageAccountName=<STORAGE_ACCOUNT_NAME>
   ```

   Requires Azure role `Owner` at resource group.

### Configure Terraform backend

1. Create a Terraform configuration file `main.tf` and add the following backend configuration:

   ```terraform
   terraform {
     backend "azurerm" {
       resource_group_name  = "tfstate"
       storage_account_name = "<STORAGE_ACCOUNT_NAME>"
       container_name       = "tfstate"
       key                  = "terraform.tfstate"
       use_azuread_auth     = true
     }
   }
   ```

1. Initialize Terraform backend:

   ```console
   terraform init
   ```

## References

- [Store Terraform state in Azure Storage](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli)
- [Terraform backend configuration for Azure Storage](https://www.terraform.io/language/settings/backends/azurerm)

## Contributing

See [contributing guidelines](CONTRIBUTING.md).

## License

This project is licensed under the terms of the [MIT license](LICENSE).
