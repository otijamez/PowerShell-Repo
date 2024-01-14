#create resource group
$rgname = Read-Host 'Enter Resource group name'
$location = Read-Host 'Enter location' 
New-AzResourceGroup -Name $rgname -Location $location

#Create a security rule
$nsgrule1 = New-AzNetworkSecurityRuleConfig -Name 'rdp-rule' -Description 'allow-RDP' -Protocol Tcp `
-SourcePortRange * -DestinationPortRange 3389 -SourceAddressPrefix internet -DestinationAddressPrefix * `
-Priority 100 -Direction Inbound -Access Allow

#create nsg and set the rule
$nsg = New-AzNetworkSecurityGroup -Name 'NSG' -ResourceGroupName $rgname -Location $location `
-SecurityRules $nsgrule1

#add a new security rule 
Add-AzNetworkSecurityRuleConfig -Name web-rule -Description 'allow-http' -Access Allow `
-NetworkSecurityGroup $nsg -Protocol Tcp -SourcePortRange * -DestinationPortRange 80 `
-SourceAddressPrefix internet -DestinationAddressPrefix * -Priority 200 -Direction Inbound

#Add new rule to the existing nsg
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg

#remove security rule
Get-AzNetworkSecurityRuleConfig -Name web-rule -NetworkSecurityGroup $nsg 

Remove-AzNetworkSecurityRuleConfig -Name web-rule -NetworkSecurityGroup $nsg
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg

#edit security rule
set-AzNetworkSecurityRuleConfig -Name rdp-rule -Description 'deny-rdp' -Access Deny `
-NetworkSecurityGroup $nsg -Protocol Tcp -SourcePortRange * -DestinationPortRange 3389 `
-SourceAddressPrefix internet -DestinationAddressPrefix * -Priority 150 -Direction Inbound
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg

#Create virtual network with three subnets
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name subnet1 -AddressPrefix "172.17.1.0/24"
$subnet2 = New-AzVirtualNetworkSubnetConfig -Name subnet2 -AddressPrefix "172.17.2.0/24"
$subnet3 = New-AzVirtualNetworkSubnetConfig -Name subnet3 -AddressPrefix "172.17.3.0/24"
$vnet = New-AzVirtualNetwork -Name VNET -ResourceGroupName $rgname -Location $location `
-AddressPrefix "172.17.0.0/16" -Subnet $subnet1, $subnet2, $subnet3


#attach nsg to the subnet1
$vnet = Get-AzVirtualNetwork -Name VNET -ResourceGroupName $rgname
$subnet = Get-AzVirtualNetworkSubnetConfig -Name subnet1 -VirtualNetwork $vnet
$subnet.NetworkSecurityGroup = $nsg 
Set-AzVirtualNetwork -VirtualNetwork $vnet

#detach NSG from subnet
$subnet.NetworkSecurityGroup = $null
Set-AzVirtualNetwork -VirtualNetwork $vnet

#Create PIP and NIC
$pip = New-AzPublicIpAddress -Name "PIP" -ResourceGroupName $rgname -Location $location `
-AllocationMethod Static

$nic = New-AzNetworkInterface -Name "NIC" -ResourceGroupName $rgname `
-Location $location -SubnetId $vnet.Subnets[0].id -PublicIpAddressId $pip.id `
-PrivateIpAddress "172.17.1.4"


#attach NSG to NIC
$nic.NetworkSecurityGroup = $nsg
Set-AzNetworkInterface -NetworkInterface $nic
