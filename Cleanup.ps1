# Self-elevate the script if required
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        exit
    }
}

#############################################################################################################################################
# Pin & Unpin Programs 
#############################################################################################################################################
function Pin-App ([string]$appname, [switch]$unpin, [switch]$start, [switch]$taskbar, [string]$path) {
    if ($unpin.IsPresent) {
        $action = "Unpin"
    } else {
        $action = "Pin"
    }
    
    if (-not $taskbar.IsPresent -and -not $start.IsPresent) {
        Write-Error "Specify -taskbar and/or -start!"
    }
    
    if ($taskbar.IsPresent) {
        try {
            $exec = $false
            if ($action -eq "Unpin") {
                ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}
                if ($exec) {
                    Write "App '$appname' unpinned from Taskbar"
                } else {
                    if (-not $path -eq "") {
                        Pin-App-by-Path $path -Action $action
                    } else {
                        Write "'$appname' not found or 'Unpin from taskbar' not found on item!"
                    }
                }
            } else {
                ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Pin to taskbar'} | %{$_.DoIt(); $exec = $true}
                
                if ($exec) {
                    Write "App '$appname' pinned to Taskbar"
                } else {
                    if (-not $path -eq "") {
                        Pin-App-by-Path $path -Action $action
                    } else {
                        Write "'$appname' not found or 'Pin to taskbar' not found on item!"
                    }
                }
            }
        } catch {
            Write-Error "Error Pinning/Unpinning $appname to/from taskbar!"
        }
    }
    
    if ($start.IsPresent) {
        try {
            $exec = $false
            if ($action -eq "Unpin") {
                ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from Start'} | %{$_.DoIt(); $exec = $true}
                
                if ($exec) {
                    Write "App '$appname' unpinned from Start"
                } else {
                    if (-not $path -eq "") {
                        Pin-App-by-Path $path -Action $action -start
                    } else {
                        Write "'$appname' not found or 'Unpin from Start' not found on item!"
                    }
                }
            } else {
                ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Pin to Start'} | %{$_.DoIt(); $exec = $true}
                
                if ($exec) {
                    Write "App '$appname' pinned to Start"
                } else {
                    if (-not $path -eq "") {
                        Pin-App-by-Path $path -Action $action -start
                    } else {
                        Write "'$appname' not found or 'Pin to Start' not found on item!"
                    }
                }
            }
        } catch {
            Write-Error "Error Pinning/Unpinning $appname to/from Start!"
        }
    }
}

function Pin-App-by-Path([string]$Path, [string]$Action, [switch]$start) {
    if ($Path -eq "") {
        Write-Error -Message "You need to specify a Path" -ErrorAction Stop
    }
    if ($Action -eq "") {
        Write-Error -Message "You need to specify an action: Pin or Unpin" -ErrorAction Stop
    }
    if ((Get-Item -Path $Path -ErrorAction SilentlyContinue) -eq $null){
        Write-Error -Message "$Path not found" -ErrorAction Stop
    }
    $Shell = New-Object -ComObject "Shell.Application"
    $ItemParent = Split-Path -Path $Path -Parent
    $ItemLeaf = Split-Path -Path $Path -Leaf
    $Folder = $Shell.NameSpace($ItemParent)
    $ItemObject = $Folder.ParseName($ItemLeaf)
    $Verbs = $ItemObject.Verbs()
    
    if ($start.IsPresent) {
        switch($Action){
            "Pin"   {$Verb = $Verbs | Where-Object -Property Name -EQ "&Pin to Start"}
            "Unpin" {$Verb = $Verbs | Where-Object -Property Name -EQ "Un&pin from Start"}
            default {Write-Error -Message "Invalid action, should be Pin or Unpin" -ErrorAction Stop}
        }
    } else {
        switch($Action){
            "Pin"   {$Verb = $Verbs | Where-Object -Property Name -EQ "Pin to Tas&kbar"}
            "Unpin" {$Verb = $Verbs | Where-Object -Property Name -EQ "Unpin from Tas&kbar"}
            default {Write-Error -Message "Invalid action, should be Pin or Unpin" -ErrorAction Stop}
        }
    }
    
    if($Verb -eq $null){
        Write-Error -Message "That action is not currently available on this Path" -ErrorAction Stop
    } else {
        $Result = $Verb.DoIt()
    }
}

function Remove-Tiles {
    (New-Object -Com Shell.Application).
    NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').
    Items() |
    ForEach-Object { $_.Verbs() } |
    Where-Object { $_.Name -match 'Un.*pin from Start' } |
    ForEach-Object { $_.DoIt() }
}


#############################################################################################################################################
# System Tweaks
#############################################################################################################################################
Function Disable-AnnoyingFeatures {
    # Disable Fastboot
    Write-Host "Disabling Fastboot..."
    Set-ItemProperty -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 0
    
    # Disable Telemetry
    Write-Host "Disabling Telemetry..."
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    
    # Disable Wi-Fi Sense
    Write-Host "Disabling Wi-Fi Sense..."
    If (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
        New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0

    # Disable SmartScreen Filter
    Write-Host "Disabling SmartScreen Filter..."
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Type String -Value "Off"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 0

    # Disable Bing Search in Start Menu
    Write-Host "Disabling Bing Search in Start Menu..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
    
    # Disable Location Tracking
    Write-Host "Disabling Location Tracking..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
    
    # Disable Feedback
    Write-Host "Disabling Feedback..."
    If (!(Test-Path "HKCU:\Software\Microsoft\Siuf\Rules")) {
        New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
    
    # Disable Advertising ID
    Write-Host "Disabling Advertising ID..."
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
    
    # Disable Cortana
    Write-Host "Disabling Cortana..."
    If (!(Test-Path "HKCU:\Software\Microsoft\Personalization\Settings")) {
        New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
    If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization")) {
        New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
    If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore")) {
        New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
    
    # Restrict Windows Update P2P only to local network
    Write-Host "Restricting Windows Update P2P only to local network..."
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -Name "SystemSettingsDownloadMode" -Type DWord -Value 3
    
    # Remove AutoLogger file and restrict directory
    Write-Host "Removing AutoLogger file and restricting directory..."
    $autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
    If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
        Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
    }
    icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null
    
    # Stop and disable Diagnostics Tracking Service
    Write-Host "Stopping and disabling Diagnostics Tracking Service..."
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled
    
    # Stop and disable Home Groups services
    Write-Host "Stopping and disabling Home Groups services..."
    Stop-Service "HomeGroupListener"
    Set-Service "HomeGroupListener" -StartupType Disabled
    Stop-Service "HomeGroupProvider"
    Set-Service "HomeGroupProvider" -StartupType Disabled
    
    # Disable Remote Assistance
    Write-Host "Disabling Remote Assistance..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
    
    # Disable Autoplay
    Write-Host "Disabling Autoplay..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1
    
    # Disable Autorun for all drives
    Write-Host "Disabling Autorun for all drives..."
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255
    
    # Disable Sticky keys prompt
    Write-Host "Disabling Sticky keys prompt..."
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
    
    # Search button Icon
    Write-Host "Hiding Search Box / Button..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1
    
    # Hide Task View button
    Write-Host "Hiding Task View button..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

    # Hide People icon on Taskbar
    Write-Host "Hiding People icon..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0
    
    # Show all tray icons
    Write-Host "Showing all tray icons..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Type DWord -Value 0
    
    # Show known file extensions
    Write-Host "Showing known file extensions..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
    
    # Show hidden files
    Write-Host "Showing hidden files..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
    
    # Change default Explorer view to "Computer"
    Write-Host "Changing default Explorer view to `"Computer`"..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
    
    # Remove Music icon from computer namespace
    Write-Host "Removing Music icon from computer namespace..."
    Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -Recurse -ErrorAction SilentlyContinue
    
    # Remove 3D Objects icon from computer namespace
    Write-Host "Removing 3D Objects icon from computer namespace..."
    Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue
    
    # Disabling Hibernation
    powercfg.exe /hibernate off

    # Stops edge from taking over as the default .PDF viewer    
    Write-Output "Stopping Edge from taking over as the default .PDF viewer"
    $NoPDF = "HKCR:\.pdf"
    $NoProgids = "HKCR:\.pdf\OpenWithProgids"
    $NoWithList = "HKCR:\.pdf\OpenWithList" 
    If (!(Get-ItemProperty $NoPDF  NoOpenWith)) {
        New-ItemProperty $NoPDF NoOpenWith 
    }        
    If (!(Get-ItemProperty $NoPDF  NoStaticDefaultVerb)) {
        New-ItemProperty $NoPDF  NoStaticDefaultVerb 
    }        
    If (!(Get-ItemProperty $NoProgids  NoOpenWith)) {
        New-ItemProperty $NoProgids  NoOpenWith 
    }        
    If (!(Get-ItemProperty $NoProgids  NoStaticDefaultVerb)) {
        New-ItemProperty $NoProgids  NoStaticDefaultVerb 
    }        
    If (!(Get-ItemProperty $NoWithList  NoOpenWith)) {
        New-ItemProperty $NoWithList  NoOpenWith
    }        
    If (!(Get-ItemProperty $NoWithList  NoStaticDefaultVerb)) {
        New-ItemProperty $NoWithList  NoStaticDefaultVerb 
    }
            
    # Appends an underscore '_' to the Registry key for Edge
    $Edge = "HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_"
    If (Test-Path $Edge) {
        Set-Item $Edge AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_ 
    }

    # Left Align Taskbar. Does not affect Win 10
    Write-Host "Left Align Taskbar"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 0

    # Disable Shake to Minimize
    Write-Host "Disable Shake to Minimize"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -Type DWord -Value 1

    # Disable News and Interests
    Write-Host "Disable News and Interests"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 2

    # Hide Cortana Button
    Write-Host "Hide Cortana Button"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Type DWord -Value 0

    # Hide Meet Now
    Write-Host "Hide Meet Now"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -Name "HideSCAMeetNow " -Type DWord -Value 1
}

Function Debloat-Windows {
    # Uninstall default Microsoft applications
    Write-Host "Uninstalling default Microsoft applications..."
    Get-AppxPackage "Microsoft.3DBuilder" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.BingFinance" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.BingSports" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.Getstarted" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.Office.OneNote" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.People" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.SkypeApp" | Remove-AppxPackage
    Get-AppxPackage "microsoft.windowscommunicationsapps" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsMaps" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsPhone" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.AppConnector" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.ConnectivityStore" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.Office.Sway" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.Messaging" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.CommsPhone" | Remove-AppxPackage
    Get-AppxPackage "9E2F88E3.Twitter" | Remove-AppxPackage
    Get-AppxPackage "king.com.CandyCrushSodaSaga" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsFeedbackHub" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.Wallet" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.GetHelp" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.Xbox.TCUI" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.XboxGameOverlay" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.MixedReality.Portal" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.XboxIdentityProvider" | Remove-AppPackage
    
    Write-Output "Uninstalling default apps"
    $apps = @(
        # default Windows 10 apps
        "Microsoft.3DBuilder"
        "Microsoft.Advertising.Xaml"
        "Microsoft.Appconnector"
        "Microsoft.BingFinance"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingTranslator"
        "Microsoft.BingWeather"
        "Microsoft.FreshPaint"
        "Microsoft.GamingServices"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MixedReality.Portal"
        "Microsoft.MicrosoftPowerBIForWindows"
        "Microsoft.MicrosoftSolitaireCollection"
        #"Microsoft.MicrosoftStickyNotes"
        "Microsoft.MinecraftUWP"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.Office.OneNote"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.YourPhone"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "Microsoft.Windows.CloudExperienceHost"
        "Microsoft.Windows.ContentDeliveryManager"
        "Microsoft.Windows.PeopleExperienceHost"
        "Microsoft.XboxGameCallableUI"
    
        # Threshold 2 apps
        "Microsoft.CommsPhone"
        "Microsoft.ConnectivityStore"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.WindowsFeedbackHub"
    
        # Creators Update apps
        "Microsoft.Microsoft3DViewer"
    
        #Redstone apps
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.BingTravel"
        "Microsoft.WindowsReadingList"
    
        # Redstone 5 apps
        "Microsoft.MixedReality.Portal"
        #"Microsoft.ScreenSketch" Snip & Sketch
        "Microsoft.XboxGamingOverlay"
        "Microsoft.YourPhone"
    
        # non-Microsoft
        "2FE3CB00.PicsArt-PhotoStudio"
        "46928bounde.EclipseManager"
        "4DF9E0F8.Netflix"
        "613EBCEA.PolarrPhotoEditorAcademicEdition"
        "6Wunderkinder.Wunderlist"
        "7EE7776C.LinkedInforWindows"
        "89006A2E.AutodeskSketchBook"
        "9E2F88E3.Twitter"
        "A278AB0D.DisneyMagicKingdoms"
        "A278AB0D.MarchofEmpires"
        "ActiproSoftwareLLC.562882FEEB491" # next one is for the Code Writer from Actipro Software LLC
        "CAF9E577.Plex"
        "ClearChannelRadioDigital.iHeartRadio"
        "D52A8D61.FarmVille2CountryEscape"
        "D5EA27B7.Duolingo-LearnLanguagesforFree"
        "DB6EA5DB.CyberLinkMediaSuiteEssentials"
        "DolbyLaboratories.DolbyAccess"
        "DolbyLaboratories.DolbyAccess"
        "Drawboard.DrawboardPDF"
        "Facebook.Facebook"
        "Fitbit.FitbitCoach"
        "Flipboard.Flipboard"
        "GAMELOFTSA.Asphalt8Airborne"
        "KeeperSecurityInc.Keeper"
        "NORDCURRENT.COOKINGFEVER"
        "PandoraMediaInc.29680B314EFC2"
        "Playtika.CaesarsSlotsFreeCasino"
        "ShazamEntertainmentLtd.Shazam"
        "SlingTVLLC.SlingTV"
        "SpotifyAB.SpotifyMusic"
        "TheNewYorkTimes.NYTCrossword"
        "ThumbmunkeysLtd.PhototasticCollage"
        "TuneIn.TuneInRadio"
        "WinZipComputing.WinZipUniversal"
        "XINGAG.XING"
        "flaregamesGmbH.RoyalRevolt2"
        "king.com.*"
        "king.com.BubbleWitch3Saga"
        "king.com.CandyCrushSaga"
        "king.com.CandyCrushSodaSaga"
    )
    
    foreach ($app in $apps) {
        Write-Output "Trying to remove $app"
    
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers
    
        Get-AppXProvisionedPackage -Online |
            Where-Object DisplayName -EQ $app |
            Remove-AppxProvisionedPackage -Online
    }
    
    # Prevents Apps from re-installing
    $cdm = @(
        "ContentDeliveryAllowed"
        "FeatureManagementEnabled"
        "OemPreInstalledAppsEnabled"
        "PreInstalledAppsEnabled"
        "PreInstalledAppsEverEnabled"
        "SilentInstalledAppsEnabled"
        "SubscribedContent-314559Enabled"
        "SubscribedContent-338387Enabled"
        "SubscribedContent-338388Enabled"
        "SubscribedContent-338389Enabled"
        "SubscribedContent-338393Enabled"
        "SubscribedContentEnabled"
        "SystemPaneSuggestionsEnabled"
    )
    
    New-FolderForced -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    foreach ($key in $cdm) {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" $key 0
    }
    
    # This script disables unwanted Windows services. 
    
    $services = @(
        "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
        "DiagTrack"                                # Diagnostics Tracking Service
        "dmwappushservice"                         # WAP Push Message Routing Service (see known issues)
        "lfsvc"                                    # Geolocation Service
        "MapsBroker"                               # Downloaded Maps Manager
        "TrkWks"                                   # Distributed Link Tracking Client
        "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
        "XblAuthManager"                           # Xbox Live Auth Manager
        "XblGameSave"                              # Xbox Live Game Save Service
        "XboxNetApiSvc"                            # Xbox Live Networking Service
        "SysMain"                                  # Sysmain
    )
    
    foreach ($service in $services) {
        Write-Output "Trying to disable $service"
        Get-Service -Name $service | Stop-Service -Force
        Get-Service -Name $service | Set-Service -StartupType Disabled
    }

    # Clear last used files and folders
    Write-Host "Clear last used files and folders"
    Remove-Item %APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*.automaticDestinations-ms -FORCE -ErrorAction SilentlyContinue

    #These are the registry keys that it will delete.
    $Keys = @(
            
        #Remove Background Tasks
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
            
        #Windows File
        "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
            
        #Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
            
        #Scheduled Tasks to delete
        "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
            
        #Windows Protocol Keys
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
               
        #Windows Share Target
        "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    )
        
    # This writes the output of each key it is removing and also removes the keys listed above.
    ForEach ($Key in $Keys) {
        Write-Output "Removing $Key from registry"
        Remove-Item $Key -Recurse
    }

    # Fix Whitelisted apps
    If(!(Get-AppxPackage -AllUsers | Select Microsoft.Paint3D, `
        Microsoft.MSPaint, Microsoft.WindowsCalculator, Microsoft.WindowsStore, `
        Microsoft.MicrosoftStickyNotes, Microsoft.WindowsSoundRecorder, Microsoft.Windows.Photos, Microsoft.ScreenSketch)) {
    
    Get-AppxPackage -allusers Microsoft.Paint3D | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.MSPaint | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.WindowsCalculator | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.MicrosoftStickyNotes | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.WindowsSoundRecorder | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.Windows.Photos | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} 
    Get-AppxPackage -allusers Microsoft.ScreenSketch | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} }
}
    
function Set-PinlessStartMenu{
    # Unpin all Start Menu tiles
    # DO NOT TAB INDENT
    $START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@

    $layoutFile="C:\Windows\StartMenuLayout.xml"

    #Delete layout file if it already exists
    If(Test-Path $layoutFile)
    {
        Remove-Item $layoutFile
    }

    #Creates the blank layout file
    $START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII

    $regAliases = @("HKLM", "HKCU")

    #Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
    foreach ($regAlias in $regAliases){
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        IF(!(Test-Path -Path $keyPath)) { 
            New-Item -Path $basePath -Name "Explorer"
        }
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
        Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
    }

    #Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
    Stop-Process -name explorer
    Start-Sleep -s 5
    $wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
    Start-Sleep -s 5

    #Enable the ability to pin items again by disabling "LockedStartLayout"
    foreach ($regAlias in $regAliases){
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
    }

    #Restart Explorer and delete the layout file
    Stop-Process -name explorer

    # Uncomment the next line to make clean start menu default for all new users
    Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\

    Remove-Item $layoutFile
}

Function Enable-StorageSense{
    # Enable Storage Sense
    # Enable deleting temp files, Enable daily cleanup
    # Dehydrate onlne files after 180 days
    # Clean Recycle Bin of files older than 7 days
    # Clean Downloads of files older than 180 days
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "AllowStorageSenseGlobal" /T REG_DWORD /d "1" /f
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "AllowStorageSenseTemporaryFilesCleanup" /T REG_DWORD /d "1" /f
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "ConfigStorageSenseGlobalCadence" /T REG_DWORD /d "1" /f
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "ConfigStorageSenseCloudContentDehydrationThreshold" /T REG_DWORD /d "180" /f
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "ConfigStorageSenseRecycleBinCleanupThreshold" /T REG_DWORD /d "7" /f
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "ConfigStorageSenseDownloadsCleanupThreshold" /T REG_DWORD /d "180" /f
}

function Set-VirtualMemory{
    # Set Virtual Memory to 10GB
    $computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges;
    $computersys.AutomaticManagedPagefile = $False;
    $computersys.Put();
    $pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name like '%pagefile.sys'";
    $pagefile.InitialSize = 10240;
    $pagefile.MaximumSize = 10240;
    $pagefile.Put();
}

#############################################################################################################################################
# Main Login Loop
#############################################################################################################################################

# Windows Tweaks
Disable-AnnoyingFeatures
Debloat-Windows
Set-PinlessStartMenu
Enable-StorageSense
Set-VirtualMemory
Remove-Tiles
Pin-App "Microsoft Edge" -unpin -taskbar
Pin-App "Microsoft Store" -unpin -taskbar
