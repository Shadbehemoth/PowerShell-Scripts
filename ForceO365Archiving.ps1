Connect-ExchangeOnline

get-mailboxLocation -user EmailAddress | fl mailboxGuid,mailboxLocationType

Get-Mailbox -identity EmailAddress | Get-MailboxStatistics | Select-Object Displayname, TotalItemSize, MailboxGuid

Start-ManagedFolderAssistant Primary_Guid