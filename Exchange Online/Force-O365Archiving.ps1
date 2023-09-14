# Script requires a UserPrincipalName parameter
param(
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName
)

# Script requires the ExchangeOnlineManagement module, and prompts to install if not present
if (!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    $confirm = Read-Host "Exchange Online PowerShell module not found. Install now? (y/n)"
    if ($confirm -eq 'y') {
        Install-Module -Name ExchangeOnlineManagement -Force
    }
    else {
        throw "This script requires Exchange Online PowerShell module. Please install it and try again."
    }
}

# Import the installed module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline

# Check if Archive is enabled for the given UserPrincipalName
$Mailbox = Get-Mailbox -Identity $UserPrincipalName

if(!$Mailbox.ArchiveStatus -eq 'Active') {
    # Enable the Archive if not already enabled
    Enable-Mailbox $UserPrincipalName -Archive
    Write-Host "Archive enabled for $UserPrincipalName"
} else {
    Write-Host "Archive already active for $UserPrincipalName"
}

# Get the mailbox GUID
$MailboxGuid = $Mailbox.ExchangeGuid

# Run the Start-ManagedFolderAssistant cmdlet with the GUID parameter
Start-ManagedFolderAssistant -Identity $MailboxGuid

Get-PSSession | Remove-PSSession

# Get-Mailbox -identity EmailAddress | Get-MailboxStatistics | Select-Object Displayname, TotalItemSize, MailboxGuid
