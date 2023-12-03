
# Azure Cloud Shell and MSI

((Invoke-WebRequest -Uri "$env:MSI_ENDPOINT`?resource=https://management.azure.com/" -Headers @{Metadata='true'}).content |  ConvertFrom-Json).access_token

(Get-AzAccessToken).Token

# Cloud shell doesn't manage the token used by CLI, rather just initializes the CLI with existing credentials used in the portal.
#  get-access-token is a CLI command which retrieves it from the tokens cached by CLI itself
az account get-access-token

# Remove the quotes from the token 
az account get-access-token --query accessToken -o tsv

# a site where you paste a token to get it decoded
https://jwt.ms/ 

# Decoding the token in Bash (Cloud Shell)
function jwt_decode(){
   jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$1"
}

jwt_decode $(az account get-access-token --query accessToken -o tsv)

# Decoding the token in PowerShell (Cloud Shell)
function Decode-JWT ($jwt) {
    $payload = $jwt.Split('.')[1] -replace '_', '/' -replace '-', '+' | ForEach-Object { [System.Convert]::FromBase64String("$_==") }
    [System.Text.Encoding]::UTF8.GetString($payload) | ConvertFrom-Json
}

Decode-JWT (Get-AzAccessToken).Token


# The cloud shell is actually just simulating the managed identity behavior, but indeed gets tokens from the logged-in user.

<# The following example demonstrates how to use the managed identities for Azure resources REST endpoint from a PowerShell client to:

Acquire an access token.
Use the access token to call an Azure Resource Manager REST API and get information about the VM. Be sure to substitute your subscription ID, resource group name, and virtual machine name for <SUBSCRIPTION-ID>, <RESOURCE-GROUP>, and <VM-NAME>, respectively.
#>

# Get an access token for managed identities for Azure resources
Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -Headers @{Metadata="true"} -OutVariable response
$content = $response.Content | ConvertFrom-Json
$access_token = $content.access_token
echo "The managed identities for Azure resources access token is $access_token"

# Use the access token to get resource information for the VM
$vmInfoRest = (Invoke-WebRequest -Uri 'https://management.azure.com/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/lab-rg/providers/Microsoft.Compute/virtualMachines/lon-dc1?api-version=2017-12-01' -Method GET -ContentType "application/json" -Headers @{ Authorization ="Bearer $access_token"}).content
echo "JSON returned from call to get VM info:"
echo $vmInfoRest

##########

curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true
curl 'http://localhost:50342/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true


# To export the user settings Cloud Shell saves for you such as preferred shell, font size, and font type
# run the following commands.

token="Bearer $(curl http://localhost:50342/oauth2/token --data "resource=https://management.azure.com/" -H Metadata:true -s | jq -r ".access_token")"
curl https://management.azure.com/providers/Microsoft.Portal/usersettings/cloudconsole?api-version=2017-12-01-preview -H Authorization:"$token" -s | jq

$token = ((Invoke-WebRequest -Uri "$env:MSI_ENDPOINT`?resource=https://management.core.windows.net/" -Headers @{Metadata='true'}).content |  ConvertFrom-Json).access_token
((Invoke-WebRequest -Uri https://management.azure.com/providers/Microsoft.Portal/usersettings/cloudconsole?api-version=2017-12-01-preview -Headers @{Authorization = "Bearer $token"}).Content | ConvertFrom-Json).properties | Format-List