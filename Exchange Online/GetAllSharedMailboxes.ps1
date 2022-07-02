Get-Mailbox | 
Get-MailboxPermission -user $user | 
Where {($_.AccessRights -eq "FullAccess") -and -not ($_.User -eq "NT AUTHORITY\SELF")} | 
Format-Table Identity,User