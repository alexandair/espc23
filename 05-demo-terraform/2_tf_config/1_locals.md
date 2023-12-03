## Locals

#### Setup

> Make sure you are in the correct folder

```bash
# if you are using Azure Cloud Shell

cd ~/clouddrive/terraform_espc

# Ensure the resource groups from previous lab has been destroyed and tf state is clean
# Below should be empty
terraform show
```
---

## Refactor main.tf to use locals

* Make below changes to `main.tf` so we are no longer hardcoding values.

> Please avoid `copying and pasting` unless specified. 

> Authoring terraform config files on your own is the best way to learn terraform and understand how it works.


```terraform
locals {   
    prefix = "espc2023"
    region = "northeurope"
    tags = {
        cost_center = "espc research"
    }
}

terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>3.0"
        }
    }
}

provider "azurerm" {
    features {}    
}

resource "azurerm_resource_group" "espc2023-rg" {
    name = "${local.prefix}-rg"
    location = local.region
    tags = local.tags
}

resource "azurerm_resource_group" "espc2023-dev-rg" {    
    name = "${local.prefix}-dev-rg"
    location = local.region
    tags = local.tags
}

```
Run a `plan` and `apply` as we've done before. 

Option 1: (via plan file)
```bash
terraform plan -out "espc.tfplan"
terraform apply -auto-approve "espc.tfplan" 
```

**or**

Option 2: (in memory)
```bash
terraform plan
terraform apply
```

> Note: From now on, we will simply refer to these operations as **`plan and apply`**.

#### Verify

* Verify that resources have been created correctly as we've done before. (via Azure portal or CLI)

* Run a **_`terraform show`_** on the the state to ensure it's correct and as expected.

----
