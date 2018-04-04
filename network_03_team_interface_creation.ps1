Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# Network Teams
$Team1_Name = "HV_TRUNK"

# Create Team Interfaces
Add-NetLbfoTeamNic -Team $Team1_Name -vLanID 431 -Name "HV_TRUNK - LM-HB"  -Confirm:$False
Add-NetLbfoTeamNic -Team $Team1_Name -vLanID 432 -Name "HV_TRUNK - CSV"  -Confirm:$False
Add-NetLbfoTeamNic -Team $Team1_Name -vLanID 433 -Name "HV_TRUNK - VLAN 433"  -Confirm:$False