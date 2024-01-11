#VARIABLES
$location = 'eastus'
$resourceGroup = "RG-1"
$subname = 'subnet1'
$subname2 = 'subnet2'

#RESOURCEGROUP
New-AzResourceGroup -Name $resourceGroup -Location $location 

#SUBNETS
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name $subname -AddressPrefix 172.16.20.0/24
$subnet2 = New-AzVirtualNetworkSubnetConfig -Name $subname2 -AddressPrefix 172.16.30.0/24

#VIRTUAL NETWORK
$VNET = New-AzVirtualNetwork -Name VNET -ResourceGroupName $resourceGroup -Location $location -AddressPrefix 172.16.0.0/16 -Subnet $subnet1,$subnet2

#PUBLIC IP
$newpip = New-AzPublicIpAddress -Name PIP -ResourceGroupName $resourceGroup -Location $location -AllocationMethod Static

#NETWORK INTERFACE
$nic = New-AzNetworkInterface -Name NIC -ResourceGroupName $resourceGroup -Location $location -SubnetId $VNET.Subnets[0].id -PublicIpAddressId $newpip.Id
