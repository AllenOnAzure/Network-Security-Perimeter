#Azure network security perimeter - Public Github version 1.0#


######Step 1 - Install the Az.Tools.Installer module:
Install-Module -Name Az.Tools.Installer -Repository PSGallery -Force


######Step 2 - Install the preview build of the Az.Network module: 
Install-Module -Name Az.Network -AllowPrerelease -Force -RequiredVersion 7.13.0-preview


######Step 3 - Sign in to your Azure account
Connect-AzAccount -UseDeviceAuthentication


######Step 4 - Connect to your subscription
#List all subscriptions
$SubscriptionID = "<subscriptionID>"
Set-AzContext -Subscription $SubscriptionID


######Step 5 - Register the Microsoft.Network resource provider:
Register-AzResourceProvider -ProviderNamespace Microsoft.Network


######Step 6 - Create a resource group and key vault
# Create a resource group
$rgParams = @{
    Name = "allen-lab-rg"
    Location = "southafricanorth"
}
New-AzResourceGroup @rgParams


######Step 7 - Create a key vault
$keyVaultName = "allen-lab-keyvault2"
$keyVaultParams = @{
    Name = $keyVaultName
    ResourceGroupName = $rgParams.Name
    Location = $rgParams.Location
}
$keyVault = New-AzKeyVault @keyVaultParams


######Step 8 - Create a network security perimeter
$nsp = @{ 
        Name = 'allen-lab-NetworkSecurityProvider' 
        location = $rgParams.Location
        ResourceGroupName = $rgParams.name  
        }

$demoNSP=New-AzNetworkSecurityPerimeter @nsp
$nspId = $demoNSP.Id


######Step 9 - CREATE a new network security perimeter PROFILE
$nspProfile = @{ 
        Name = 'allen-nsp-profileAKV' 
        ResourceGroupName = $rgParams.name 
        SecurityPerimeterName = $nsp.name 
        }

$demoProfileNSP=New-AzNetworkSecurityPerimeterProfile @nspprofile


######Step 10 - ASSOCIATE the PaaS resource with the network security perimeter PROFILE

#10.1 - Retrieve the Key Vault Resource ID:

$keyVault = Get-AzKeyVault -ResourceGroupName $rgParams.name -VaultName $KeyvaultName
$keyVaultResourceID = $keyVault.ResourceID
$keyVaultResourceID 


$nspAssociation = @{ 
        AssociationName = 'allen-nsp-associationAKV' 
        ResourceGroupName = $rgParams.name 
        SecurityPerimeterName = $nsp.name 
        AccessMode = 'Learning'  
        ProfileId = $demoProfileNSP.Id 
        PrivateLinkResourceId = $keyVaultResourceID 
        }

New-AzNetworkSecurityPerimeterAssociation @nspassociation | format-list



######Step 11 - Update association by changing the access mode to ENFORCED
# Update the association to enforce the access mode
    $updateAssociation = @{ 
        AssociationName = $nspassociation.AssociationName 
        ResourceGroupName = $rgParams.name 
        SecurityPerimeterName = $nsp.name 
        AccessMode = 'Enforced'
        }
    Update-AzNetworkSecurityPerimeterAssociation @updateAssociation | format-list
	

######Step 12 - Create, update network security perimeter access rules

<#
NOTE FOR PAAS RESOURCES: If managed identity is not assigned to the resource which supports it, 
outbound access to other resources within the same perimeter will be denied. 
Subscription based inbound rules intended to allow access from this resource will not take effect.
#>

# Create an inbound access rule for a public IP address prefix
    $inboundRule = @{ 
        Name = 'nsp-inboundRule' 
        ProfileName = $nspprofile.Name  
        ResourceGroupName = $rgParams.Name  
        SecurityPerimeterName = $nsp.Name  
        Direction = 'Inbound'  
        AddressPrefix = '192.0.2.0/24' 
        }

New-AzNetworkSecurityPerimeterAccessRule @inboundrule | format-list

# Update the inbound access rule to add more public IP address prefixes
    $updateInboundRule = @{ 
        Name = $inboundrule.Name 
        ProfileName = $nspprofile.Name  
        ResourceGroupName = $rgParams.Name  
        SecurityPerimeterName = $nsp.Name  
        AddressPrefix = @('192.0.2.0/24','198.51.100.0/24')
        }
    Update-AzNetworkSecurityPerimeterAccessRule @updateInboundRule | format-list
	
###END OF SCRIPT###
