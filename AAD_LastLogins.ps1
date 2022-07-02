Connect-MsolService 
Connect-AzureAD 

$Users = Get-MsolUser -all
"DisplayName`tUserPrincipalName`tLicense`tLastLogon" >> C:\list.csv
ForEach ($User in $Users)
    {
    $UPN = $User.UserPrincipalName
    $LoginTime = Get-AzureAdAuditSigninLogs -top 1 -filter "userprincipalname eq '$UPN'" | Select-Object CreatedDateTime
    $NewLine = $User.DisplayName + "`t" + $User.UserPrincipalName + "`t" + $User.Licenses.AccountSkuId + "`t" + $LoginTime.CreatedDateTime
    $NewLine >>'C:\list.csv'
    }