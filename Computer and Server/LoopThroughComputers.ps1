$computers = Get-Content -Path 'C:\Temp\Computers.txt'
$objects = @()

foreach ($computer in $computers){

    $objects += Get-WmiObject -Class MSFT_PhysicalDisk -ComputerName $computer -Namespace root\Microsoft\Windows\Storage | 
    Select-Object PSComputername, FriendlyName, MediaType

}


$objects | Export-Csv -ErrorAction Stop -path 'C:\Temp\WMIInfo.csv' -noTypeInformation -Delimiter "," -Force

$objects | Out-GridView