# Enable Storage Sense
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense"  /V "AllowStorageSenseGlobal" /T REG_DWORD /d "1" /f
# Enable deleting temp files
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense"  /V "AllowStorageSenseTemporaryFilesCleanup" /T REG_DWORD /d "1" /f
# Enable daily cleanup
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense"  /V "ConfigStorageSenseGlobalCadence" /T REG_DWORD /d "1" /f
# Dehydrate onlne files after 180 days
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense"  /V "ConfigStorageSenseCloudContentDehydrationThreshold" /T REG_DWORD /d "180" /f
# Clean Recycle Bin of files older than 7 days
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense"  /V "ConfigStorageSenseRecycleBinCleanupThreshold" /T REG_DWORD /d "7" /f
# Clean Downloads of files older than 180 days
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense"  /V "ConfigStorageSenseDownloadsCleanupThreshold" /T REG_DWORD /d "180" /f