# NAME: Remove Common Bloatware
# DEVELOPER: MikeTheTech
# DESCRIPTION: Removes commonly unwanted pre-installed Windows 10/11 applications.
# UNDOABLE: Yes
# UNDO_DESC: Reinstalls removed bloatware applications.
#
# This script removes common pre-installed Windows applications that are often considered bloatware

param (
    [switch]$Undo
)

# List of common bloatware app packages to remove
$bloatwareApps = @(
    "Microsoft.3DBuilder",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.People",
    "Microsoft.SkypeApp",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

# Log file to keep track of removed apps (for undo functionality)
$logFile = "$env:TEMP\RemovedBloatware.log"

function Perform-Action {
    Write-Host "Removing common bloatware applications..."
    
    # Clear previous log if it exists
    if (Test-Path $logFile) {
        Remove-Item $logFile -Force
    }
    
    foreach ($app in $bloatwareApps) {
        $packagePresent = Get-AppxPackage -Name $app -AllUsers
        
        if ($packagePresent) {
            Write-Host "Removing $app..."
            try {
                # Log before removing
                Add-Content -Path $logFile -Value $app
                
                # Remove the app package
                Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage
                Write-Host "  Removed successfully." -ForegroundColor Green
            }
            catch {
                Write-Host "  Failed to remove $app. Error: $_" -ForegroundColor Red
            }
        }
        else {
            Write-Host "$app is not installed." -ForegroundColor Yellow
        }
    }
    
    Write-Host "`nBloatware removal completed. See $logFile for list of removed applications."
}

function Perform-Undo {
    Write-Host "Reinstalling previously removed bloatware applications..."
    
    if (-not (Test-Path $logFile)) {
        Write-Host "No log file found. Cannot restore applications." -ForegroundColor Red
        return
    }
    
    $removedApps = Get-Content $logFile
    
    foreach ($app in $removedApps) {
        Write-Host "Reinstalling $app..."
        try {
            # Reinstall the app package
            Add-AppxPackage -RegisterByFamilyName -MainPackage $app
            Write-Host "  Reinstalled successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "  Failed to reinstall $app. Error: $_" -ForegroundColor Red
        }
    }
    
    # Remove the log file after restoration
    Remove-Item $logFile -Force
    
    Write-Host "`nBloatware reinstallation completed."
}

# Main script
if ($Undo) {
    Perform-Undo
} else {
    Perform-Action
}
