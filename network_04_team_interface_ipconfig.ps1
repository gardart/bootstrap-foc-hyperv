#
# Automatic NIC IP configuration
# Reads config from csv file containing information for NICs connected to the current host
# If the hostname matches the csv file then it configures all of the NICs for that host
# 
Import-Module NetAdapter

$NICs = Import-Csv "nic_config.csv" | Where-Object {$_.computername -eq $env:COMPUTERNAME -and ( $_.Name -like "HV_TRUNK -*" ) }

foreach ($NIC in $NICs) {
$NICAttributes = @{}
# Rename NIC and configure attributes
$NetAdapter = Get-NetAdapter | Where-Object {$_.Name -eq $NIC.Name}
$NetAdapter = $NetAdapter | Set-NetIPInterface -DHCP Disabled -PassThru
if ($NIC.AddressFamily) {
$NICAttributes.Add('AddressFamily',$NIC.AddressFamily)
}
if ($NIC.IPAddress) {
$NICAttributes.Add('IPAddress',$NIC.IPAddress)
}
if ($NIC.PrefixLength) {
$NICAttributes.Add('PrefixLength',$NIC.PrefixLength)
}
if ($NIC.DefaultGateway) {
$NICAttributes.Add('DefaultGateway',$NIC.DefaultGateway)
}
if ($NIC.IPAddress) {
$NetAdapter | New-NetIPAddress @NICAttributes
}

# Configuring DNS client server address
if ($NIC.DnsServerAddresses) {
Set-DnsClientServerAddress -InterfaceAlias $($NIC.Name) -ServerAddresses $NIC.DnsServerAddresses
}

# Remove unessesary bindings for LM NIC
if ($NIC.Name -eq "HV_TRUNK - LM-HB" -or $NIC.Name -eq "HV_TRUNK - CSV") {
    # Disable  Link-Layer Topology Discovery Responder
	Disable-NetAdapterBinding -Name $NIC.Name -ComponentID ms_rspndr
	# Disable Link-Layer Topology Discovery Mapper I/O Driver
	Disable-NetAdapterBinding -Name $NIC.Name -ComponentID ms_lltdio
	# Disable Dynamic DNS Registration and TcpipNetbios
	Get-WmiObject win32_networkadapterconfiguration | where { $_.ipaddress -like $NIC.IPAddress } | %{$_.SetDynamicDNSRegistration($false,$false) -and $_.SetTcpipNetbios(2)}
}

# Management Trunk - VLAN 433
if ($NIC.Name -eq "HV_TRUNK - VLAN 433") {
	# Disable Tcpip Netbios
	# Bilað
	Get-WmiObject win32_networkadapterconfiguration | where { $_.ipaddress -like $NIC.IPAddress } | %{$_.SetTcpipNetbios(2)}
}
# This has been moved to VMM (possible to clone that powershell command
# VM_TRUNK nic is now a virtual switch inside HyperV
# Remove unessesary bindings for VM Trunk Nic
#if ($NIC.Name -eq "HV_VM_Trunk") {

#	Get-NetAdapterBinding -Name $NIC.Name | ?{ $_.ComponentID -ne 'ms_lbfo'} | % {Disable-NetAdapterBinding -Name $_.Name -ComponentID $_.ComponentID} 
#}
#}
}
