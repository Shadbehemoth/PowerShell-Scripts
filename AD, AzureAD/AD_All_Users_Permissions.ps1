Import-Module ActiveDirectory
$users = Get-ADUser -Filter * -Properties * 
$ErrorActionPreference = 'SilentlyContinue'
# Loop through each user
foreach ($user in $users) {
#Search in specified OU and Update existing attributes
	(Get-ACL "AD:$((Get-ADUser $user).distinguishedname)").access | Export-Csv -Path ("C:\User_Permissions\explicit_permissions_" + $user + ".csv") -NoTypeInformation
}
