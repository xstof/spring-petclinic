#
# Deploys petclinic-webappinfra ARM template
#

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
  [string]$SubscriptionName,
  
  [Parameter(Mandatory=$True)]
  [string]$RGName,
  
  [Parameter(Mandatory=$True)]
  [string]$Location,

  [Parameter(Mandatory=$True)]
  [string]$WebAppName
)

Select-AzureRmSubscription -SubscriptionName $SubscriptionName
Write-Host "Selected subscription: $SubscriptionName"

# Find existing or deploy new Resource Group:
$rg = Get-AzureRmResourceGroup -Name $RGName -ErrorAction SilentlyContinue
if (-not $rg)
{
    # Cannot continue if resource group was not found.  (Depending on common resources which should have been deployed earlier.)
    throw  "Resource Group NOT found: $RGName"
}
else{ echo "Resource Group found: $RGName"}
  
# Deploy ARM template
$scriptDir = Split-Path $MyInvocation.MyCommand.Path 
New-AzureRmResourceGroupDeployment -Verbose -Force `
   -Name "webappinfra" `
   -ResourceGroupName $RGName `
   -TemplateFile "$scriptDir/Templates/petclinic-webappinfra.json" `
   -WebAppName $WebAppName