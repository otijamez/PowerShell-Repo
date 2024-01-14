#create resource group
$rgname = Read-Host 'Enter Resource group name'
$location = Read-Host 'Enter location' 
New-AzResourceGroup -Name $rgname -Location $location



#Create a security rule
$nsgrule1 = New-AzNetworkSecurityRuleConfig -Name 'rdp-rule' -Description 'allow-RDP' -Protocol Tcp `
-SourcePortRange * -DestinationPortRange 3389 -SourceAddressPrefix internet -DestinationAddressPrefix * `
-Priority 100 -Direction Inbound -Access Allow

#create nsg and set the rule
$nsg = New-AzNetworkSecurityGroup -Name 'example-nsg' -ResourceGroupName $rgname -Location $location `
-SecurityRules $nsgrule1

#add a new security rule to an existing nsg
Add-AzNetworkSecurityRuleConfig -Name web-rule -Description 'allow-http' -Access Allow `
-NetworkSecurityGroup $nsg -Protocol Tcp -SourcePortRange * -DestinationPortRange 80 `
-SourceAddressPrefix internet -DestinationAddressPrefix * -Priority 105 -Direction Inbound
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg

#remove security rule
Get-AzNetworkSecurityRuleConfig -Name rdp-rule -NetworkSecurityGroup $nsg 

Remove-AzNetworkSecurityRuleConfig -Name rdp-rule -NetworkSecurityGroup $nsg
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg

#edit security rule
set-AzNetworkSecurityRuleConfig -Name web-rule -Description 'deny-http' -Access Deny `
-NetworkSecurityGroup $nsg -Protocol Tcp -SourcePortRange * -DestinationPortRange 8080 `
-SourceAddressPrefix internet -DestinationAddressPrefix * -Priority 105 -Direction Inbound
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg

#Create virtual network with three subnets
$serversub = New-AzVirtualNetworkSubnetConfig -Name seversubnet -AddressPrefix "192.168.1.0/24"
$clientsub = New-AzVirtualNetworkSubnetConfig -Name clientsubnet -AddressPrefix "192.168.2.0/24"
$dcsub = New-AzVirtualNetworkSubnetConfig -Name dcsub -AddressPrefix "192.168.3.0/24"
$vnet1 = New-AzVirtualNetwork -Name vnet1 -ResourceGroupName $rgname -Location $location `
-AddressPrefix "192.168.0.0/16" -Subnet $serversub, $clientsub, $dcsub


#attach nsg to the server subnet
$vnet = Get-AzVirtualNetwork -Name vnet1 -ResourceGroupName $rgname
$subnet = Get-AzVirtualNetworkSubnetConfig -Name seversubnet -VirtualNetwork $vnet
$subnet.NetworkSecurityGroup = $nsg 
Set-AzVirtualNetwork -VirtualNetwork $vnet

#detach nsg from subnet
$subnet.NetworkSecurityGroup = $null
Set-AzVirtualNetwork -VirtualNetwork $vnet

#Create PIP and NIC
$pip = New-AzPublicIpAddress -Name "examplePIP" -ResourceGroupName $rgname -Location $location `
-AllocationMethod Static

$nic = New-AzNetworkInterface -Name "exampleNIC" -ResourceGroupName $rgname `
-Location $location -SubnetId $vnet1.Subnets[0].Id -PublicIpAddressId $pip.id `
-PrivateIpAddress "192.168.1.7"


#attach nsg to nic
$nic.NetworkSecurityGroup = $nsg
Set-AzNetworkInterface -NetworkInterface $nic
