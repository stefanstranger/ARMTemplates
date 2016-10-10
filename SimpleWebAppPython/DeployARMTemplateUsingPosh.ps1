# ---------------------------------------------------
# Script: C:\Users\Stefan\OneDrive for Business\Customers\2016\Heineken\DeployARMTemplateUsingPosh.ps1
# Tags:
# Version:
# Author: Stefan Stranger
# Date: 10/10/2016 09:54:18
# Description: Deploy ARM Template using PowerShell
# Comments:
# Changes:  
# Disclaimer: 
# This example is provided “AS IS” with no warranty expressed or implied. Run at your own risk. 
# **Always test in your lab first**  Do this at your own risk!! 
# The author will not be held responsible for any damage you incur when making these changes!
# ---------------------------------------------------

#region Variables
$ResourceGroupName = 'ContosoHWebAppRG'
$Location = 'West Europe'
$PathToJsonTemplate = 'C:\Users\Stefan\Documents\GitHub\ARMTemplates\SimpleWebAppPython'
$ARMTemplateName = 'azuredeploy.json'
$ARMTemplateParameterName = 'azuredeploy.parameters.json'
#endregion

#region Connect to Azure
#Login to Azure
Add-AzureRmAccount
 
#Select Azure Subscription
$subscription = 
    (Get-AzureRmSubscription |
        Out-GridView `
        -Title 'Select an Azure Subscription ...' `
    -PassThru)
 
Set-AzureRmContext -SubscriptionId $subscription.subscriptionId -TenantId $subscription.TenantID

#endregion

#region deploy webapp
#Create new Resource Group for WebApp
#First Check if Resource Group already exists.
If (!(Get-AzureRMResourceGroup -name $ResourceGroupName -Location $Location))
{
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
}

#Test ARM Template
$ARMTemplate = $PathToJsonTemplate + '\' + $ARMTemplateName
Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $ARMTemplate

#Deploy ARM Template with local Parameter file
$ARMTemplateParameter = $PathToJsonTemplate + '\' + $ARMTemplateParameterName
New-AzureRmResourceGroupDeployment -Name TestDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $ARMTemplate -TemplateParameterFile $ARMTemplateParameter

#endregion

#region verify ARM Deployment
#Get Resource group
Get-AzureRmResourceGroup -Name $ResourceGroupName -OutVariable ResourceGroup

#Get WebApp within ResourceGroup
Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName -OutVariable WebApp

#Get WebApp Slot
#Get WebApp Hosting Plan name
$HostingPlanName = $WebApp.ServerFarmId.split('/')[-1]
Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/serverfarms -ResourceName $HostingPlanName -ApiVersion 2015-08-01

#Get WebApp Web Properties
Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/config -ResourceName "$($WebApp.SiteName)/web" -ApiVersion 2015-08-01 |
    Select-Object -ExpandProperty Properties

#Get WebApp Web Properties
Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/config -ResourceName "$($WebApp.SiteName)/web" -ApiVersion 2015-08-01 |
    Select-Object -ExpandProperty Properties
#endregion

#region clean up

#Remove WebApp
Remove-AzureRMWebApp -ResourceGroupName $ResourceGroupName -Name $WebApp.Name

#Remove WebService Plan
Remove-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/serverfarms -ResourceName $HostingPlanName -ApiVersion 2015-08-01 -Force


#Remove ResourceGroup
Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force
#endregion
