#
# Deploys code for the pet-clinic web app onto ARM infrastructure from deploy-webappinfra.json
#

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
  [string]$SubscriptionName,
  
  [Parameter(Mandatory=$True)]
  [string]$RGName,
  
  [Parameter(Mandatory=$True)]
  [string]$WebAppName
)

# Determine current working directory:
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$parentDirectoryPath = (Get-Item $directorypath).Parent.FullName
$amsflowRootDirectoryPath = (Get-Item $parentDirectoryPath).Parent.Parent.FullName
$amsflowSourceDirectoryPath = "$amsflowRootDirectoryPath\source"

# Constants:
$webAppPublishingProfileFileName = $directorypath + "\petclinic.publishsettings"
echo "web publishing profile will be stored to: $webAppPublishingProfileFileName"

# Determine which directory to deploy:
# $sourceDirToDeploy = $amsflowSourceDirectoryPath + "\..\..\target\petclinic.war"
$sourceDirToDeploy = "C:\Users\Christof\source\spring-petclinic\spring-petclinic\target"
echo "source directory to deploy: $sourceDirToDeploy"

# Build the pet-clinic code:
# TODO: call Maven here

# Select Subscription:
Get-AzureRmSubscription -SubscriptionName "$SubscriptionName" | Select-AzureRmSubscription
Get-AzureRmWebApp -Name $WebAppName
echo "Selected Azure Subscription"

# Fetch publishing profile for web app:
Get-AzureRmWebAppPublishingProfile -Name $WebAppName -OutputFile $webAppPublishingProfileFileName -ResourceGroupName $RGName
echo "Fetched Azure Web App Publishing Profile: petclinic.publishsettings"

# Parse values from .publishsettings file:
[Xml]$publishsettingsxml = Get-Content $webAppPublishingProfileFileName
$websiteName = $publishsettingsxml.publishData.publishProfile[0].msdeploySite
echo "web site name: $websiteName"

$username = $publishsettingsxml.publishData.publishProfile[0].userName
echo "user name: $username"

$password = $publishsettingsxml.publishData.publishProfile[0].userPWD
echo "password: $password"

$computername = $publishsettingsxml.publishData.publishProfile[0].publishUrl
echo "computer name: $computername"

# Deploy the pet-clinic web app
& "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe" `
-verb:sync `
-source:contentPath="$sourceDirToDeploy" `
-dest:contentPath="$WebAppName/webapps/petclinic.war",ComputerName="https://$computername/msdeploy.axd?site=$websiteName",UserName="$username",Password="$password",AuthType="Basic"

