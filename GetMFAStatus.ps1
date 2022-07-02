Get-MsolUser -All | 
Where {$_.UserPrincipalName} | 
Select UserPrincipalName, DisplayName, @{n=”Status”; e={$_.StrongAuthenticationRequirements.State}}, @{n=”Methods”; e={($_.StrongAuthenticationMethods).MethodType}}, @{n=”Chosen Method”; e={($_.StrongAuthenticationMethods).IsDefault}} | 
Out-GridView