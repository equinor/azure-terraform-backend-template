# Terraform Backend

[![SCM Compliance](https://scm-compliance-api.radix.equinor.com/repos/equinor/terraform-backend/badge)](https://scm-compliance-api.radix.equinor.com/repos/equinor/terraform-backend/badge)

Bicep template that creates an Azure Storage account to store Terraform state files.

[![Deploy to Azure](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fequinor%2Fterraform-backend%2Fmain%2Fazuredeploy.json)

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

1. Create a deployment at resource group from the template file:

   ```console
   az deployment group create --name terraform-backend --resource-group tfstate --template-file main.bicep
   ```

   Alternatively, create a deployment at resource group from the template URI:

   ```console
   az deployment group create --name terraform-backend --resource-group tfstate --template-uri https://raw.githubusercontent.com/equinor/terraform-backend/refs/heads/main/azuredeploy.json
   ```

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

## Build

```console
az bicep build --file main.bicep --outfile azuredeploy.json
```

## License

This project is licensed under the terms of the [MIT license](LICENSE).
