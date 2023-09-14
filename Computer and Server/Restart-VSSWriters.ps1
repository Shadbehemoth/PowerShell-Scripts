if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        exit
    }
}

Restart-Service VSS	
Restart-Service BITS
Restart-Service DFSR
Restart-Service DHCPServer	
Restart-Service NtFrs
Restart-Service srmsvc
Restart-Service AppHostSvc
Restart-Service IISADMIN
Restart-Service MSExchangeIS
Restart-Service vmms
Restart-Service NTDS
Restart-Service OSearch
Restart-Service OSearch14
Restart-Service WSearch
Restart-Service SPSearch
Restart-Service SPSearch4
Restart-Service SQLWriter
Restart-Service CryptSvc
Restart-Service TermServLicensing
Restart-Service WINS
Restart-Service Winmgmt