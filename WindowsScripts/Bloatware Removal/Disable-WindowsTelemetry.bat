:: NAME: Disable Windows Telemetry
:: DEVELOPER: MikeTheTech
:: DESCRIPTION: Disables Windows telemetry and data collection services.
:: UNDOABLE: Yes
:: UNDO_DESC: Re-enables Windows telemetry and data collection services.
::
:: This script disables Windows telemetry and data collection to improve privacy

@echo off
setlocal enabledelayedexpansion

:: Check if the first parameter is "undo"
if "%1"=="undo" goto :undo

:main
echo Disabling Windows telemetry and data collection...

:: Create backup of current settings (for undo capability)
echo Creating backup of current settings...
reg export "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "%TEMP%\TelemetrySettings.reg" /y
reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" "%TEMP%\DiagTrackSettings.reg" /y

:: Set telemetry to lowest setting
echo Setting telemetry to lowest setting...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

:: Disable DiagTrack service
echo Disabling Connected User Experiences and Telemetry service (DiagTrack)...
sc stop DiagTrack
sc config DiagTrack start= disabled

:: Disable dmwappushservice
echo Disabling WAP Push Message Routing Service...
sc stop dmwappushservice
sc config dmwappushservice start= disabled

:: Disable Customer Experience Improvement Program
echo Disabling Customer Experience Improvement Program...
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /disable
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM" /disable
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /disable
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /disable

echo Windows telemetry has been disabled.
goto :end

:undo
echo Re-enabling Windows telemetry and data collection...

:: Restore settings from backup
echo Restoring settings from backup...
if exist "%TEMP%\TelemetrySettings.reg" (
    reg import "%TEMP%\TelemetrySettings.reg"
    del "%TEMP%\TelemetrySettings.reg"
) else (
    echo Warning: Backup registry file not found.
)

if exist "%TEMP%\DiagTrackSettings.reg" (
    reg import "%TEMP%\DiagTrackSettings.reg"
    del "%TEMP%\DiagTrackSettings.reg"
) else (
    echo Warning: Backup registry file not found.
)

:: Enable DiagTrack service
echo Re-enabling Connected User Experiences and Telemetry service (DiagTrack)...
sc config DiagTrack start= auto
sc start DiagTrack

:: Enable dmwappushservice
echo Re-enabling WAP Push Message Routing Service...
sc config dmwappushservice start= auto
sc start dmwappushservice

:: Re-enable Customer Experience Improvement Program
echo Re-enabling Customer Experience Improvement Program...
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /enable
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM" /enable
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /enable
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /enable

echo Windows telemetry has been re-enabled.
goto :end

:end
echo.
echo Script completed.
pause
