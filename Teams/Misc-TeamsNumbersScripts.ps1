Install-Module –Name MicrosoftTeams
Import-Module MicrosoftTeams -Force
Connect-MicrosoftTeams

# Add # to User/Resource Group
Set-CsPhoneNumberAssignment -Identity User@example.com -PhoneNumber +2787159**** -PhoneNumberType DirectRouting
Set-CsPhoneNumberAssignment -Identity User@example.com -EnterpriseVoiceEnabled $true

# Get all assigned users:
Get-CsOnlineUser | Where-Object { $_.LineURI -notlike $null } | Sort-Object LineURI | Select-Object DisplayName,UserPrincipalName,LineURI