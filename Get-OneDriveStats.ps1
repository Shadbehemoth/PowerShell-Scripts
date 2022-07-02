Function Get-OneDriveStats {
  <#
    .SYNOPSIS
        Get the mailbox size and quota
  #>
  process {
    $oneDrives = Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/'" -Detailed | 
    Select Title,Owner,StorageQuota,StorageQuotaWarningLevel,StorageUsageCurrent,LastContentModifiedDate,Status
    $i = 0
    $oneDrives | ForEach {
      [pscustomobject]@{
        "Display Name" = $_.Title
        "Owner" = $_.Owner
        "Onedrive Size (Gb)" = $_.StorageUsageCurrent
        "Storage Warning Quota (Gb)" = $_.StorageQuotaWarningLevel
        "Storage Quota (Gb)" = $_.StorageQuota
        "Last Used Date" = $_.LastContentModifiedDate
        "Status" = $_.Status
      }
      $currentUser = $_.Title
      Write-Progress -Activity "Collecting OneDrive Sizes" -Status "Current Count: $i" -PercentComplete (($i / $oneDrives.Count) * 100) -CurrentOperation "Processing OneDrive: $currentUser"
      $i++;
    }
  }
}
