$365Logon = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $365Logon -Authentication Basic -AllowRedirection
Import-PSSession $Session

$Groups = Get-DistributionGroup
$Groups | ForEach-Object {
$group = $_.Name
Get-DistributionGroupMember $group | ForEach-Object {
      New-Object -TypeName PSObject -Property @{
       Group = $group
       Member = $_.Name
       EmailAddress = $_.PrimarySMTPAddress
       RecipientType= $_.RecipientType
}}} | Export-CSV "C:\DistributionGroupMembers.csv" -NoTypeInformation -Encoding UTF8

$Groups = Get-UnifiedGroup -ResultSize Unlimited
$Groups | ForEach-Object {
$group = $_
Get-UnifiedGroupLinks -Identity $group.Name -LinkType Members -ResultSize Unlimited | ForEach-Object {
      New-Object -TypeName PSObject -Property @{
       Group = $group.DisplayName
       Member = $_.Name
       EmailAddress = $_.PrimarySMTPAddress
       RecipientType= $_.RecipientType
}}} | Export-CSV "C:\Office365GroupMembers.csv" -NoTypeInformation -Encoding UTF8