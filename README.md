This PowerShell script provisions the following resources:
#1 Provisions a dedicated resource group for the network security perimeter
#2 Provisions an Azure Key Vault. Since this is a lab, the key vault is deployed into the same resource group
#3 Provisions a network security perimeter
#4 Provisions one new network security perimeter PROFILE
#5 ASSOCIATES the PaaS resource to the network security perimeter PROFILE 
#6 UPDATES the access mode to ENFORCED
#7 CREATE and optional UPDATES network security perimeter access rules
