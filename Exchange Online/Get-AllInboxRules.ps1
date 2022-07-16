[CmdletBinding()]

#Check for ExchangeOnlineManagement module 
$Module = Get-Module ExchangeOnlineManagement -ListAvailable
if ($Module.count -eq 0) { 
	Write-Host Exchange Online PowerShell V2 module is not available  -ForegroundColor yellow  
	$Confirm = Read-Host Are you sure you want to install module? [Y] Yes [N] No 
	if ($Confirm -match "[yY]") { 
		Write-host "Installing Exchange Online PowerShell module"
		Install-Module ExchangeOnlineManagement -Repository PSGallery -AllowClobber -Force
	} 
	else { 
		Write-Host EXO V2 module is required to connect Exchange Online.Please install module using Install-Module ExchangeOnlineManagement cmdlet. 
		Exit
	}
} 
Connect-ExchangeOnline

$Documents = [environment]::getfolderpath("mydocuments")
mkdir "$Documents\Temp"

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
	} } | Export-CSV "$Documents\Temp\Mail_Rules.csv" -NoTypeInformation -Encoding UTF8



Get-PSSession | Remove-PSSession