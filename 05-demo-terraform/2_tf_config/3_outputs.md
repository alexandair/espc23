## Output Values (outputs)

## Outputs.tf

Similar to `variables.tf`, let's now create a new file called `outputs.tf`

* `outputs.tf` will be used to define the output values from resources created/updated.

Create a `outputs.tf` file in PowerShell terminal

```powershell
cd Z:\terraform_espc
New-Item outputs.tf -Type file
code .\outputs.tf
```

Add `output` values definition such as below. Notice the use of `expressions` here to get the `id` of specified resource group.

```terraform
# outputs.tf
output "espc2023-rg-id" {
    value = azurerm_resource_group.espc2023-rg.id
    description = "don't show actual data on CLI output"
    sensitive = true
}

output "espc2023-dev-rg-id" {    
    value = azurerm_resource_group.espc2023-dev-rg.id
}
```

#### Plan and apply

```bash
terraform plan -var-file="espc.northeurope.tfvars"
terraform apply -auto-approve -var-file="espc.northeurope.tfvars"
```

#### Verify

* Observe the output on terminal.
* Notice that one of them simply shows `sensitive`. This doesn't mean it's fully secure, anyone with access to state file can still get to that data.

```bash
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

espc2023-dev-rg-id = /subscriptions/.../resourceGroups/espc2023-dev-rg
espc2023-rg-id = <sensitive>
```

#### Outputs via CLI

The following commands can be used to get outputs from state and values of sensitive outputs.

```bash
# Show all outputs
terraform output
```

```bash
# Show a specific output in JSON format
terraform output -json espc2023-rg-id
```

```bash
# Show a specific output in raw format
terraform output -raw espc2023-rg-id
```

#### Clean up the infrastructure with `terraform destroy`

----

#### Recap:

Topics Covered: 
* https://www.terraform.io/docs/configuration/outputs.html
* https://www.terraform.io/docs/configuration/expressions.html

The terraform_espc folder should now look like below.

```
terraform_espc
|___.terraform/ 
|___espc.westeurope.tfvars
|___espc.tfplan
|___espc.northeurope.tfvars
|___main.tf
|___outputs.tf
|___terraform.tfstate
|___terraform.tfstate.backup
|___terraform.tfvars
|___variables.tf
----