Get-EXOMailbox | 
Get-MailboxStatistics | 
Sort totalitemsize | 
select displayname, totalitemsize |
Format-Table -Property displayname, @{n='mb';e={'{0:N}' -f ($_.totalitemsize / 1mb)}}


Get-EXOMailbox | 
Get-MailboxStatistics | 
select displayname, totalitemsize -AutoSize |
Sort totalitemsize 

Get-EXOMailbox -identity * |
get-mailboxstatistics | 
select displayname, TotalItemSize, @{expression = {$_.TotalItemSize.Value.ToMB()}; label="TotalItemSizeMB"} | 
sort totalitemsizeMB

Get-EXOMailbox | 
Get-MailboxStatistics | 
Sort totalitemsize |
FL displayname, totalitemsize -AutoSize


Get-Mailbox -ResultSize Unlimited |
Get-MailboxStatistics |
Select DisplayName, `
@{name="TotalItemSize (MB)"; expression={[math]::Round(($_.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}} , `
@{name="SystemMessageSizeWarningQuota (GB)"; expression={[math]::Round(($_.SystemMessageSizeWarningQuota.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1GB),2)}}|
Sort "TotalItemSize (MB)" -Descending |
export-csv "FileName.csv" -NoTypeInformation -Encoding UTF8


Get-InboxRule -Mailbox * | 
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
    }