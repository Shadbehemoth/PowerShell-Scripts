[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $Identity
)

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

$ArchiveNotEnabled = Get-Mailbox -Filter `
{ ArchiveGuid -Eq "00000000-0000-0000-0000-000000000000" `
        -AND RecipientTypeDetails -Eq "UserMailbox" `
        -AND UserPrincipalName -Eq $Identity } | 
Measure-Object

if ($ArchiveNotEnabled.count -eq 1) {
    Enable-Mailbox -Identity $Identity -Archive
    Start-Sleep 60
    get-mailboxLocation -user $Identity | 
    Where-Object { $_.mailboxLocationType -eq "Primary" } | 
    Select-Object mailboxGuid | 
    Start-ManagedFolderAssistant
    Write-Host "Archive enabled"
} else {
    get-mailboxLocation -user $Identity | 
    Where-Object { $_.mailboxLocationType -eq "Primary" } | 
    Select-Object mailboxGuid | 
    Start-ManagedFolderAssistant
    Write-Host "Archive already enabled"
}

Get-PSSession | Remove-PSSession

# Get-Mailbox -identity EmailAddress | Get-MailboxStatistics | Select-Object Displayname, TotalItemSize, MailboxGuid
