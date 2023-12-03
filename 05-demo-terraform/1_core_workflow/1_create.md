#### Understand the Terraform core workflow (write, plan, apply)

## Terraform Core Workflow

* Write
* Plan 
* Apply


#### Setup

> Make sure you are in the correct folder

```bash
# open Azure Cloud Shell as a terminal in VS Code
mkdir ~/clouddrive/terraform_espc
cd ~/clouddrive/terraform_espc
```

---

## Operation: Create

> NOTE: For the following commands you'll need to be authenticated to Azure and connected to the subscription you want to deploy to. HINT: When you are not in Azure Cloud Shell, use `az login` and `az account set --subscription mysubscription`

**1. Write**
 
Create the `main.tf` file in PowerShell terminal in VS Code, open it in the editor and paste in the below code.

```powershell
cd Z:\terraform_espc
New-Item main.tf -Type file
code .\main.tf
```

```terraform
# Specify the provider and version
terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>3.0"
        }
    }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}
}

# Create the very first resource
resource "azurerm_resource_group" "espc2023-rg" {
    name = "espc2023-rg"
    location = "northeurope"
}
```

* Save `main.tf` (`ctrl + s` should work)

---

**2. Init**

* Run in the Azure Cloud Shell terminal

```bash
# init
terraform init
```

Take a look at what's been created

1. `.terraform.lock.hcl` - Lock file to record the provider selections it made above. 
   ```bash
   # To display dotfiles
   ls -al
   ```

    To upgrade to newer version of the provider in the future, will require a **`terraform init --upgrade`**, which will then also update the lock file. This prevents accidental version bump following a change to `main.tf`. 
    
    Ensure `.terraform.lock.hcl` is version controlled.

2. `.terraform` directory - Contains provider itself that got installed based on the version specified in `main.tf`. 

    ```bash
    ls -R ./.terraform/providers/*/   

    # Above should display something like "terraform-provider-azurerm_v3.x.0_x5"
    ```
---
**3. Plan**

```bash
# Below command will generate an execution plan.
# Take a few minutes to go through the terminal output and see what changes will be applied

terraform plan
```  

You should see something like below
    
```bash
▶ terraform plan           

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.espc2023-rg will be created
  + resource "azurerm_resource_group" "espc2023-rg" {
      + id       = (known after apply)
      + location = "northeurope"
      + name     = "espc2023-rg"
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

---

**4. Apply**

```bash
# apply
terraform apply
```

> When prompted to enter a value, type **`yes`** to approve


The terminal output should say something like below

```bash
azurerm_resource_group.espc2023-rg: Creating...

azurerm_resource_group.espc2023-rg: Creation complete after 1s [id=/subscriptions/.../resourceGroups/espc2023-rg]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

> Note that `terraform.tfstate` file has been created locally upon our first apply. State management is a topic on its own and we'll cover it separately.
```bash
ls -al
``` 

---

**5. Verify**

Verify that the resource has been created, either via `Azure Portal` or using `az cli` and `jq` in `Cloud Shell`

```bash
# In Cloud Shell
az group list | jq '.[].name | select(contains("espc"))'

# or
az group list | jq '.[] | select(.name == "espc2023-rg")'
```

```bash
# Below should display the current state of your terraform managed infrastructure    
terraform show 

# or specify the state file name explicitly
terraform show terraform.tfstate
```
> The terraform `show` command is used to provide human-readable output from a state or plan file. See: https://www.terraform.io/docs/commands/show.html

---






