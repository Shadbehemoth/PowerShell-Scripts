Get-MsolUser -All | 
Where-Object {$_.UserPrincipalName} | 
Select-Object UserPrincipalName, DisplayName, `
@{n=”Status”; e={$_.StrongAuthenticationRequirements.State}}, `
@{n=”Methods”; e={($_.StrongAuthenticationMethods).MethodType}}, `
@{n=”Chosen Method”; e={($_.StrongAuthenticationMethods).IsDefault}} | 
Out-GridView