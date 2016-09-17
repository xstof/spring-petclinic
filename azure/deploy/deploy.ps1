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

# Deploy common components (App Service Plan)
. "./deploy-common.ps1" `
  -SubscriptionName "$SubscriptionName" `
  -RGName "$RGName" `
  -Location "$Location" `
  -AppServicePlanName "$AppServicePlanName"

  # Deploy empty Web App onto App Service Plan:
. "./deploy-webappinfra.ps1" `
  -SubscriptionName "$SubscriptionName" `
  -RGName "$RGName" `
  -Location "$Location" `
  -WebAppName $PetClinicWebAppName

# Deploy war file onto Web App:
. "./deploy-webappcode.ps1" `
  -SubscriptionName "$SubscriptionName" `
  -RGName "$RGName" `
  -WebAppName $PetClinicWebAppName
