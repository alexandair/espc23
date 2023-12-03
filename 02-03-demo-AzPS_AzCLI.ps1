#region Installation, release notes, breaking changes...

# Azure PowerShell works with PowerShell 5.1 or higher on Windows, or PowerShell 7 or higher on any platform.
# If you are using PowerShell 5 on Windows, you also need .NET Framework 4.7.2 installed.

# https://github.com/Azure/azure-powershell

# https://docs.microsoft.com/powershell/azure/install-az-ps
# https://www.powershellgallery.com/packages/Az/

# Install-Module -Name Az -Repository PSGallery -Scope CurrentUser -AllowClobber 

# Release notes and the .MSI files (the MSI installer only works for PowerShell 5.1 on Windows)
# https://github.com/Azure/azure-powershell/releases/

# Release notes and the breaking changes (migration guides)
# https://learn.microsoft.com/en-us/powershell/azure/release-notes-azureps
# https://learn.microsoft.com/en-us/powershell/azure/upcoming-breaking-changes
# https://learn.microsoft.com/en-us/powershell/azure/migrate-az-11.0.0

# Azure AD to Microsoft Graph migration changes in Azure PowerShell
# https://learn.microsoft.com/en-us/powershell/azure/azps-msgraph-migration-changes

# Update-Module installs the new version side-by-side with previous versions
# It does not uninstall the previous versions
# It's a good idea to have the last 2 versions
Update-Module -Name Az

# Check a version
Get-Module az -ListAvailable
Get-InstalledModule -Name Az

# Az and AzureRM coexistence
# Microsoft doesn't support having both the AzureRM and Az modules installed for PowerShell 5.1 on Windows at the same time.
 
# In a scenario where you want to install both AzureRM and the Az PowerShell module on the same system, AzureRM must be installed only in the user scope for Windows PowerShell.
# Install the Az PowerShell module on PowerShell 7 or higher on the same system.

https://github.com/Azure/azure-cli
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
https://learn.microsoft.com/en-us/cli/azure/release-notes-azure-cli
https://learn.microsoft.com/en-us/cli/azure/microsoft-graph-migration

# Upgrade Azure CLI and extensions
az upgrade

#endregion


#region How to uninstall Azure PowerShell modules

# Uninstallation can be complicated if you have more than one version of the Az PowerShell module installed.
# Because of this complexity, Microsoft only supports uninstalling all versions of the Az PowerShell module that are currently installed.

# A list of all the Az PowerShell module versions installed on a system
Get-InstalledModule -Name Az -AllVersions -OutVariable AzVersions

# A list of all the Az PowerShell modules that need to be uninstalled in addition to the Az module
($AzVersions | ForEach-Object {
  Import-Clixml -Path (Join-Path -Path $_.InstalledLocation -ChildPath PSGetModuleInfo.xml)
}).Dependencies.Name | Sort-Object -Unique -OutVariable AzModules

# Remove the Az modules from memory and then uninstall them
$AzModules | ForEach-Object {
  Remove-Module -Name $_ -ErrorAction SilentlyContinue
  Write-Output "Attempting to uninstall module: $_"
  Uninstall-Module -Name $_ -AllVersions
}

# The final step is to remove the Az PowerShell module
Remove-Module -Name Az -ErrorAction SilentlyContinue
Uninstall-Module -Name Az -AllVersions

#endregion


#region Login experience and secrets management

Connect-AzAccount
as login

# Converting a SecureString to a string

$cred = Get-Credential -UserName $env:USERNAME -Message 'Enter Azure password'
$plainText = $cred.GetNetworkCredential().Password
"Your password is: $plainText"

$password = Read-Host -Prompt 'Enter Azure password' -AsSecureString
$password -is [SecureString]

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

[System.Net.NetworkCredential]::new('', $password).Password

[System.Net.NetworkCredential]::new

# SecretManagement and SecretStore

Install-Module Microsoft.PowerShell.SecretManagement

# The SecretManagement module provides the following cmdlets for accessing secrets and managing SecretVaults

Get-Command -Module Microsoft.PowerShell.SecretManagement | Sort-Object noun | Format-Table -GroupBy noun

# SecretManagement becomes useful once you install and register extension vaults.
# Extension vaults, which are PowerShell modules with a particular structure,
# provide the connection between the SecretManagement module and any local or remote Secret Vault.
Find-Module -Tag "SecretManagement" -Repository PSGallery

# Getting Started with Azure Key Vault
$azKeyVault = Get-AzKeyVault -Name githubkv
$vaultName = ($azKeyVault.ResourceId -split '/')[-1]
$subID = ($azKeyVault.ResourceId -split '/')[2]

Register-SecretVault -Module Az.KeyVault -Name AzKV -VaultParameters  @{ AZKVaultName = $vaultName; SubscriptionId = $subID }

Get-SecretInfo -Vault AzKV
Get-Secret -Name MySecretName -Vault AzKV # -AsPlainText

#endregion


#region Azure CLI vs Azure PowerShell: Side-by-side Command Comparison

# Get available subscriptions
az account list
Get-AzSubscription

# List Azure Locations
az account list-locations
Get-AzLocation

# Create Azure Storage Account
az storage account create --name <StorageAccountName> --resource-group <ResourceGroupName> --location northeurope --sku Standard_LRS --kind StorageV2
New-AzStorageAccount -Name <StorageAccountName> -ResourceGroupName <ResourceGroupName> -Location northeurope -SkuName Standard_LRS -Kind StorageV2

# Create Azure Virtual Machine
az vm create --resource-group myResourceGroup --name myVM --image UbuntuLTS --admin-username azureuser --admin-password '<Password>'
<#
Invalid image "ubuntults". Use a valid image URN, custom image name, custom image id, VHD blob URI, or pick an image from ['CentOS85Gen2', 'Debian11', 'FlatcarLinuxFreeGen2', 'OpenSuseLeap154Gen2', 'RHELRaw8LVMGen2', 'SuseSles15SP3', 'Ubuntu2204', 'Win2022Datacenter', 'Win2022AzureEditionCore', 'Win2019Datacenter', 'Win2016Datacenter', 'Win2012R2Datacenter', 'Win2012Datacenter', 'Win2008R2SP1'].
#>
New-AzVM -ResourceGroupName <ResourceGroupName> -Name myVM -Image UbuntuLTS -Credential (Get-Credential)
<#
New-AzVM: Can't find the image 'ubuntults'.
#>

# Stop VM
az vm stop --name myVM --resource-group <ResourceGroupName>
Stop-AzVM -Name myVM -ResourceGroupName <ResourceGroupName> -StayProvisioned

# Stop & Deallocate VM
az vm deallocate --name myVM --resource-group <ResourceGroupName>
Stop-AzVM -Name myVM -ResourceGroupName <ResourceGroupName>

#endregion


#region Change Output Formats and Select Properties

#output
# AzPS > an object
# AzCLI > JSON string
# --output -o : Output format. Allowed values: json, jsonc, none, table, tsv, yaml, yamlc. Default: json.


# filtering
# --query : JMESPath query string. See http://jmespath.org/ for more information and examples.

az vm list -g lab-rg --query '[].[location, resourceGroup, name]' --output table # columns have generic names (Column1, Column2...)
az vm list -g lab-rg --query '[].{location:location, group:resourceGroup, name:name}' --output table
az vm list -g lab-rg --query '[].[location, resourceGroup, name]' --output tsv

Get-AzLocation | Select-Object DisplayName, Location | Sort-Object DisplayName
az account list-locations --query "sort_by([].{DisplayName: displayName, ARMName:name}, &DisplayName)" --output table

az functionapp list --query "[].{group:resourceGroup, name:name, defaultHostName:defaultHostName}" -o table
# az functionapp list --query "[].{group:resourceGroup, name, defaultHostName}" -o table
Get-AzFunctionApp | Select-Object @{n = 'Group'; e = { $_.resourceGroup } }, name, defaultHostName

az functionapp list | ConvertFrom-Json | Select-Object @{n = 'Group'; e = { $_.resourceGroup } }, name, defaultHostName

az functionapp list --query "[?state=='Running'].{resourceGroup:resourceGroup, name:name, defaultHostName:defaultHostName}" -o table
Get-AzFunctionApp | Where-Object { $_.State -eq 'Running' } | Format-Table resourceGroup, name, defaultHostName
Get-AzFunctionApp | where State -EQ 'Running' | ft resourceGroup, name, defaultHostName

#endregion


#region Different shells

# assign the list of running VMs to a variable
# Azure CLI in Bash shell
running_vm_ids=$(az vm list --resource-group espc23-rg --show-details --query "[?powerState=='VM running'].id" --output tsv)

# verify the value of the variable
echo $running_vm_ids

# Azure CLI in PowerShell shell
$running_vm_ids = az vm list --resource-group espc23-rg --show-details --query "[?powerState=='VM running'].id" --output tsv
$running_vm_ids
# Azure PowerShell
Get-AzVM -ResourceGroupName espc23-rg -Status | Where-Object PowerState -EQ "VM running" | Select-Object -ExpandProperty Id

# Azure CLI in Bash shell
az vm list --resource-group mscommba-rg --show-details --query "[?powerState=='VM deallocated'].id" --output tsv | az vm start --ids @-
# Azure CLI in PowerShell shell
az vm list --resource-group mscommba-rg --show-details --query "[?powerState=='VM deallocated'].id" --output tsv | az vm start --ids `@-
az vm list --resource-group mscommba-rg --show-details --query "[?powerState=='VM deallocated'].id" --output tsv | ForEach-Object {az vm start --ids $_}
Get-AzVM -ResourceGroupName mscommba-rg -Status | Where-Object PowerState -EQ "VM deallocated" | Start-AzvM

az vm list --resource-group mscommba-rg --show-details --query "[?powerState=='VM running'].id" --output tsv | ForEach-Object {az vm deallocate --ids $_}

# Get the application (app reg: espc23app)
az rest --method GET --uri 'https://graph.microsoft.com/v1.0/applications/9339588b-8c94-486a-9170-ab762d0c560a'

# Update `redirectUris` for `web` property
# Bash
az rest --method PATCH --uri 'https://graph.microsoft.com/v1.0/applications/9339588b-8c94-486a-9170-ab762d0c560a' --body '{"web":{"redirectUris":["https://myapp.com"]}}'
# PowerShell, escaping the double quotes
az rest --method PATCH --uri 'https://graph.microsoft.com/v1.0/applications/9339588b-8c94-486a-9170-ab762d0c560a' --body '{\"web\":{\"redirectUris\":[\"https://myapp2.com\"]}}'

# PowerShell, using single quotes, no escaping
Invoke-AzRestMethod -Method PATCH -Uri 'https://graph.microsoft.com/v1.0/applications/9339588b-8c94-486a-9170-ab762d0c560a' -Payload '{"web":{"redirectUris":["https://myapp3.com"]}}'

# PowerShell, using a hash table
# $payload_ht = @{web = @{redirectUris = @("https://myapp4.com")}}
$payload_ht = @{web = @{redirectUris = @('https://myapp4.com')}}
$payload = $payload_ht | ConvertTo-Json -Compress

Invoke-AzRestMethod -Method PATCH -Uri 'https://graph.microsoft.com/v1.0/applications/9339588b-8c94-486a-9170-ab762d0c560a' -Payload $payload

#endregion


#region Tab-completion, Predictive IntelliSense

# Completers in Azure PowerShell
# Get-AzVm -Name L<TAB> -ResourceGroupName <Ctrl+Space> 
# Get-AzVm -ResourceGroupName l<TAB> -Name <Ctrl+Space>
# Stop-AzVM -Id *demovm*<TAB>

# Predictive IntelliSense (Enable Az Predictor)
# matching predictions from the user’s history and additional domain specific plugins

Install-Module Az.Tools.Predictor -Scope CurrentUser -Verbose 

# Predictions are displayed in one of two views depending on the user preference
# InlineView – This is the default view and displays the prediction inline with the user’s typing. This view is similar to other shells Fish and ZSH.
# ListView – ListView provides a dropdown list of predictions below the line the user is typing.

# You can switch between view modes with the F2 key.

# To enable Az Predictor for all sessions, run the following command and it will update your PowerShell profile ($profile)
Enable-AzPredictor -AllSession

code $PROFILE

# A tab-completion for Azure CLI commands in PowerShell shell

#endregion


#region Idempotency

#Azure CLI
az group create --name espc23-rg --location northeurope

az storage account create --name espc23cli --resource-group espc23-rg --location northeurope
az storage account create --name espc23cli --resource-group espc23-rg --location northeurope

# Azure PowerShell
New-AzResourceGroup -Name espc23-rg -Location northeurope
New-AzResourceGroup -Name espc23-rg -Location northeurope -Force

New-AzStorageAccount -Name espc23cli -ResourceGroupName espc23-rg -Location northeurope -SkuName Standard_LRS 
# New-AzStorageAccount: The storage account named espc23cli is already taken. (Parameter 'Name')

#endregion





























# Azure CLI vs Azure PowerShell: Side-by-side Command Comparison

#region Sign in, Subscription, and Location Commands

# Sign in with a web browser
az login
Connect-AzAccount

# Get available subscriptions
az account list
Get-AzSubscription

# Set Subscription
az account set --subscription <SubscriptionId>
Set-AzContext -Subscription <SubscriptionID>

# List Azure Locations
az account list-locations
Get-AzLocation

#endregion

#region Find Versions, Get Help, and View Command Help:

# Find Version
az --version
Get-InstalledModule -Name Az

# Get Help
az --help
Get-Help

# View Command Help
az vm --help
Get-Help -Name New-AzVM

#endregion

#region Create a Resource Group, VM, and Storage Account

# Create Resource Group
az group create --name <ResourceGroupName> --location northeurope
New-AzResourceGroup -Name <ResourceGroupName> -Location northeurope

# Create Azure Virtual Machine
az vm create --resource-group myResourceGroup --name myVM --image UbuntuLTS --admin-username azureuser --admin-password '<Password>'
New-AzVM -ResourceGroupName <ResourceGroupName> -Name myVM -Image UbuntuLTS -Credential (Get-Credential)

# Create Azure Storage Account
az storage account create --name <StorageAccountName> --resource-group <ResourceGroupName> --location northeurope --sku Standard_LRS --kind StorageV2
New-AzStorageAccount -Name <StorageAccountName> -ResourceGroupName <ResourceGroupName> -Location northeurope -SkuName Standard_LRS -Kind StorageV2

#endregion

#region Manage Azure Virtual Machines

# List VM
az vm list
Get-AzVM

# Restart VM
az vm restart --name myVM --resource-group <ResourceGroupName>
Restart-AzVM -Name myVM -ResourceGroupName <ResourceGroupName>

# Stop VM
az vm stop --name myVM --resource-group <ResourceGroupName>
Stop-AzVM -Name myVM -ResourceGroupName <ResourceGroupName> -StayProvisioned

# Stop & Deallocate VM
az vm deallocate --name myVM --resource-group <ResourceGroupName>
Stop-AzVM -Name myVM -ResourceGroupName <ResourceGroupName>

# Start VM
az vm start --name myVM --resource-group <ResourceGroupName>
Start-AzVM -Name myVM -ResourceGroupName <ResourceGroupName>

# Delete VM
az vm delete --name myVM --resource-group <ResourceGroupName>
Remove-AzVM -Name myVM -ResourceGroupName <ResourceGroupName>

#endregion

#region Select Properties and Change Output Formats

# Show all subscription information
az account list --all
Get-AzSubscription | Select-Object -Property *

# Output as a Table
az account list -o table
Get-AzSubscription | Format-Table

# Output as JSON
az account show
Get-AzSubscription | ConvertTo-Json

# jobs
# CLI output | ConvertFrom-Json
# JMES query vs Select-Object
az vm list --query "[].{resource:resourceGroup, name:name}" --output table
# JMES query vs Where-Object
# extensions vs modules

az vm list -g lab-rg --query '[].[id, location, resourceGroup, name]' --output tsv
az vm list -g lab-rg --query '[].[id, location, resourceGroup, name]' --output table # columns have generic names (Column1, Column2...)
az vm list -g lab-rg --query '[].{location:location, group:resourceGroup, name:name}' --output table

#endregion


az keyvault secret set --name MySecretName --vault-name githubkv --value MySecretValue

# assign the list of running VMs to a variable
# Azure CLI in Bash shell
running_vm_ids=$(az vm list --resource-group mscommba-rg --show-details --query "[?powerState=='VM running'].id" --output tsv)

# verify the value of the variable
echo $running_vm_ids

# Azure CLI in PowerShell shell
$running_vm_ids = az vm list --resource-group mscommba-rg --show-details --query "[?powerState=='VM running'].id" --output tsv
$running_vm_ids
# Azure PowerShell
Get-AzVM -ResourceGroupName mscommba-rg -Status | Where-Object PowerState -EQ "VM running" | Select-Object -ExpandProperty Id

# Azure CLI in Bash shell
az vm list --resource-group mscommba-rg --show-details --query "[?powerState=='VM deallocated'].id" --output tsv | az vm start --ids @-
# Azure CLI in PowerShell shell
az vm list --resource-group mscommba-rg --show-details --query "[?powerState=='VM deallocated'].id" --output tsv | az vm start --ids `@-
az vm list --resource-group mscommba-rg --show-details --query "[?powerState=='VM deallocated'].id" --output tsv | ForEach-Object {az vm start --ids $_}
Get-AzVM -ResourceGroupName mscommba-rg -Status | Where-Object PowerState -EQ "VM deallocated" | Start-AzvM

az vm list --resource-group mscommba-rg --show-details --query "[?powerState=='VM running'].id" --output tsv | ForEach-Object {az vm deallocate --ids $_}

# Get the application
az rest --method GET --uri 'https://graph.microsoft.com/v1.0/applications/d3dcaac1-b39a-426a-90cf-6f462e1a0443'

# Update `redirectUris` for `web` property
# Bash
az rest --method PATCH --uri 'https://graph.microsoft.com/v1.0/applications/d3dcaac1-b39a-426a-90cf-6f462e1a0443' --body '{"web":{"redirectUris":["https://myapp.com"]}}'
# PowerShell, escaping the double quotes
az rest --method PATCH --uri 'https://graph.microsoft.com/v1.0/applications/d3dcaac1-b39a-426a-90cf-6f462e1a0443' --body '{\"web\":{\"redirectUris\":[\"https://myapp.com\"]}}'

# PowerShell, using single quotes, no escaping
Invoke-AzRestMethod -Method PATCH -Uri 'https://graph.microsoft.com/v1.0/applications/d3dcaac1-b39a-426a-90cf-6f462e1a0443' -Payload '{"web":{"redirectUris":["https://myapp.com"]}}'

# PowerShell, using a hash table
# $payload_ht = @{web = @{redirectUris = @("https://myapp.com")}}
$payload_ht = @{web = @{redirectUris = @('https://myapp.com')}}
$payload = $payload_ht | ConvertTo-Json -Compress

Invoke-AzRestMethod -Method PATCH -Uri 'https://graph.microsoft.com/v1.0/applications/d3dcaac1-b39a-426a-90cf-6f462e1a0443' -Payload $payload

# Decode JWT token in Bash
function jwt_decode(){
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$1"
}
<#
The selected code is a function written in PowerShell, a scripting language developed by Microsoft for task automation and configuration management. The function is named jwt_decode.

The purpose of this function is to decode a JSON Web Token (JWT). JWTs are a compact, URL-safe means of representing claims to be transferred between two parties. They are often used for authentication and information exchange.

The function uses jq, a lightweight and flexible command-line JSON processor. The -R option tells jq to read a string instead of JSON. The split(".") command splits the JWT, which is typically a string with three Base64-encoded parts separated by dots. The .[1] command selects the second part of the split JWT, which is the payload containing the claims. The @base64d command decodes the Base64-encoded payload, and fromjson converts the JSON string into a JSON object.

The <<< "$1" part is a bash construct called a "here string". It allows the string that follows to be used as the input to the command that precedes it. In this case, it's providing the JWT (which is the first argument to the function, represented by $1) as input to the jq command.

To improve the readability of this code, you might consider adding comments to explain what each part of the jq command is doing. For performance, as this is a simple command-line function, there's not much that can be done to improve it without changing the functionality. However, you could consider error handling for cases where the input is not a valid JWT.
#>

$jwt = (Get-AzAccessToken).Token
$payload = $jwt.Split(".")[1] -replace '_', '/' -replace '-','+' | % { [System.Convert]::FromBase64String($_) }
$payloadJson = [System.Text.Encoding]::UTF8.GetString($payload)
$payloadObject = ConvertFrom-Json $payloadJson
$payloadObject

function Decode-JWT ($jwt) {
    $payload = $jwt.Split('.')[1] -replace '_', '/' -replace '-', '+' | ForEach-Object { [System.Convert]::FromBase64String($_) }
    [System.Text.Encoding]::UTF8.GetString($payload) | ConvertFrom-Json
}

<#
The selected code is written in PowerShell, a scripting language developed by Microsoft for task automation and configuration management. This particular code snippet is used to decode the payload of a JSON Web Token (JWT).

In the first line, the $jwt.Split('.')[1] command splits the JWT into parts using the dot (.) as a delimiter and selects the second part, which is the payload. The -replace '_', '/' -replace '-', '+' commands replace underscore characters with slashes and hyphen characters with plus signs. This is necessary because the JWT specification uses a URL-safe variant of Base64 encoding which replaces '+' with '-' and '/' with '_'.

The ForEach-Object { [System.Convert]::FromBase64String($_) } command then converts each Base64-encoded string back into a byte array. The result is stored in the $payload variable.

In the second line, [System.Text.Encoding]::UTF8.GetString($payload) converts the byte array back into a string using UTF-8 encoding. The ConvertFrom-Json command then converts the JSON string into a PowerShell object.

To improve the readability of this code, you might consider adding comments to explain what each part of the code is doing. For performance, as this is a simple command-line function, there's not much that can be done to improve it without changing the functionality. However, you could consider error handling for cases where the input is not a valid JWT.
#>

<#
GitHub Copilot
Sure, here's a comparison of Azure PowerShell and Azure CLI:

Azure PowerShell:

Pros:

Azure PowerShell is a great choice if you're already familiar with PowerShell scripting and prefer a consistent scripting experience.
It provides a full-fledged scripting environment with the power of objects. This is useful for complex scripting and automation tasks.
Azure PowerShell works well with other PowerShell modules and integrates seamlessly with the Windows ecosystem.
It supports Desired State Configuration (DSC) for declarative scripting.
Azure PowerShell cmdlets follow a Verb-Noun naming convention, which can make it easier to discover and remember commands.
Cons:

Azure PowerShell cmdlets can be verbose and may require more typing compared to Azure CLI.
The learning curve might be steep if you're not already familiar with PowerShell.
Azure PowerShell is less friendly for non-Windows platforms, although it's now cross-platform with PowerShell Core.
The output is object-based, which can be overwhelming if you're used to text-based output.
Azure PowerShell is updated frequently, which can sometimes lead to breaking changes.
Azure CLI:

Pros:

Azure CLI commands are often simpler and easier to type than Azure PowerShell cmdlets.
It's a great choice if you're working on a non-Windows platform or prefer a command-line interface.
Azure CLI is designed to be easy to learn and get started with.
The output is text-based and easy to read and filter.
Azure CLI supports autocomplete feature which can speed up typing commands.
Cons:

Azure CLI might not be as powerful as PowerShell for complex scripting and automation tasks.
It doesn't integrate as seamlessly with the Windows ecosystem as PowerShell does.
Azure CLI commands don't follow a consistent naming convention like PowerShell cmdlets do.
While Azure CLI is easy to get started with, it might require more effort to master compared to PowerShell if you're already familiar with the latter.
Azure CLI also gets updated frequently, which can sometimes lead to breaking changes.
#>

<#
Sure, here are some more advanced pros and cons of Azure PowerShell and Azure CLI:

Azure PowerShell:

Pros:

Azure PowerShell supports the use of pipelines, which allows you to pass the output of one cmdlet as input to another cmdlet. This can be very powerful for complex scripting tasks.
It has deep integration with .NET, allowing you to leverage .NET classes and methods directly in your scripts.
Azure PowerShell supports the use of Desired State Configuration (DSC), a declarative language for system configuration management.
It has a rich set of cmdlets for managing Azure resources, providing a comprehensive toolset for Azure administration.
Azure PowerShell supports the use of background jobs, which can be useful for long-running tasks.
Cons:

Azure PowerShell can be slower than Azure CLI for certain tasks due to its object-oriented nature.
The error handling in PowerShell can be complex and unintuitive, especially for beginners.
PowerShell's syntax can be difficult to understand if you're coming from a different scripting language.
While PowerShell is now cross-platform, not all modules and cmdlets are available on all platforms.
PowerShell's security features, while robust, can sometimes get in the way of scripting tasks.
Azure CLI:

Pros:

Azure CLI has a simpler syntax compared to PowerShell, which can make it easier to learn for beginners.
It is designed to be used interactively, making it a good choice for ad-hoc tasks.
Azure CLI supports the use of JMESPath query language for filtering output, which can be very powerful.
It has a consistent output format, making it easier to parse the output in scripts.
Azure CLI commands are idempotent, meaning running the same command multiple times will always produce the same result.
Cons:

Azure CLI doesn't support the use of pipelines like PowerShell does.
It doesn't have as deep integration with .NET as PowerShell does.
While Azure CLI's syntax is simpler, it might not be as expressive as PowerShell's syntax for complex scripting tasks.
Azure CLI doesn't support the use of background jobs like PowerShell does.
The error handling in Azure CLI can be less detailed compared to PowerShell.
#>








