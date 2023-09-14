$networkInterfaces = Get-NetAdapter | Where-Object { $_.InterfaceType -ne 'Loopback' }

foreach ($interface in $networkInterfaces) {
    $interfaceName = $interface.Name
    Write-Host "Disabling IPv6 on interface: $interfaceName"
    
    # Disable IPv6 on the network interface
    Set-NetAdapterBinding -Name $interfaceName -ComponentID ms_tcpip6 -Enabled $false
}

Write-Host "IPv6 has been disabled on all network interfaces."