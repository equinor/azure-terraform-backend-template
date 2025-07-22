# Azure Terraform Backend Template

[![GitHub License](https://img.shields.io/github/license/equinor/azure-terraform-backend-template)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/equinor/azure-terraform-backend-template)](https://github.com/equinor/azure-terraform-backend-template/releases/latest)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![SCM Compliance](https://scm-compliance-api.radix.equinor.com/repos/equinor/azure-terraform-backend-template/badge)](https://developer.equinor.com/governance/scm-policy/)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fequinor%2Fazure-terraform-backend-template%2Fmain%2Fazuredeploy.json)

Azure Resource Manager (ARM) template that creates an Azure Storage account to store [Terraform](https://www.terraform.io) [state](https://developer.hashicorp.com/terraform/language/state) files:

- Creates a storage account with the specified name.
- Configures the storage account according to [security recommendations](https://learn.microsoft.com/en-us/azure/storage/blobs/security-recommendations).
- Creates a blob container with the specified name.
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

1. Create a deployment at subscription from the template URI:

   ```console
   az deployment group create --name terraform-backend --location northeurope --template-uri https://raw.githubusercontent.com/equinor/azure-terraform-backend-template/main/azuredeploy.json --parameters storageAccountName=<STORAGE_ACCOUNT_NAME>
   ```

   Requires Azure role `Owner` at resource group.

### Configure Terraform backend

1. Create a Terraform configuration file `main.tf` and add the following backend configuration:

   ```terraform
   terraform {
     backend "azurerm" {
       resource_group_name  = "<RESOURCE_GROUP_NAME>"
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

## Parameters

| Name | Description | Type | Default |
| - | - | - | - |
| `resourceGroupName` | The name of the resource group to create. | `string` | |
| `storageAccountName` | The name of the storage account to create. | `string` | |
| `containerName` | The name of the blob container to create. | `string` | `tfstate` |
| `allowSharedAccessKey` | Allow authenticating to the storage account using a shared access key? | `bool` | `false` |
| `ipRules` | An array of IP addresses or ranges that should be granted access to the storage account. If empty, all IP addresses and ranges will be granted access to the storage account. | `array` | `[]` |
| `principalIds` | An array of object IDs for user, group or service principals that should be allowed to authenticate to the storage account using Microsoft Entra. | `array` | `[]` |

> [!TIP]
> Rather than passing parameters as inline values, create a [parameter file](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/parameter-files).

## Outputs

When the deployment succeeds, the following output values are automatically returned in the results of the deployment:

| Name | Description | Type |
| - | - | - |
| `resourceGroupName` | The name of the resource group that was created. | `string` |
| `storageAccountName` | The name of the storage account that was created. | `string` |
| `containerName` | The name of the blob container that was created. | `string` |

## References

- [Store Terraform state in Azure Storage](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli)
- [Terraform backend configuration for Azure Storage](https://www.terraform.io/language/settings/backends/azurerm)

## Contributing

See [contributing guidelines](CONTRIBUTING.md).

## License

This project is licensed under the terms of the [MIT license](LICENSE).
