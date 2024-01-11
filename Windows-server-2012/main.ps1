$location = 'eastus'
$resourcegroup = 'RG-1'
New-AzResourceGroup -Name $resourcegroup -Location $location 

$Storageacct = New-AzStorageAccount `
  -ResourceGroupName $resourcegroup `
  -Name 'storagename6656201' `
  -Location $location `
  -SkuName Standard_LRS 

$subnetname1 = 'subnet1'
$subnetname2 = 'subnet2'

$subnet1 = New-AzVirtualNetworkSubnetConfig -Name $subnetname1 -AddressPrefix 172.16.10.0/24
$subnet2 = New-AzVirtualNetworkSubnetConfig -Name $subnetname2 -AddressPrefix 172.16.20.0/24

$VNET = New-AzVirtualNetwork `
  -Name 'VNET' `
  -ResourceGroupName $resourcegroup `
  -Location $location `
  -AddressPrefix 172.16.0.0/16 `
  -Subnet $subnet1,$subnet2

$PIP = New-AzPublicIpAddress `
  -Name 'PIP' `
  -ResourceGroupName $resourcegroup `
  -Location $location `
  -Sku Basic `
  -AllocationMethod Static

$NIC = New-AzNetworkInterface `
  -Name 'NIC' `
  -ResourceGroupName $resourcegroup `
  -Location $location `
  -SubnetId $VNET.Subnets[1].id `
  -PublicIpAddressId $PIP.Id `
  -PrivateIpAddress 172.16.20.4

#VM CONFIGURATION VARIABLES
$VMName = 'AdminVM'
$VMSize = 'Standard_DS1_v2'
$VMConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize

#SPECIFY WINDOWS SERVER 2012 R2 DATACENTER IMAGE
$publisher = 'MicrosoftWindowsServer'
$offer = 'WindowsServer'
$sku = '2012-R2-Datacenter'
$diskName = 'ADMINVMOSDisk'

#PROMPT CREDENTIALS
$Credential = Get-Credential `
  -Message 'PLEASE ENTER USERNAME AND PASSWORD'

#ASSIGN THE O.S TO THE VM COMFIGURATION
$VMConfig = Set-AzVMOperatingSystem `
  -VM $VMConfig `
  -Windows `
  -ComputerName $VMName `
  -Credential $Credential `
  -ProvisionVMAgent `
  -EnableAutoUpdate `

#ASSIGN THE GALLERY IMAGE TO THE VM CONFIGURATION
$VMConfig = Set-AzVMSourceImage `
  -VM $VMConfig `
  -PublisherName $publisher `
  -Offer $offer `
  -Skus $sku `
  -Version 'latest'

#ASSIGN THE NIC TO THE VM CONFIGURATION
$VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -Id $NIC.Id

#CREATE THE URL TO STORE THE OS DISK VHD
$OSDiskurl = $Storageacct.PrimaryEndpoints.Blob.ToString()+"vhds/"+$diskName+".vhd"

#ASSIGN THE OS DISK NAME AND LOCATION TO THHE VM CONFIGURATION
$VMConfig = Set-AzVMOSDisk `
-VM $VMConfig -Name $diskName -VhdUri $OSDiskurl -CreateOption fromimage

#CREATE VIRTUAL MACHINE
New-AzVM -ResourceGroupName $resourcegroup -Location $location -VM $VMConfig 
