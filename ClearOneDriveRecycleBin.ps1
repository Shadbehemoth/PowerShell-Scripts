#Install Module
Install-Module -Name PnP.PowerShell
Import-Module -Name PnP.PowerShell
  
#Connect to OneDrive for Business Site (Replace my URL with the users URL)
Connect-PnPOnline -url https://XXXXX.sharepoint.com/personal/XXXXXXX -Interactive

#Empty the first and second stage recycle bins.
Clear-PnPRecycleBinItem -All -force

#Close sessions
Get-PSSession | Remove-PSSession


# Alternate:
#Set Parameters
$OneDriveSiteURL=https://primemeridiandirect-my.sharepoint.com/personal/UPN/
 
#Get Credentials to connect
$Cred = Get-Credential
  
#Connect to OneDrive for Business Site
Connect-PnPOnline $OneDriveSiteURL -Credentials $Cred
 
#empty recycle bin onedrive for business powershell
Clear-PnPRecycleBinItem -All -force
 
#empty first stage recycle bin in onedrive for business site
Get-PnPRecycleBinItem -FirstStage -RowLimit 5000  | Clear-PnpRecycleBinItem -Force
 
#PowerShell to empty 2nd Stage recycle bin in onedrive for business
Get-PnPRecycleBinItem -SecondStage -RowLimit 5000  | Clear-PnpRecycleBinItem -Force
