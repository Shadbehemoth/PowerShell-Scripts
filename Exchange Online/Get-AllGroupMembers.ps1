mkdir Groups
cd Groups
$DistributionGroups = Get-DistributionGroup -ResultSize Unlimited
$DistributionGroups | ForEach-Object {
     $Group = $_
     $GroupMembers = Get-DistributionGroupMember -Identity $Group.Name -ResultSize Unlimited
     $GroupMembers | Export-Csv -Path ".\$($Group.Name).csv" -NoTypeInformation

}
$O365Groups = Get-UnifiedGroup -ResultSize Unlimited
$O365Groups | ForEach-Object {
     $Group = $_
     $GroupMembers = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Members -ResultSize Unlimited
     $GroupMembers | Export-Csv -Path ".\$($Group.DisplayName).csv" -NoTypeInformation
}