#
# Automatic Hyper-V NIC configuration
# Reads config from csv file containing information for NICs connected to the current host
# If the hostname matches the csv file then it configures all of the Hyper-V NICs for that host
# 
Import-Module NetAdapter

$NICs = Import-Csv "nic_config.csv" | Where-Object {$_.computername -eq $env:COMPUTERNAME -and $_.Name -like "HV_*"}

foreach ($NIC in $NICs) {
# Rename NIC and configure
if ($NIC.MAC) {
$NetAdapter = Get-NetAdapter | Where-Object {$_.MacAddress -eq $NIC.MAC}
$NetAdapter = $NetAdapter | Rename-NetAdapter -NewName $NIC.NAME -PassThru
$NetAdapter = $NetAdapter | Set-NetIPInterface -DHCP Disabled -PassThru
}
}