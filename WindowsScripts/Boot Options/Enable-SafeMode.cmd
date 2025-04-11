:: NAME: Enable Safe Mode
:: DEVELOPER: MikeTheTech
:: DESCRIPTION: Configure Windows to boot into Safe Mode on next restart.
:: UNDOABLE: Yes
:: UNDO_DESC: Restores normal boot configuration.
::
:: This script configures Windows to boot into Safe Mode on the next restart

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
title Configure Windows Safe Mode Boot Options
cls
echo ==========================================
echo     WINDOWS SAFE MODE CONFIGURATION
echo ==========================================
echo.
echo This script will configure Windows to boot into Safe Mode
echo on the next system restart.
echo.
echo Safe Mode options:
echo  1. Minimal Safe Mode
echo  2. Safe Mode with Networking
echo  3. Safe Mode with Command Prompt
echo  4. Enable Boot Menu (choose Safe Mode at startup)
echo  5. Cancel
echo.

set /p choice=Enter your choice (1-5): 

if "%choice%"=="1" goto :minimal_safe_mode
if "%choice%"=="2" goto :networking_safe_mode
if "%choice%"=="3" goto :cmd_safe_mode
if "%choice%"=="4" goto :boot_menu
if "%choice%"=="5" goto :cancel

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto :main

:minimal_safe_mode
echo.
echo Configuring system to boot into Minimal Safe Mode...

:: Backup current boot configuration
echo Creating configuration backup...
bcdedit /export "%TEMP%\boot_config_backup.bcd" >nul

:: Configure for Safe Mode
bcdedit /set {default} safeboot minimal

if %errorlevel% neq 0 (
    echo Failed to configure Safe Mode.
    goto :error
)

echo.
echo System will boot into Minimal Safe Mode on next restart.
echo To undo this change later, run this script with "undo" parameter.
echo.
goto :prompt_restart

:networking_safe_mode
echo.
echo Configuring system to boot into Safe Mode with Networking...

:: Backup current boot configuration
echo Creating configuration backup...
bcdedit /export "%TEMP%\boot_config_backup.bcd" >nul

:: Configure for Safe Mode with Networking
bcdedit /set {default} safeboot network

if %errorlevel% neq 0 (
    echo Failed to configure Safe Mode with Networking.
    goto :error
)

echo.
echo System will boot into Safe Mode with Networking on next restart.
echo To undo this change later, run this script with "undo" parameter.
echo.
goto :prompt_restart

:cmd_safe_mode
echo.
echo Configuring system to boot into Safe Mode with Command Prompt...

:: Backup current boot configuration
echo Creating configuration backup...
bcdedit /export "%TEMP%\boot_config_backup.bcd" >nul

:: Configure for Safe Mode with Command Prompt
bcdedit /set {default} safeboot minimal
bcdedit /set {default} safebootalternateshell yes

if %errorlevel% neq 0 (
    echo Failed to configure Safe Mode with Command Prompt.
    goto :error
)

echo.
echo System will boot into Safe Mode with Command Prompt on next restart.
echo To undo this change later, run this script with "undo" parameter.
echo.
goto :prompt_restart

:boot_menu
echo.
echo Configuring system to display the boot options menu at startup...

:: Backup current boot configuration
echo Creating configuration backup...
bcdedit /export "%TEMP%\boot_config_backup.bcd" >nul

:: Configure Boot Menu
bcdedit /set {bootmgr} displaybootmenu yes
bcdedit /set {bootmgr} timeout 15

if %errorlevel% neq 0 (
    echo Failed to configure boot menu.
    goto :error
)

echo.
echo System will display the boot options menu at startup.
echo Press F8 during startup to access Safe Mode options.
echo To undo this change later, run this script with "undo" parameter.
echo.
goto :end

:undo
echo.
echo Restoring normal boot configuration...

:: Check if backup exists
if exist "%TEMP%\boot_config_backup.bcd" (
    :: Restore from backup
    bcdedit /import "%TEMP%\boot_config_backup.bcd" >nul
    
    if %errorlevel% neq 0 (
        echo Failed to restore boot configuration from backup.
        
        :: Try manual reset if backup restore fails
        echo Attempting manual reset of boot configuration...
        bcdedit /deletevalue {default} safeboot
        bcdedit /deletevalue {default} safebootalternateshell
        bcdedit /set {bootmgr} displaybootmenu no
    ) else (
        echo Boot configuration restored from backup.
        del "%TEMP%\boot_config_backup.bcd"
    }
) else (
    :: No backup file, try manual reset
    echo No backup file found. Attempting manual reset of boot configuration...
    bcdedit /deletevalue {default} safeboot
    bcdedit /deletevalue {default} safebootalternateshell
    bcdedit /set {bootmgr} displaybootmenu no
)

echo.
echo System will boot normally on next restart.
echo.
goto :end

:prompt_restart
echo Would you like to restart the system now? (Y/N)
set /p restart=Enter your choice: 

if /i "%restart%"=="Y" (
    echo.
    echo Restarting system...
    shutdown /r /t 5 /c "Restarting to enter Safe Mode"
) else (
    echo.
    echo System is configured for Safe Mode.
    echo Please restart your computer manually when ready.
)
goto :end

:cancel
echo.
echo Operation cancelled. No changes were made.
goto :end

:error
echo.
echo An error occurred while configuring Safe Mode.
echo No changes were made to the system.
goto :end

:end
echo.
echo Script completed.
pause
endlocal
exit /b 0
