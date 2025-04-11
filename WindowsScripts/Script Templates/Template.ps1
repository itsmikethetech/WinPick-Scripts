# NAME: PowerShell Script Template
# DEVELOPER: MikeTheTech
# LINK: https://github.com/itsmikethetech
# DESCRIPTION: A template for creating new PowerShell scripts with undo capability
# UNDOABLE: Yes
# UNDO_DESC: Reverts any changes made by this script
#
# This is a PowerShell script template with undo capability

param (
    [switch]$Undo,
    [switch]$Verbose
)

# Set up logging
$LogFile = Join-Path $PSScriptRoot "$(Split-Path -Leaf $PSCommandPath).log"
$VerbosePreference = if ($Verbose) { "Continue" } else { "SilentlyContinue" }

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp - $Level - $Message"
    
    Write-Host $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}

function Create-Backup {
    Write-Verbose "Creating backup"
    # Implement backup logic here
    # Example:
    # Copy-Item -Path "original-file.txt" -Destination "original-file.txt.bak" -Force
}

function Restore-FromBackup {
    Write-Verbose "Restoring from backup"
    # Implement restore logic here
    # Example:
    # if (Test-Path "original-file.txt.bak") {
    #     Copy-Item -Path "original-file.txt.bak" -Destination "original-file.txt" -Force
    #     Remove-Item -Path "original-file.txt.bak" -Force
    # }
}

function Perform-Action {
    Write-Log "Performing main action..."
    
    # Create a backup before making changes
    Create-Backup
    
    # Your main code here
    # Example:
    Write-Verbose "Executing main operation..."
    
    Write-Log "Action completed"
}

function Perform-Undo {
    Write-Log "Performing undo action..."
    
    # Restore from backup
    Restore-FromBackup
    
    # Your undo code here
    # Example:
    Write-Verbose "Executing undo operation..."
    
    Write-Log "Undo completed"
}

# Main script execution
try {
    if ($Undo) {
        Write-Log "Starting undo operation" -Level "INFO"
        Perform-Undo
        Write-Log "Undo operation completed successfully" -Level "INFO"
    } else {
        Write-Log "Starting main operation" -Level "INFO"
        Perform-Action
        Write-Log "Main operation completed successfully" -Level "INFO"
    }
    
    exit 0
} catch {
    Write-Log "An error occurred: $_" -Level "ERROR"
    Write-Log $_.Exception.StackTrace -Level "ERROR"
    exit 1
}
