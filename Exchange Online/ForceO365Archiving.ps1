Connect-ExchangeOnline

get-mailboxLocation -user EmailAddress | Format-List mailboxGuid,mailboxLocationType

Get-Mailbox -identity EmailAddress | Get-MailboxStatistics | Select-Object Displayname, TotalItemSize, MailboxGuid

Start-ManagedFolderAssistant Primary_Guid