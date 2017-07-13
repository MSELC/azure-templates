$inputCSV = "Parameters.csv"
$templateUri = "https://github.com/MSELC/azure-templates/VM-PaloAlto/template.json"
$adminPassword = Read-Host "Enter local admin password" -AsSecureString

Import-Module AzureRM
Login-AzureRmAccount
############################

$csv = Import-Csv $inputCSV
foreach ($object in $csv)
{
    $objectName = $object.vmName
    Write-Host "`nCreating VM: $($objectName)"
    Write-Host "Selecting subscription: $($object.subscriptionName)"
    Select-AzureRmSubscription -SubscriptionName $object.subscriptionName | Out-Null
    $resourceGroup = Get-AzureRmResourceGroup -Name $object.resourceGroupName -ErrorAction SilentlyContinue
    if(!$resourceGroup)
    {
        Write-Host "Creating resource group $($object.resourceGroupName) in location $($vnet.region)"
        New-AzureRmResourceGroup -Name $object.resourceGroupName -Location $object.location
    }
    else{
        Write-Host "Using existing resource group $($object.resourceGroupName)"
    }
       
    $parameters = @{}
    $parameters.Add("vmName",$object.vmName)
	$parameters.Add("location",$object.location)
	$parameters.Add("vmSize",$object.vmSize)
	$parameters.Add("virtualNetworkName",$object.virtualNetworkName)
	$parameters.Add("virtualNetworkExistingRGName",$object.virtualNetworkExistingRGName)
	$parameters.Add("subnet0Name",$object.subnet0Name)
	$parameters.Add("subnet1Name",$object.subnet1Name)
	$parameters.Add("subnet2Name",$object.subnet2Name)
	$parameters.Add("nic0IPAddress",$object.nic0IPAddress)
	$parameters.Add("nic1IPAddress",$object.nic1IPAddress)
	$parameters.Add("nic2IPAddress",$object.nic2IPAddress)
	$parameters.Add("adminUsername",$object.adminUsername)
	$parameters.Add("adminPassword",$adminPassword)
	$parameters.Add("baseUrl",$object.baseUrl)
    $parameters.Add("diskType",$object.diskType)
	$parameters.Add("storageAccountName",$object.storageAccountName)
	$parameters.Add("managedDiskStorageType",$object.managedDiskStorageType)
    $parameters.Add("authenticationType",$object.authenticationType)
	$parameters.Add("sshKey",$object.sshKey)
	$parameters.Add("availabilitySetName",$object.availabilitySetName)
    if ($object.diskType -eq "unmanaged"){
        $parameters.Add("availabilitySetSku","Classic")
    }
    elseif ($object.diskType -eq "managed") {
        $parameters.Add("availabilitySetSku","Aligned")
    }

    Write-Host "Deploying template"
    New-AzureRmResourceGroupDeployment -Name "$($objectName)_Deployment" -ResourceGroupName $object.resourceGroupName -TemplateUri $templateUri -TemplateParameterObject $parameters
}