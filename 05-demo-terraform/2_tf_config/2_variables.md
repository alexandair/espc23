## Variable Definition Files

#### Setup

> Make sure you are in the correct folder

```bash
cd ~/clouddrive/terraform_espc
```

## 2.1 Variables

#### Refactor `main.tf` to make it more configurable using variables

Introduce variables to `main.tf`, so it looks such as below.

* Notice how each variable has a slightly different setup. We've done this, so we can try different approaches to pass in data.

```terraform
variable prefix {}

variable region {           
    type = string
    default = "westeurope"
}

variable tags {
    type = map          
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
    name = "${var.prefix}-rg"
    location = var.region
    tags = var.tags
}

resource "azurerm_resource_group" "espc2023-dev-rg" {    
    name = "${var.prefix}-dev-rg"
    location = var.region
    tags = var.tags
}
```

#### terraform.tfvars

Go to PowerShell terminal in VS Code.
Create a file called `terraform.tfvars` in folder `Z:\terraform_espc`.

```powershell
cd Z:\terraform_espc
New-Item terraform.tfvars -Type file
code .\terraform.tfvars
```

Add tag information to `terraform.tfvars` so it looks like below.

```terraform
# terraform.tfvars
tags = {  
    cost_center = "espc research"    
} 
```
* Save both `main.tf` and `terraform.tfvars` files

#### Plan and Apply

Now, run a **`terraform plan`** in Azure Cloud Shell. When prompted for **var.prefix**, enter "espc2023"

* You should see something like below, stating that there will be a force replacement.
* This is because, now our default region is set to "westeurope" and we are not passing any overrides.
* We are prompted for `prefix` because we haven't set any `default` value

```bash
  # azurerm_resource_group.contoso_rg must be replaced
-/+ resource "azurerm_resource_group" "espc2023-rg" {
      ~ id       = "/subscriptions/.../resourceGroups/espc2023-rg" -> (known after apply)
      ~ location = "northeurope" -> "westeurope" # forces replacement
        name     = "espc2023-rg"
        tags     = {
            "cost_center" = "espc research"
        }
    }
Plan: 2 to add, 0 to change, 2 to destroy.
```

When ready, do a **`terraform apply`** and enter "espc2023" when prompted for prefix. (_and then enter `yes` when asked for approval_)

----

## 2.2 Environment Variables and custom .tfvars

We are currently passing in the `prefix` manually from CLI. Let's set an `environment variable`, so it gets picked from there.

From bash shell in Azure Cloud Shell terminal,
```bash
export TF_VAR_prefix="espc2023"
# ensure it's created correctly
env | grep TF_VAR_prefix
```

Go to PowerShell terminal in VS Code.
Now create two new files for .tfvars such as below, so we can make the region configurable. (this could  also be something like `.dev.tfvars`, `.prod.tfvars` in real world scenarios)

* espc.northeurope.tfvars
* espc.westeurope.tfvars

```powershell
cd Z:\terraform_espc
echo 'region = "northeurope"' > espc.northeurope.tfvars
echo 'region = "North Europe"' > espc.westeurope.tfvars
```

* Take a quick look at both `.tfvars` files and make sure they have the correct region value.

#### plan and apply

Run a plan and apply using `espc.northeurope.tfvars` file

```bash
terraform plan -var-file="espc.northeurope.tfvars"
terraform apply -auto-approve -var-file="espc.northeurope.tfvars"
```

Notice that we are no longer prompted for `prefix` value anymore. Terraform now picks this up from the environment variable we've created.

#### Verify and commit

Verify that the resource groups are re-created in `northeurope` 

---

## 2.3 Variables.tf

In this step, we will move all the variable definitions to a separate file, so our config file (main.tf) looks tidy.

Create a `variables.tf` file in PowerShell terminal

```powershell
cd Z:\terraform_espc
New-Item variables.tf -Type file
code .\variables.tf
```

Move all the variable definitions to this file, so it looks like below.

```terraform
# variables.tf
variable prefix {}

variable region {           
    type = string
    default = "northeurope"
}

variable tags {
    type= map          
}
```
* Save both `main.tf` and `variables.tf` files

#### Plan and Apply

Run a `terraform plan and apply`, but this time pass in the other `.tfvars` file (espc.westeurope.tfvars), so we can force a replacement.

```bash
terraform plan -var-file="espc.westeurope.tfvars"
terraform apply -auto-approve -var-file="espc.westeurope.tfvars"
```

#### Clean up the infrastructure with `terraform destroy`

* Run a `terraform destroy` and verify that both resource groups are now deleted.

* Do a `terraform show` to make sure the state file is empty.

----

## 2.4 Recap

Take a few minutes to observe and recap on different value sources that are used for our variables.

Your `terraform_espc` folder should look like below. Make sure you are fully comfortable with what those files are. (_you can ignore state.backup file for now_)

```
terraform_espc
|___.terraform/ 
|___espc.westeurope.tfvars
|___espc.tfplan
|___espc.northeurope.tfvars
|___main.tf
|___terraform.tfstate
|___terraform.tfstate.backup
|___terraform.tfvars
|___variables.tf
```

#### Topics covered

* https://www.terraform.io/docs/configuration/variables.html
* https://www.terraform.io/docs/configuration/locals.html

See more on Environment Variables: https://www.terraform.io/docs/commands/environment-variables.html

