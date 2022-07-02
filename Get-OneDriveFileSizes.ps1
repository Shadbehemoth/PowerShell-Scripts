Get-PnPListItem -List "Documents" |
Select-Object id,`
@{label="GUID";expression={$_.FieldValues.UniqueId}},`
@{label="Filename";expression={$_.FieldValues.FileLeafRef}},`
@{label="Last Modified";expression={$_.FieldValues.Last_x0020_Modified}},`
@{label="File Size";expression={$_.FieldValues.File_x0020_Size}} | 
Sort-Object "Last Modified" | Out-GridView