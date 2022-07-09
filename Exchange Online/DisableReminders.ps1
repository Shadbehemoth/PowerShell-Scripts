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

Set-MailboxCalendarConfiguration -Identity $Identity -RemindersEnabled $false

#Clean up session
Get-PSSession | Remove-PSSession