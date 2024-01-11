#VARIABLES
$resourceGroupname = "RG-1"
$location = "eastus"

#RESOURCEGROUP
New-AzResourceGroup -Name $resourceGroupname -Location $location

#CREATE VIRTUAL NETWORK
$vnet = New-AzVirtualNetwork -Name vnet -ResourceGroupName $resourceGroupname -Location $location -AddressPrefix 172.16.0.0/16

#SUBNETS 
$subnet01 = Add-AzVirtualNetworkSubnetConfig -Name subnet01 -VirtualNetwork $vnet -AddressPrefix 172.16.10.0/24
$subnet02 = Add-AzVirtualNetworkSubnetConfig -Name subnet02 -VirtualNetwork $vnet -AddressPrefix 172.16.20.0/24

#SET VIRTUAL NETWORK
$vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet 

#PUBLIC IP
$PIP = New-AzPublicIpAddress -Name 'PIP' -ResourceGroupName $resourceGroupname -Location $location -AllocationMethod Static 

#NETWORK INTERFACE
$NIC = New-AzNetworkInterface -Name 'NIC' -ResourceGroupName $resourceGroupname -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $PIP.id
