Remove-Item "C:\Temp\Mailbox_Sizes.csv"
foreach ($UPN in Get-ExoMailbox -ResultSize Unlimited | Select-Object -ExpandProperty UserPrincipalName)
{
    Get-MailboxStatistics -identity $UPN |
    Select-Object Displayname, UserPrincipalName, TotalItemSize | 
    ForEach-Object {
		$_.UserPrincipalName = $UPN;
		return $_;
	} | Export-CSV "C:\Temp\Mailbox_Sizes.csv" -NoTypeInformation -Encoding UTF8 -Append
} 

Get-Mailbox | Get-MailboxStatistics | Select-Object Displayname, TotalItemSize