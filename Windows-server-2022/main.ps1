$locate = 'eastus'
$rgroup10 = New-AzResourceGroup -Name RG10 -Location $locate

$storeACCt = New-AzStorageAccount -ResourceGroupName rg10 -Name 'storagename7845884' -SkuName Standard_LRS -Location $locate -AccessTier Hot

$subnet10 = New-AzVirtualNetworkSubnetConfig -Name subnet55 -AddressPrefix 10.0.1.0/24 
$subnet20 = New-AzVirtualNetworkSubnetConfig -Name subnet20 -AddressPrefix 10.0.2.0/24

$vnet10 = New-AzVirtualNetwork -Name vnet10 -ResourceGroupName rg10 -Location $locate -AddressPrefix 10.0.0.0/16 -Subnet $subnet10,$subnet20 

$PubIP = New-AzPublicIpAddress -Name 'pip10' -ResourceGroupName rg10 -Location $locate -Sku Basic -AllocationMethod Static -DomainNameLabel 'dnl-vm10'

$NIC55 = New-AzNetworkInterface -Name nic10 -ResourceGroupName rg10 -Location $locate -SubnetId $vnet10.Subnets[0].id -PublicIpAddressId $PubIP.Id `
-PrivateIpAddress 10.0.1.4

$VMname = 'vm10'
$VMsize = 'Standard_Ds1_v2'

$VMConfig = New-AzVMConfig -VMName $VMname -VMSize $VMsize 

$credents = Get-Credential -Message 'Please enter your name and password'

$publisher = 'MicrosoftWindowsServer'
$offer = 'WindowsServer'	
$sku = '2022-Datacenter'
$osdiskname = 'osdisk'

$osdisk = Set-AzVMOperatingSystem -VM $VMConfig -Windows -ComputerName $VMname -Credential $credents -ProvisionVMAgent -EnableAutoUpdate

$vmimage = Set-AzVMSourceImage -VM $VMConfig -PublisherName $publisher -Offer $offer -Skus $sku -Version 'latest'

$osdiskURI = $storeACCt.PrimaryEndpoints.Blob.ToString() + 'vhdsblob/' + $osdiskname + '.vhd'

Add-AzVMNetworkInterface -VM $VMConfig -Id $NIC55.Id

Set-AzVMOSDisk -VM $VMConfig -Name $osdiskname -VhdUri $osdiskURI -CreateOption 'fromimage' 

$vm10 = New-AzVM -ResourceGroupName rg10 -Location $locate -VM $VMConfig 
 
