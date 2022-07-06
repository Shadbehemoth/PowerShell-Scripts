Get-ExoMailbox -ResultSize Unlimited | 
Select-Object -ExpandProperty UserPrincipalName | 
Foreach-Object { Get-InboxRule -Mailbox $_ | 
	Select-Object -Property MailboxOwnerID, Name, Enabled, From, Description, RedirectTo, MoveToFolder, ForwardTo |
	ForEach-Object {
		$_.MailboxOwnerID = [regex]::Replace($_.MailboxOwnerID, "(`n|`r|`t)+", " ", "Multiline");
		$_.Name = [regex]::Replace($_.Name, "(`n|`r|`t)+", " ", "Multiline");
		$_.Enabled = [regex]::Replace($_.Enabled, "(`n|`r|`t)+", " ", "Multiline");
		$_.From = [regex]::Replace($_.From, "(`n|`r|`t)+", " ", "Multiline");
		$_.Description = [regex]::Replace($_.Description, "(`n|`r|`t)+", " ", "Multiline");
		$_.RedirectTo = [regex]::Replace($_.RedirectTo, "(`n|`r|`t)+", " ", "Multiline");
		$_.MoveToFolder = [regex]::Replace($_.MoveToFolder, "(`n|`r|`t)+", " ", "Multiline");
		$_.ForwardTo = [regex]::Replace($_.ForwardTo, "(`n|`r|`t)+", " ", "Multiline");
		return $_;
	} } | Export-CSV "C:\Temp\Mail_Rules.csv" -NoTypeInformation -Encoding UTF8