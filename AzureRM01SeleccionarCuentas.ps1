#Con ARM.... la nueva versión de máquinas virtuales
$MiNN            = "32"                    #Número a cambiar para crear varias máquinas virtuales
$MiDNS           = "40.127.177.225"        #Dirección IP del servidor DNS de la organización que quieres que utilicen las máquinas
#=============================================
$Migr            = "gr$MiNN"               #Grupo de recursos
$MiRed           = "red$MiNN"              #Nombre de red
$MiSubred        = "misubred$MiNN"         #Nombre de la subred
$MiRangoIP       = "10.4.1$MiNN.0/24"      #Rango de direcciones subrede
$MiLoc           = "North Europe"          #Localización de todos los recursos. Podría ser también "East US" o ....
$MiAlmacen       = "almacensri$MiNN"       #Nombre del almacenamiento 
$MiVMSize        = "Basic_A1"              #Tamaño de la máquina virtual
#=============================================
$MiMVws          = "ws2015$MiNN"           #WINDOWS. Nombre de la máquina virtual
$MiIpPrivws      = "10.4.1$MiNN.101"       #WINDOWS. Dirección IP privada estática
$MiIPws          = "IPws$MiNN"             #WINDOWS. Nombre de la Dirección IP pública estática 
$MiNICws         = "NICws$MiNN"            #WINDOWS. Tarjeta de red
$MiGSws          = "GS_ws$MiNN"            #WINDOWS. Grupo de seguridad. Se definirar las reglas de entrada y salida del tráfico
#=============================================
$MiMVus          = "us2015$MiNN"           #UBUNTU.  Nombre de la máquina virtual
$MiIpPrivus      = "10.4.1$MiNN.100"       #UBUNTU.  Dirección IP privada estática
$MiIPus          = "IPus$MiNN"             #UBUNTU.  Nombre de la Dirección IP pública estática
$MiNICus         = "NICus$MiNN"            #UBUNTU.  Tarjeta de red
$MiGSus          = "GS_us$MiNN"            #UBUNTU.  Grupo de seguridad. Se definiran las reglas de entrada y salida del tráfico
#=============================================
#Añadir Grupo de Recursos
$GrupoRecursos   = New-AzureRmResourceGroup    -Location $MiLoc -Name $Migr
#$GrupoRecursos   = Get-AzureRmResourceGroup -Name $Migr

#Añadir Cuenta de almacenamiento
$CuentaAlmacen   = New-AzureRmStorageAccount   -Location $MiLoc -Name $MiAlmacen -Type Standard_LRS -ResourceGroupName $Migr

#Añadir Red y Subred
$SubRed          = New-AzureRmVirtualNetworkSubnetConfig        -Name $MiSubred  -AddressPrefix  $MiRangoIP
$RedVirtual      = New-AzureRmVirtualNetwork   -Location $MiLoc -Name $MiRed     -AddressPrefix "10.0.0.0/8" -DnsServer $MiDNS -Subnet $SubRed -ResourceGroupName $Migr
#===========================
#WINDOWS. Añadir Grupo de seguridad
                   New-AzureRmNetworkSecurityGroup -Location $MiLoc -Name $MiGSws -ResourceGroupName $Migr 
                   Get-AzureRmNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr | Add-AzureRmNetworkSecurityRuleConfig -Name "BloquearTodoTcp"   -Direction Inbound  -Priority 400 -Access Deny  -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange *    -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   #Get-AzureRMNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr | Set-AzureRmNetworkSecurityRuleConfig -Name "BloquearTodoTcp"   -Direction Inbound  -Priority 400 -Access Deny  -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange *    -Protocol UDP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr | Add-AzurermNetworkSecurityRuleConfig -Name "allow-rdp-in"      -Direction Inbound  -Priority 100 -Access Allow -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange 3389 -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr | Add-AzureRmNetworkSecurityRuleConfig -Name "allow-rdp-out"     -Direction Outbound -Priority 100 -Access Allow -SourceAddressPrefix * -SourcePortRange 3389 -DestinationAddressPrefix * -DestinationPortRange *    -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr | Add-AzurermNetworkSecurityRuleConfig -Name "allow-http-in"     -Direction Inbound  -Priority 101 -Access Allow -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange 80   -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr | Add-AzureRmNetworkSecurityRuleConfig -Name "allow-http-out"    -Direction Outbound -Priority 101 -Access Allow -SourceAddressPrefix * -SourcePortRange 80   -DestinationAddressPrefix * -DestinationPortRange *    -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr | Add-AzurermNetworkSecurityRuleConfig -Name "allow-https-in"    -Direction Inbound  -Priority 102 -Access Allow -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange 443  -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr | Add-AzureRmNetworkSecurityRuleConfig -Name "allow-https-out"   -Direction Outbound -Priority 102 -Access Allow -SourceAddressPrefix * -SourcePortRange 443  -DestinationAddressPrefix * -DestinationPortRange *    -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr | Add-AzurermNetworkSecurityRuleConfig -Name "allow-dns-in"      -Direction Inbound  -Priority 103 -Access Allow -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange 53  -Protocol * | Set-AzureRmNetworkSecurityGroup
#                   Get-AzureRMNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr | Add-AzureRmNetworkSecurityRuleConfig -Name "allow-dns-out"     -Direction Outbound -Priority 103 -Access Allow -SourceAddressPrefix * -SourcePortRange 53  -DestinationAddressPrefix * -DestinationPortRange *    -Protocol * | Set-AzureRmNetworkSecurityGroup
$GrupoSeg_ws     = Get-AzureRmNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr

#===========================
#WINDOWS. Creación de la máquina virtual
$imagePublisher  = "MicrosoftWindowsServer"
$imageOffer      = "WindowsServer"
$VersionOSSku    = "2012-R2-Datacenter"

$pipws           = New-AzureRmPublicIpAddress  -Location $MiLoc -Name $MiIPws  -AllocationMethod static -ResourceGroupName $Migr -DomainNameLabel $MiMVws
$nicws           = New-AzureRmNetworkInterface -Location $MiLoc -Name $MiNICws -SubnetId $RedVirtual.Subnets[0].Id -PublicIpAddressId $pipws.Id -PrivateIpAddress $MiIpPrivws  -ResourceGroupName $Migr -NetworkSecurityGroupId $GrupoSeg_ws.Id

$cred            = Get-Credential     -Message "Introduce el nombre del usuario y la contraseña"
$vm              = New-AzureRmVMConfig -VMName $MiMVws -VMSize $MiVMSize   
$vm              = Set-AzureRmVMOperatingSystem  -VM $vm -Windows -ComputerName $MiMVws -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm              = Set-AzureRmVMSourceImage      -VM $vm -PublisherName $imagePublisher -Offer $imageOffer -Skus $VersionOSSku -Version "latest"
$vm              = Add-AzureRmVMNetworkInterface -VM $vm -Id $nicws.Id
$osDiskUri       = $CuentaAlmacen.PrimaryEndpoints.Blob.ToString() + "vhds/$MiMVws.vhd"
$vm              = Set-AzureRmVMOSDisk -VM $vm -Name $MiMVws -VhdUri $osDiskUri -CreateOption fromImage
                   New-AzureRmVM -ResourceGroupName $Migr       -Location $MiLoc -VM $vm

#===========================
#UBUNTU.  Añadir Grupo de seguridad
                   New-AzureRmNetworkSecurityGroup -Location $MiLoc -Name $MiGSus -ResourceGroupName $Migr 
                   Get-AzureRmNetworkSecurityGroup -Name $MiGSus -ResourceGroupName $Migr | Add-AzureRmNetworkSecurityRuleConfig -Name "BloquearTodoTcp"   -Direction Inbound  -Priority 400 -Access Deny  -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange *    -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   #Get-AzureRMNetworkSecurityGroup -Name $MiGSus -ResourceGroupName $Migr | Set-AzureRmNetworkSecurityRuleConfig -Name "BloquearTodoTcp"   -Direction Inbound  -Priority 400 -Access Deny  -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange *    -Protocol UDP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSus -ResourceGroupName $Migr | Add-AzurermNetworkSecurityRuleConfig -Name "allow-ssh-in"      -Direction Inbound  -Priority 100 -Access Allow -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange 22   -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSus -ResourceGroupName $Migr | Add-AzureRmNetworkSecurityRuleConfig -Name "allow-ssh-out"     -Direction Outbound -Priority 100 -Access Allow -SourceAddressPrefix * -SourcePortRange 22   -DestinationAddressPrefix * -DestinationPortRange *    -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSus -ResourceGroupName $Migr | Add-AzurermNetworkSecurityRuleConfig -Name "allow-http-in"     -Direction Inbound  -Priority 101 -Access Allow -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange 80   -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSus -ResourceGroupName $Migr | Add-AzureRmNetworkSecurityRuleConfig -Name "allow-http-out"    -Direction Outbound -Priority 101 -Access Allow -SourceAddressPrefix * -SourcePortRange 80   -DestinationAddressPrefix * -DestinationPortRange *    -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSus -ResourceGroupName $Migr | Add-AzurermNetworkSecurityRuleConfig -Name "allow-https-in"    -Direction Inbound  -Priority 102 -Access Allow -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange 443  -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSus -ResourceGroupName $Migr | Add-AzureRmNetworkSecurityRuleConfig -Name "allow-https-out"   -Direction Outbound -Priority 102 -Access Allow -SourceAddressPrefix * -SourcePortRange 443  -DestinationAddressPrefix * -DestinationPortRange *    -Protocol TCP | Set-AzureRmNetworkSecurityGroup
                   Get-AzureRMNetworkSecurityGroup -Name $MiGSus -ResourceGroupName $Migr | Add-AzurermNetworkSecurityRuleConfig -Name "allow-dns-in"      -Direction Inbound  -Priority 103 -Access Allow -SourceAddressPrefix * -SourcePortRange *    -DestinationAddressPrefix * -DestinationPortRange 53  -Protocol * | Set-AzureRmNetworkSecurityGroup
#                   Get-AzureRMNetworkSecurityGroup -Name $MiGSws -ResourceGroupName $Migr | Add-AzureRmNetworkSecurityRuleConfig -Name "allow-dns-out"     -Direction Outbound -Priority 103 -Access Allow -SourceAddressPrefix * -SourcePortRange 53  -DestinationAddressPrefix * -DestinationPortRange *    -Protocol * | Set-AzureRmNetworkSecurityGroup
$GrupoSeg_us     = Get-AzureRmNetworkSecurityGroup -Name $MiGSus -ResourceGroupName $Migr

#UBUNTU.  Creación de la máquina virtual
$imagePublisher  = "Canonical"
$imageOffer      = "UbuntuServer"
$VersionOSSku    = "14.04.3-LTS"

$pipus           = New-AzureRmPublicIpAddress  -Location $MiLoc -Name  $MiIPus  -AllocationMethod static -ResourceGroupName $Migr -DomainNameLabel $MiMVus
$nicus           = New-AzureRmNetworkInterface -Location $MiLoc -Name  $MiNICus -SubnetId $RedVirtual.Subnets[0].Id -PublicIpAddressId $pipus.Id -PrivateIpAddress $MiIpPrivus  -ResourceGroupName $Migr -NetworkSecurityGroupId $GrupoSeg_us.ID

$cred            = Get-Credential     -Message "Introduce el nombre del usuario y la contraseña"
$vm              = New-AzureRmVMConfig -VMName $MiMVus -VMSize $MiVMSize   
$vm              = Set-AzureRmVMOperatingSystem  -VM $vm -linux -ComputerName $MiMVus -Credential $cred  
$vm              = Set-AzureRmVMSourceImage      -VM $vm -PublisherName $imagePublisher -Offer $imageOffer -Skus $VersionOSSku -Version "latest"
$vm              = Add-AzureRmVMNetworkInterface -VM $vm -Id $nicus.Id
$osDiskUri       = $CuentaAlmacen.PrimaryEndpoints.Blob.ToString() + "vhds/$MiMVus.vhd"
$vm              = Set-AzureRmVMOSDisk -VM $vm -Name $MiMVus -VhdUri $osDiskUri -CreateOption fromImage
                   New-AzureRmVM -ResourceGroupName $Migr       -Location $MiLoc -VM $vm
