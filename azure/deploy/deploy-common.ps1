#
# Deploys petclinic-common ARM template containing: 
# - the common app service plan
#
# Assumes user is interactively logged on to Azure and that the right subscription was selected


[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
  [string]$SubscriptionName,
  
  [Parameter(Mandatory=$True)]
  [string]$RGName,
  
  [Parameter(Mandatory=$True)]
  [string]$Location,

  [Parameter(Mandatory=$True)]
  [string]$AppServicePlanName
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

# Deploy ARM template for petclinic common components: app service plan
$scriptDir = Split-Path $MyInvocation.MyCommand.Path 
New-AzureRmResourceGroupDeployment -Verbose -Force `
   -Name "common" `
   -ResourceGroupName $RGName `
   -TemplateFile "$scriptDir/Templates/petclinic-common.json" `
   -AppServicePlanName $AppServicePlanName  