#
# deploy all amsflow components
#

[CmdletBinding()]
Param(
  # Params required for App Service Plan creation:
  [Parameter(Mandatory=$True)]
  [string]$SubscriptionName,
  
  [Parameter(Mandatory=$True)]
  [string]$RGName,
  
  [Parameter(Mandatory=$True)]
  [string]$Location,

  [Parameter(Mandatory=$True)]
  [string]$AppServicePlanName,

  # Params required for Web App creation:
  [Parameter(Mandatory=$True)]
  [string]$PetClinicWebAppName
)

Select-AzureRmSubscription -SubscriptionName $SubscriptionName
Write-Host "Selected subscription: $SubscriptionName"

# Find existing or deploy new Resource Group:
$rg = Get-AzureRmResourceGroup -Name $RGName -ErrorAction SilentlyContinue
if (-not $rg)
{
    New-AzureRmResourceGroup -Name "$RGName" -Location "$Location"
    echo "New resource group deployed: $RGName"   
}
else{ echo "Resource group found: $RGName"}

# Deploy ARM template for petclinic components
$scriptDir = Split-Path $MyInvocation.MyCommand.Path 
New-AzureRmResourceGroupDeployment -Verbose -Force `
   -Name "all" `
   -ResourceGroupName $RGName `
   -TemplateFile "$scriptDir/Templates/petclinic-all.json" `
   -AppServicePlanName $AppServicePlanName `
   -WebAppName $PetClinicWebAppName

# Deploy war file onto Web App:
. "./deploy-webappcode.ps1" `
  -SubscriptionName "$SubscriptionName" `
  -RGName "$RGName" `
  -WebAppName $PetClinicWebAppName
