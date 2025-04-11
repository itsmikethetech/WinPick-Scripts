:: NAME: Set Boot Timeout
:: DEVELOPER: MikeTheTech
:: DESCRIPTION: Changes the boot menu timeout duration in Windows.
:: UNDOABLE: Yes
:: UNDO_DESC: Restores the original boot menu timeout duration.
::
:: This script modifies the Windows boot menu timeout duration

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
:: Backup current timeout value
echo Backing up current boot timeout value...
bcdedit /timeout > "%TEMP%\boot_timeout_backup.txt"

:: Extract just the timeout value from the output
for /f "tokens=2 delims=: " %%a in ('bcdedit /timeout') do (
    set "original_timeout=%%a"
)

echo Current boot timeout is set to %original_timeout% seconds.
echo.

:: Get new timeout value
set /p new_timeout=Enter new boot timeout in seconds (recommended: 3-10): 

:: Validate input
set "valid=true"
for /f "delims=0123456789" %%i in ("%new_timeout%") do set "valid=false"

if "%valid%"=="false" (
    echo Invalid input. Please enter a number.
    pause
    goto :main
)

if %new_timeout% LSS 0 (
    echo Invalid input. Timeout cannot be negative.
    pause
    goto :main
)

if %new_timeout% GTR 999 (
    echo Invalid input. Timeout is too large.
    pause
    goto :main
)

:: Set new timeout
echo.
echo Setting boot timeout to %new_timeout% seconds...
bcdedit /timeout %new_timeout%

if %errorlevel% neq 0 (
    echo Failed to change boot timeout.
    del "%TEMP%\boot_timeout_backup.txt" 2>nul
    pause
    exit /b 1
)

echo Boot timeout has been changed successfully.
echo The new setting will apply on next system restart.
echo.

:: Additional advanced options
echo Would you like to modify additional boot options?
echo 1. Display OS selection menu at startup
echo 2. Hide OS selection menu at startup (boot directly)
echo 3. Skip additional options
echo.
choice /c 123 /n /m "Enter your choice (1-3): "

if errorlevel 3 goto :end
if errorlevel 2 goto :hide_menu
if errorlevel 1 goto :show_menu

:show_menu
echo.
echo Configuring Windows to always display the OS selection menu...
bcdedit /set {bootmgr} displaybootmenu yes
if %errorlevel% neq 0 (
    echo Failed to configure boot menu display.
) else (
    echo Boot menu will now always be displayed at startup.
)
goto :end

:hide_menu
echo.
echo Configuring Windows to hide the OS selection menu (direct boot)...
bcdedit /set {bootmgr} displaybootmenu no
if %errorlevel% neq 0 (
    echo Failed to configure boot menu display.
) else (
    echo Boot menu will now be hidden unless multiple OS are detected or a key is pressed.
    echo Note: If you have multiple operating systems, they will still be accessible by
    echo pressing F8 during startup.
)
goto :end

:undo
:: Check if backup exists
if not exist "%TEMP%\boot_timeout_backup.txt" (
    echo No backup found. Cannot restore original timeout.
    pause
    exit /b 1
)

:: Extract timeout value from backup
for /f "tokens=2 delims=: " %%a in ('type "%TEMP%\boot_timeout_backup.txt"') do (
    set "original_timeout=%%a"
)

:: Restore original timeout
echo Restoring original boot timeout value...
bcdedit /timeout %original_timeout%

if %errorlevel% neq 0 (
    echo Failed to restore original boot timeout.
    pause
    exit /b 1
)

echo Boot timeout has been restored to the original value of %original_timeout% seconds.
echo The new setting will apply on next system restart.

:: Clean up backup
del "%TEMP%\boot_timeout_backup.txt"

goto :end

:end
echo.
echo Script completed.
pause
endlocal
exit /b 0
