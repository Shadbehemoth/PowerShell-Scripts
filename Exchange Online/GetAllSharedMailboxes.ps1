Get-Mailbox | 
Get-MailboxPermission -user $user | 
Where-Object {($_.AccessRights -eq "FullAccess") -and -not ($_.User -eq "NT AUTHORITY\SELF")} | 
Format-Table Identity,User