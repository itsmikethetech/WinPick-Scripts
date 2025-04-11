# NAME: Enable Fast Boot
# DEVELOPER: MikeTheTech
# DESCRIPTION: Enables Windows Fast Startup feature for quicker boot times.
# UNDOABLE: Yes
# UNDO_DESC: Disables Windows Fast Startup feature.
#
# This script enables the Windows Fast Startup feature to reduce boot time

param (
    [switch]$Undo
)

function Perform-Action {
    Write-Host "Enabling Windows Fast Startup feature..."
    
    # Store original value for undo capability
    $originalValue = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -ErrorAction SilentlyContinue
    
    if ($null -ne $originalValue) {
        $originalValue = $originalValue.HiberbootEnabled
    } else {
        $originalValue = 0
    }
    
    # Create a backup file with the original value
    $backupPath = "$env:TEMP\FastBootSetting.txt"
    $originalValue | Out-File -FilePath $backupPath -Force
    
    # Enable Fast Startup
    try {
        # Ensure hibernation is enabled (required for Fast Startup)
        Start-Process -FilePath "powercfg.exe" -ArgumentList "/h on" -NoNewWindow -Wait
        
        # Enable Fast Startup in registry
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 1 -Type DWord -Force
        
        # Update power settings via Control Panel
        $powerCfg = Get-WmiObject -Namespace "root\cimv2\power" -Class Win32_PowerPlan -Filter "IsActive='True'"
        $powerGuid = $powerCfg.InstanceID.ToString().Replace("Microsoft:PowerPlan\{", "").Replace("}", "")
        
        # Check if hiberfil.sys exists and create it if necessary
        if (-not (Test-Path "$env:SystemDrive\hiberfil.sys")) {
            Write-Host "Configuring hibernation file..."
            Start-Process -FilePath "powercfg.exe" -ArgumentList "/hibernate on" -NoNewWindow -Wait
        }
        
        Write-Host "Windows Fast Startup has been enabled successfully." -ForegroundColor Green
        Write-Host "This setting will take effect after the next restart." -ForegroundColor Yellow
    }
    catch {
        Write-Host "Error enabling Windows Fast Startup: $_" -ForegroundColor Red
        return $false
    }
    
    return $true
}

function Perform-Undo {
    Write-Host "Disabling Windows Fast Startup feature..."
    
    # Check for backup file
    $backupPath = "$env:TEMP\FastBootSetting.txt"
    if (Test-Path $backupPath) {
        $originalValue = Get-Content -Path $backupPath
        
        try {
            # Convert string to integer
            $originalValue = [int]$originalValue
        }
        catch {
            # If conversion fails, assume it was disabled
            $originalValue = 0
        }
    } else {
        # If no backup file, assume it was disabled
        $originalValue = 0
    }
    
    # Restore original value
    try {
        # Disable Fast Startup in registry
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value $originalValue -Type DWord -Force
        
        # If we're disabling fast startup, we might want to keep hibernation enabled for other purposes
        # So we won't turn off hibernation automatically
        
        Write-Host "Windows Fast Startup has been disabled successfully." -ForegroundColor Green
        Write-Host "This setting will take effect after the next restart." -ForegroundColor Yellow
    }
    catch {
        Write-Host "Error disabling Windows Fast Startup: $_" -ForegroundColor Red
        return $false
    }
    
    # Remove backup file
    if (Test-Path $backupPath) {
        Remove-Item -Path $backupPath -Force
    }
    
    return $true
}

# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrator privileges. Please run as administrator." -ForegroundColor Red
    exit 1
}

# Main script
if ($Undo) {
    Perform-Undo
} else {
    Perform-Action
}
