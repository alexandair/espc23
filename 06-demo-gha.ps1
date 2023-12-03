# DEMO: Deploy Bicep files by using GitHub Actions

#region Create a new GitHub repository

cd c:\gh

# create a new remote repository and clone it locally
gh repo create espc23 --public --clone

#endregion


#region Create resource group

$resourceGroupName = "demowebsite-rg"
$location = "northeurope"

az group create -n $resourceGroupName -l $location

#endregion


#region Generate deployment credentials

# Create a user-assigned managed identity

Install-Module -Name Az.ManagedServiceIdentity -AllowPrerelease
$resourceGroupName_UAMI = "espc23-rg"
New-AzUserAssignedIdentity -Name uami-espc23 -ResourceGroupName $resourceGroupName_UAMI -Location $location

# Configure a user-assigned managed identity to trust an external identity provider

New-AzFederatedIdentityCredentials -Name fic-espc23 -IdentityName uami-espc23 -ResourceGroupName $resourceGroupName_UAMI -Issuer "https://token.actions.githubusercontent.com" -Subject "repo:alexandair/espc23:ref:refs/heads/main" -Audience "api://AzureADTokenExchange"

<#
Name         Issuer                                      Subject                                      Audience
----         ------                                      -------                                      --------
fic-espc23 https://token.actions.githubusercontent.com repo:alexandair/espc23:ref:refs/heads/main {api://AzureADTokenExchange}
#>

New-AzFederatedIdentityCredentials -Name fic2-espc23 -IdentityName uami-espc23 -ResourceGroupName $resourceGroupName_UAMI -Issuer "https://token.actions.githubusercontent.com" -Subject "repo:alexandair/espc23:environment:Website" -Audience "api://AzureADTokenExchange"

Get-AzFederatedIdentityCredentials -IdentityName uami-espc23 -ResourceGroupName $resourceGroupName_UAMI | fl * 

$uami_clientId = (Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName_UAMI -Name uami-espc23).ClientId

cd c:\gh\espc23
gh secret set AZURE_UAMI_CLIENT_ID --body $uami_clientId

# ADD ROLE ASSIGNMENT FOR UAMI
# ROLE: contributor
# SCOPE: resource group demowebsite-rg

$uami_principalId = (Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName_UAMI -Name uami-espc23).PrincipalId
$subscriptionId = (Get-AzContext).Subscription.Id

New-AzRoleAssignment -ObjectId $uami_principalId -RoleDefinitionName "Contributor" -Scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName"

#endregion

# Open GitHub repository (https://github.com/alexandair/espc23) in browser
# Workflow file: .github/workflows/workflow.yml
# Other files are in the Deploy folder
cd C:\gh\espc23
gh browse
