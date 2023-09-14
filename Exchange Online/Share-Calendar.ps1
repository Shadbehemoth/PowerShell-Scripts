$Users = @("Email@example.com")
Foreach ($mbx in get-mailbox) {
 
    $calendar = $mbx.alias + ":\Calendar"
    Foreach ($User in $Users) {
        Add-mailboxfolderpermission -identity $calendar -user $User -AccessRights PublishingEditor
    }
 
}


Foreach ($mbx in get-mailbox) {
    Add-mailboxfolderpermission -identity "Boardroom5@example.com:\Calendar" -user $mbx.UserPrincipalName -AccessRights LimitedDetails
}
