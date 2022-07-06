Connect-MsolService
  
$users = Get-Content -Path 'C:\Temp\users.txt'
foreach ($user in $users)
{
    $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
    $st.RelyingParty = "*"
    $st.State = "Enabled"
    $sta = @($st)
    Set-MsolUser -UserPrincipalName $user -StrongAuthenticationRequirements $sta
}
Write-Host "DONE RUNNING SCRIPT"
  
Read-Host -Prompt "Press Enter to exit"