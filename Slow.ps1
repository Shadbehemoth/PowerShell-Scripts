# Disable Fastboot
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power"  /V "HiberbootEnabled" /T REG_DWORD /d "0" /f

# Disable SysMain
Stop-Service -Force -Name "SysMain"; Set-Service -Name "SysMain" -StartupType Disabled

# Disable Hibernation
powercfg -h off

# Clear Windows EDB File
net stop "Windows Search"
REG ADD "HKLM\SOFTWARE\Microsoft\Windows Search" /v SetupCompletedSuccessfully /t REG_DWORD /d 0 /f
del C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb
net start "Windows Search"

# Download and run a debloat script
Invoke-WebRequest -uri https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Windows10SysPrepDebloater.ps1 -OutFile Debloater.ps1

./Debloater.ps1 -Debloat
del Debloater.ps1

# Download and run O&O Shutup
Invoke-WebRequest -uri https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe -OutFile oosu10.exe
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ChrisTitusTech/win10script/master/ooshutup10.cfg" -OutFile ooshutup10.cfg
./OOSU10.exe ooshutup10.cfg /quiet
del OOSU10.exe 
del ooshutup10.cfg

# Run Cleanmgr
cleanmgr.exe /verylowdisk

# Set Virtual Memory to 10GB
$computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges;
$computersys.AutomaticManagedPagefile = $False;
$computersys.Put();
$pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name like '%pagefile.sys'";
$pagefile.InitialSize = 10240;
$pagefile.MaximumSize = 10240;
$pagefile.Put();

shutdown -r -t 30

