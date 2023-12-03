# Template-based previews of Azure CLI and Azure PowerShell commands for Key Vault deployments
# https://techcommunity.microsoft.com/t5/azure-tools-blog/announcing-template-based-previews-of-azure-cli-and-azure/ba-p/3933802

#region Azure PowerShell

Get-Module Az.KeyVault -ListAvailable # 4.10.1
Install-Module -Name Az.KeyVault -RequiredVersion 4.12.0-preview -AllowPrerelease -Scope CurrentUser -Verbose

Get-Command New-AzKeyVault -Syntax

$resourceGroupName = 'espc-azkeyvault-rg'
$location = 'westeurope'
$keyvaultName = 'test-azkeyvaultespc2023'


# 1. Create a Resource Group 
New-AzResourceGroup -Name $resourceGroupName -Location $location 

# 2. Validate the creation of a key vault using `-WhatIf`
New-AzKeyvault -Name $keyvaultName -Location $location -ResourceGroupName $resourceGroupName -WhatIf 

# 3. Create a key vault, observe the deployment once the command has completed 
New-AzKeyvault -Name $keyvaultName -Location $location -ResourceGroupName $resourceGroupName -Debug

cd C:\gh\espc23
code .\debug_output.json

# 4. See what will happen if create a key vault in incremental mode and do a little change 
New-AzKeyvault -Name $keyvaultName -Location $location -ResourceGroupName $resourceGroupName  -FailOnExist $false -EnabledForDeployment -WhatIf 

# 5. Create the existing key vault in incremental mode  
New-AzKeyvault -Name $keyvaultName -Location $location -ResourceGroupName $resourceGroupName -FailOnExist $false 

# 6. Clean-up Azure resources 
Remove-AzResourceGroup -Name $resourceGroupName 

#endregion


#region Azure CLI

#region whl package Installation

# Prepare and use a separate virtual environment (in Cloud Shell (PowerShell))
# Create a python virtual env named `testenv` with: 
python -m venv testenv 

# Activate the env (if you are using PowerShell): 
./testenv/bin/Activate.ps1

# Activate the env (if you are using bash): 
# source venv/bin/activate 

# Download .whl files from https://yssa.blob.core.windows.net/cli/azure_cli_keyvault_public_preview.zip on your local machine, unzip the archive and upload .whl packages to Cloud Shell 
# Install 3 CLI whl packages (azure_cli, azure_cli_core, azure_cli_telemetry) 
pip install azure_cli-2.53.0.post20230920063357-py3-none-any.whl azure_cli_core-2.53.0.post20230920063357-py3-none-any.whl azure_cli_telemetry-1.1.0.post20230920063357-py3-none-any.whl

#endregion 

#region Quick start

# Define your variables 
$location = "northeurope" 
$resourceGroupName = 'espc23-azkeyvault-rg' 
$keyvaultName = 'test-azkeyvaultespc23'

# 1. Create resource group 
az group create --resource-group $resourceGroupName --location $location 

# 2. Validate the creation of a keyvault using `--what-if`
az keyvault create --name $keyvaultName --resource-group $resourceGroupName --location $location --what-if

# 3. Create a keyvault, observe the deployment once the command has completed 
az keyvault create --name $keyvaultName --resource-group $resourceGroupName --location $location 

# 4. See what will happen if you create a keyvault in incremental mode and do a little change  
az keyvault create --name $keyvaultName --resource-group $resourceGroupName --location $location --enabled-for-deployment --fail-on-exist false --what-if

# 5. Create the existing keyvault in incremental mode 
az keyvault create --name $keyvaultName --resource-group $resourceGroupName --location $location --fail-on-exist false 

# 6. Clean-up Azure resources 
az group delete -name $resourceGroupName

#endregion


#region whl package clean up  
 
# Deactivate the virtual environment 
Deactivate 

# Delete the virtual environment folder to clean up (if you are using linux) 
rm -rf .\testenv 

#endregion

#endregion