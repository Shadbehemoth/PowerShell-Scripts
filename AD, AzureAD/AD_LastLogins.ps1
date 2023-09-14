Import-Module ActiveDirectory  

$DaysInactive = 60  
$Time = (Get-Date).Adddays(-($DaysInactive))  

$users = Get-ADUser -Filter {enabled -eq $true} -Properties LastLogon, LastLogonTimeStamp

foreach ($user in $users) {
    $lastLogon = 0
    if ($user.LastLogon -ne $null) {
        $lastLogon = $user.LastLogon
    }
    if ($user.LastLogonTimeStamp -ne $null) {
        if ($user.LastLogonTimeStamp -gt $lastLogon) {
            $lastLogon = $user.LastLogonTimeStamp
        }
    }
    $lastLogonDateTime = [DateTime]::FromFileTime($lastLogon)
    $daysSinceLastLogon = (Get-Date) - $lastLogonDateTime
    if ($lastLogon -eq 0 -or $daysSinceLastLogon.Days -gt $DaysInactive) {
        $user | 
        Select-Object Name, @{Name='LastLogon';Expression={$lastLogonDateTime}}, @{Name='DaysSinceLastLogon';Expression={$daysSinceLastLogon.Days}} |
        Export-Csv UserLastLogin.csv -Append
    }
}