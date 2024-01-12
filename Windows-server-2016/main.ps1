$locate = 'eastus'
$rgroup = New-AzResourceGroup -Name RG-01 -Location $locate

$storeacct = New-AzStorageAccount -ResourceGroupName RG-01 -Name 'storagenew544810' -SkuName Standard_LRS -Location $locate -AccessTier Hot

$subnet10 = New-AzVirtualNetworkSubnetConfig -Name subnet1 -AddressPrefix 192.168.20.0/24 
$subnet20 = New-AzVirtualNetworkSubnetConfig -Name subnet2 -AddressPrefix 192.168.30.0/24

$vnet = New-AzVirtualNetwork -Name VNET -ResourceGroupName RG-01 -Location $locate -AddressPrefix 192.168.0.0/16 -Subnet $subnet10,$subnet20 

$PubIP = New-AzPublicIpAddress -Name 'PIP' -ResourceGroupName RG-01 -Location $locate -Sku Basic -AllocationMethod Static

$NICard = New-AzNetworkInterface -Name NIC -ResourceGroupName RG-01 -Location $locate -SubnetId $vnet.Subnets[0].id -PublicIpAddressId $PubIP.Id `
-PrivateIpAddress 192.168.20.4

$VMname = 'VM-01'
$VMsize = 'Standard_Ds1_v2'

$VMConfig = New-AzVMConfig -VMName $VMname -VMSize $VMsize 

$credents = Get-Credential -Message 'Please enter your name and password'

$publisher = 'MicrosoftWindowsServer'
$offer = 'WindowsServer'	
$sku = '2016-Datacenter'
$osdiskname = 'osdisk'

$osdisk = Set-AzVMOperatingSystem -VM $VMConfig -Windows -ComputerName $VMname -Credential $credents -ProvisionVMAgent -EnableAutoUpdate

$vmimage = Set-AzVMSourceImage -VM $VMConfig -PublisherName $publisher -Offer $offer -Skus $sku -Version 'latest'

$osdiskURI = $storeacct.PrimaryEndpoints.Blob.ToString() + 'vhdsblob/' + $osdiskname + '.vhd'

Add-AzVMNetworkInterface -VM $VMConfig -Id $NICard.Id

Set-AzVMOSDisk -VM $VMConfig -Name $osdiskname -VhdUri $osdiskURI -CreateOption 'fromimage'

$vm10 = New-AzVM -ResourceGroupName RG-01 -Location $locate -VM $VMConfig 
 
