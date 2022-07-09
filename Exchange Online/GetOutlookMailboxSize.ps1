connect-exchangeonline

#  One User
Get-Mailbox -identity EMAIL | Get-MailboxStatistics | Select-Object Displayname, TotalItemSize, MailboxGuid


#  All users
foreach ($UPN in Get-ExoMailbox -ResultSize Unlimited | Select-Object -ExpandProperty UserPrincipalName)
{
    Get-MailboxStatistics -identity $UPN |
    Select-Object Displayname, UserPrincipalName, TotalItemSize, MailboxGuid | 
    ForEach-Object {
		$_.UserPrincipalName = $UPN;
		return $_;
	}
}  | Export-CSV "C:\Temp\Mailbox_Sizes.csv" -NoTypeInformation -Encoding UTF8


#  ProhibitSendReceiveQuota
Get-Mailbox -identity EMAIL | Select-Object Displayname, ProhibitSendQuota, ProhibitSendReceiveQuota

#  One User's Archive
Get-Mailbox -identity EMAIL -Archive | Select-Object-Object DisplayName, TotalItemSize, ItemCount


#  Mailbox size of certain domains
foreach ($UPN in Get-ExoMailbox -ResultSize Unlimited | Where-Object {$_.emailAddresses -like "*@DOMAIN" } | Select-Object -ExpandProperty UserPrincipalName)
{
    Get-MailboxStatistics -identity $UPN |
    Select-Object Displayname, UserPrincipalName, TotalItemSize, MailboxGuid | 
    ForEach-Object {
		$_.UserPrincipalName = $UPN;
		return $_;
	}
}  | Export-CSV "C:\Mail_Rules.csv" -NoTypeInformation -Encoding UTF8
