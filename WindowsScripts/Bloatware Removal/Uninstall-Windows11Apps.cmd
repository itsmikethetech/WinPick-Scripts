:: NAME: Uninstall Windows 11 Apps
:: DEVELOPER: MikeTheTech
:: DESCRIPTION: Provides options to uninstall built-in Windows 11 applications.
:: UNDOABLE: No
:: UNDO_DESC: Reinstallation requires manual intervention via the Microsoft Store.
::
:: This script helps uninstall built-in Windows 11 applications

@echo off
setlocal enabledelayedexpansion

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrative privileges.
    echo Please run as administrator.
    pause
    exit /b 1
)

:: Check if parameter is "undo"
if "%1"=="undo" goto :undo

:main
title Uninstall Windows 11 Built-in Apps
cls
echo ============================================
echo    WINDOWS 11 BUILT-IN APPS UNINSTALLER    
echo ============================================
echo.
echo This script will help you uninstall built-in Windows 11 applications.
echo.
echo IMPORTANT: Uninstalled apps can be reinstalled from the Microsoft Store,
echo but this script does not provide automatic reinstallation functionality.
echo.
echo Select an option:
echo.
echo  1. Display installed built-in apps
echo  2. Uninstall specific app
echo  3. Uninstall common bloatware apps
echo  4. Exit
echo.

set /p choice=Enter your choice (1-4): 

if "%choice%"=="1" goto :display_apps
if "%choice%"=="2" goto :uninstall_specific
if "%choice%"=="3" goto :uninstall_common
if "%choice%"=="4" goto :end

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto :main

:display_apps
cls
echo ============================================
echo        INSTALLED BUILT-IN APPS
echo ============================================
echo.
echo Retrieving list of installed apps...
echo.

:: Create a temporary PowerShell script
echo $apps = Get-AppxPackage -AllUsers ^| Sort-Object -Property Name ^| Format-Table -Property Name, PackageFullName -AutoSize > %TEMP%\listapps.ps1
echo $apps >> %TEMP%\listapps.ps1

:: Execute the script
powershell -ExecutionPolicy Bypass -File "%TEMP%\listapps.ps1"

:: Delete the temporary script
del %TEMP%\listapps.ps1

echo.
echo Press any key to return to the main menu...
pause >nul
goto :main

:uninstall_specific
cls
echo ============================================
echo        UNINSTALL SPECIFIC APP
echo ============================================
echo.
echo Enter the app name or part of the name.
echo (Example: Microsoft.WindowsAlarms)
echo.
set /p app_name=App name: 

if "%app_name%"=="" (
    echo App name cannot be empty.
    timeout /t 2 >nul
    goto :uninstall_specific
)

:: Create a temporary PowerShell script
echo $apps = Get-AppxPackage -AllUsers ^| Where-Object {$_.Name -like "*%app_name%*"} > %TEMP%\findapps.ps1
echo if ($apps) { >> %TEMP%\findapps.ps1
echo     Write-Host "Found the following apps:" >> %TEMP%\findapps.ps1
echo     $apps ^| Format-Table -Property Name, PackageFullName -AutoSize >> %TEMP%\findapps.ps1
echo     Write-Host "Uninstalling apps..." >> %TEMP%\findapps.ps1
echo     foreach ($app in $apps) { >> %TEMP%\findapps.ps1
echo         try { >> %TEMP%\findapps.ps1
echo             Remove-AppxPackage -Package $app.PackageFullName -AllUsers >> %TEMP%\findapps.ps1
echo             Write-Host ("Successfully uninstalled: " + $app.Name) -ForegroundColor Green >> %TEMP%\findapps.ps1
echo         } catch { >> %TEMP%\findapps.ps1
echo             Write-Host ("Failed to uninstall: " + $app.Name) -ForegroundColor Red >> %TEMP%\findapps.ps1
echo             Write-Host $_.Exception.Message -ForegroundColor Red >> %TEMP%\findapps.ps1
echo         } >> %TEMP%\findapps.ps1
echo     } >> %TEMP%\findapps.ps1
echo } else { >> %TEMP%\findapps.ps1
echo     Write-Host "No apps found matching '%app_name%'." -ForegroundColor Yellow >> %TEMP%\findapps.ps1
echo } >> %TEMP%\findapps.ps1

:: Execute the script
powershell -ExecutionPolicy Bypass -File "%TEMP%\findapps.ps1"

:: Delete the temporary script
del %TEMP%\findapps.ps1

echo.
echo Press any key to return to the main menu...
pause >nul
goto :main

:uninstall_common
cls
echo ============================================
echo     UNINSTALL COMMON BLOATWARE APPS
echo ============================================
echo.
echo The following common bloatware apps will be uninstalled:
echo.
echo  - Microsoft.3DBuilder
echo  - Microsoft.BingNews
echo  - Microsoft.BingWeather
echo  - Microsoft.GetHelp
echo  - Microsoft.Getstarted
echo  - Microsoft.MicrosoftOfficeHub
echo  - Microsoft.MicrosoftSolitaireCollection
echo  - Microsoft.MixedReality.Portal
echo  - Microsoft.People
echo  - Microsoft.SkypeApp
echo  - Microsoft.WindowsAlarms
echo  - Microsoft.WindowsFeedbackHub
echo  - Microsoft.WindowsMaps
echo  - Microsoft.Xbox.TCUI
echo  - Microsoft.XboxApp
echo  - Microsoft.XboxGameOverlay
echo  - Microsoft.XboxSpeechToTextOverlay
echo  - Microsoft.YourPhone
echo  - Microsoft.ZuneMusic
echo  - Microsoft.ZuneVideo
echo.
echo Proceed with uninstallation? (Y/N)
set /p confirm=Confirm: 

if /i not "%confirm%"=="Y" goto :main

:: Create a temporary PowerShell script to remove common bloatware
echo $apps = @( >> %TEMP%\removebloat.ps1
echo     "Microsoft.3DBuilder", >> %TEMP%\removebloat.ps1
echo     "Microsoft.BingNews", >> %TEMP%\removebloat.ps1
echo     "Microsoft.BingWeather", >> %TEMP%\removebloat.ps1
echo     "Microsoft.GetHelp", >> %TEMP%\removebloat.ps1
echo     "Microsoft.Getstarted", >> %TEMP%\removebloat.ps1
echo     "Microsoft.MicrosoftOfficeHub", >> %TEMP%\removebloat.ps1
echo     "Microsoft.MicrosoftSolitaireCollection", >> %TEMP%\removebloat.ps1
echo     "Microsoft.MixedReality.Portal", >> %TEMP%\removebloat.ps1
echo     "Microsoft.People", >> %TEMP%\removebloat.ps1
echo     "Microsoft.SkypeApp", >> %TEMP%\removebloat.ps1
echo     "Microsoft.WindowsAlarms", >> %TEMP%\removebloat.ps1
echo     "Microsoft.WindowsFeedbackHub", >> %TEMP%\removebloat.ps1
echo     "Microsoft.WindowsMaps", >> %TEMP%\removebloat.ps1
echo     "Microsoft.Xbox.TCUI", >> %TEMP%\removebloat.ps1
echo     "Microsoft.XboxApp", >> %TEMP%\removebloat.ps1
echo     "Microsoft.XboxGameOverlay", >> %TEMP%\removebloat.ps1
echo     "Microsoft.XboxSpeechToTextOverlay", >> %TEMP%\removebloat.ps1
echo     "Microsoft.YourPhone", >> %TEMP%\removebloat.ps1
echo     "Microsoft.ZuneMusic", >> %TEMP%\removebloat.ps1
echo     "Microsoft.ZuneVideo" >> %TEMP%\removebloat.ps1
echo ) >> %TEMP%\removebloat.ps1
echo. >> %TEMP%\removebloat.ps1
echo $logFile = "$env:TEMP\RemovedApps.log" >> %TEMP%\removebloat.ps1
echo "# Apps removed on $(Get-Date)" ^> $logFile >> %TEMP%\removebloat.ps1
echo. >> %TEMP%\removebloat.ps1
echo foreach ($app in $apps) { >> %TEMP%\removebloat.ps1
echo     $packageFullName = (Get-AppxPackage -Name $app -AllUsers).PackageFullName >> %TEMP%\removebloat.ps1
echo     $packagePublisher = (Get-AppxPackage -Name $app -AllUsers).Publisher >> %TEMP%\removebloat.ps1
echo. >> %TEMP%\removebloat.ps1
echo     if ($packageFullName) { >> %TEMP%\removebloat.ps1
echo         Write-Host "Uninstalling $app..." >> %TEMP%\removebloat.ps1
echo. >> %TEMP%\removebloat.ps1
echo         try { >> %TEMP%\removebloat.ps1
echo             Remove-AppxPackage -Package $packageFullName -AllUsers >> %TEMP%\removebloat.ps1
echo             Write-Host "  Successfully uninstalled $app." -ForegroundColor Green >> %TEMP%\removebloat.ps1
echo             Add-Content -Path $logFile -Value "$app,$packageFullName,$packagePublisher" >> %TEMP%\removebloat.ps1
echo         } catch { >> %TEMP%\removebloat.ps1
echo             Write-Host "  Failed to uninstall $app." -ForegroundColor Red >> %TEMP%\removebloat.ps1
echo             Write-Host "  Error: $_" -ForegroundColor Red >> %TEMP%\removebloat.ps1
echo         } >> %TEMP%\removebloat.ps1
echo     } else { >> %TEMP%\removebloat.ps1
echo         Write-Host "$app is not installed." -ForegroundColor Yellow >> %TEMP%\removebloat.ps1
echo     } >> %TEMP%\removebloat.ps1
echo } >> %TEMP%\removebloat.ps1
echo. >> %TEMP%\removebloat.ps1
echo Write-Host "Uninstallation completed. See $logFile for a record of removed apps." -ForegroundColor Cyan >> %TEMP%\removebloat.ps1

:: Execute the script
powershell -ExecutionPolicy Bypass -File "%TEMP%\removebloat.ps1"

:: Delete the temporary script
del %TEMP%\removebloat.ps1

echo.
echo Press any key to return to the main menu...
pause >nul
goto :main

:undo
cls
echo ============================================
echo             REINSTALL APPS
echo ============================================
echo.
echo This script does not support automatic reinstallation of Windows apps.
echo.
echo To reinstall removed apps, please follow these steps:
echo.
echo  1. Open the Microsoft Store app
echo  2. Search for the app you want to reinstall
echo  3. Click on the app and then click "Install"
echo.
echo If the app is not available in the Store, you may need to reset Windows.
echo.
echo Press any key to exit...
pause >nul
goto :end

:end
endlocal
exit /b 0
