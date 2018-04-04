Set-ExecutionPolicy -ExecutionPolicy Unrestricted

$NIC1 = "HV_MGMT_01"
$NIC2 = "HV_MGMT_02"

#name your Teams
$Team1_Name = "HV_TRUNK"
$Team1_Nic_Primary = "HV_TRUNK - VLAN 433"

#Create Active/Active Teams
New-NetLbfoTeam $Team1_Name.ToString() $NIC1,$NIC2  -Confirm:$False

# Rename Default Team Nic
Get-NetAdapter -Name $Team1_Name | Rename-NetAdapter -NewName $Team1_Nic_Primary

# Set VLAN ID
Set-NetLbfoTeamNic -Name $Team1_Nic_Primary -VlanID 433
