$locate = 'eastus'
$rgroup10 = New-AzResourceGroup -Name RG10 -Location $locate

$storeACCt = New-AzStorageAccount -ResourceGroupName rg10 -Name 'storagenames7854122' -SkuName Standard_LRS -Location $locate -AccessTier Hot

$subnet10 = New-AzVirtualNetworkSubnetConfig -Name subnet55 -AddressPrefix 172.16.20.0/24 
$subnet20 = New-AzVirtualNetworkSubnetConfig -Name subnet20 -AddressPrefix 172.16.30.0/24

$vnet10 = New-AzVirtualNetwork -Name vnet -ResourceGroupName rg10 -Location $locate -AddressPrefix 172.16.0.0/16 -Subnet $subnet10,$subnet20 

$PubIP = New-AzPublicIpAddress -Name 'pip' -ResourceGroupName rg10 -Location $locate -Sku Basic -AllocationMethod Static -DomainNameLabel 'dnl-vm10'

$NIC55 = New-AzNetworkInterface -Name nic10 -ResourceGroupName rg10 -Location $locate -SubnetId $vnet10.Subnets[1].id -PublicIpAddressId $PubIP.Id `
-PrivateIpAddress 172.16.30.4

$VMname = 'win10'
$VMsize = 'Standard_Ds1_v2'

$VMConfig = New-AzVMConfig -VMName $VMname -VMSize $VMsize 

$credents = Get-Credential -Message 'Please enter your name and password'

$publisher = 'MicrosoftWindowsDesktop'
$offer = 'Windows-10'
$sku = '20h2-evd'
$osdiskname = 'osdisk'

$osdisk = Set-AzVMOperatingSystem -VM $VMConfig -Windows -ComputerName $VMname -Credential $credents -ProvisionVMAgent -EnableAutoUpdate

$vmimage = Set-AzVMSourceImage -VM $VMConfig -PublisherName $publisher -Offer $offer -Skus $sku -Version 'latest'

$osdiskURI = $storeACCt.PrimaryEndpoints.Blob.ToString() + 'vhdsblob/' + $osdiskname + '.vhd'

Add-AzVMNetworkInterface -VM $VMConfig -Id $NIC55.Id

Set-AzVMOSDisk -VM $VMConfig -Name $osdiskname -VhdUri $osdiskURI -CreateOption 'fromimage' 

$vm10 = New-AzVM -ResourceGroupName rg10 -Location $locate -VM $VMConfig 
 
