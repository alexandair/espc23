#### Understand the terraform core workflow. (write, plan, apply)

## Operation: Destroy

Run a plan to see what will be destroyed.

```bash
# make sure you are running this from the terraform_espc folder in Azure Cloud Shell
terraform plan -destroy
```

If the plan looks as expected, go ahead and remove the resource group that we created using `destroy` operation.

`Destroy` depends on your state file to decide what needs to be removed. Unlike apply it cannot be invoked with a `.tfplan` file.

```bash
terraform destroy

# this is the equivalent of command
terraform apply -destroy
```

You should see a terminal output stating what will be destroyed.

When prompted, type `yes` to approve. This operation may take some time, and terraform will provide status updates every 10 seconds or so.

Verify that the `espc2023-rg` resource group has been deleted from your Azure subscription.

```bash
# You can use the portal or run the below Azure CLI command
az group show --name "espc2023-rg"
```

The state file should now be empty as we have completely cleaned up our Terraform managed infrastructure.

```bash
terraform show terraform.tfstate
```

---

## Recap

#### List of commands covered so far

* init
* plan
    * plan -out "planfile"
* apply
    * apply -auto-approve "planfile"
* show
* destroy 
---