Connect-MicrosoftTeams

Get-CsOnlineUser | 
Where-Object { $_.LineURI -notlike $null } | 
Sort-Object LineURI | 
Select-Object DisplayName,UserPrincipalName,LineURI
