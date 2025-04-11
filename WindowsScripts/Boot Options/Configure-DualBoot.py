# NAME: Configure Dual Boot
# DEVELOPER: MikeTheTech
# DESCRIPTION: Helps configure and manage dual-boot settings in Windows.
# UNDOABLE: Yes
# UNDO_DESC: Restores original dual-boot configuration settings.
#
# This script provides tools to configure and manage dual-boot settings

import os
import sys
import argparse
import subprocess
import re
import ctypes
import tempfile
import json
from datetime import datetime

# Check if running as administrator
def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

# Function to run bcdedit commands
def run_bcdedit(args):
    cmd = ["bcdedit"] + args
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {' '.join(cmd)}")
        print(f"Error message: {e.stderr}")
        return None

# Get the list of OS entries in the boot menu
def get_os_entries():
    output = run_bcdedit(["/enum", "firmware"])
    if not output:
        return []
    
    entries = []
    current_entry = {}
    in_entry = False
    
    for line in output.split("\n"):
        line = line.strip()
        
        if not line:
            if in_entry and current_entry:
                entries.append(current_entry)
                current_entry = {}
            in_entry = False
            continue
        
        if line.startswith("Windows Boot Loader"):
            in_entry = True
            current_entry = {"type": "Windows"}
            continue
            
        if not in_entry:
            continue
            
        if "identifier" in line.lower():
            current_entry["identifier"] = line.split("}", 1)[1].strip()
        elif "device" in line.lower():
            current_entry["device"] = line.split(" ", 1)[1].strip()
        elif "path" in line.lower():
            current_entry["path"] = line.split(" ", 1)[1].strip()
        elif "description" in line.lower():
            current_entry["description"] = line.split(" ", 1)[1].strip()
    
    # Add the last entry if it exists
    if in_entry and current_entry:
        entries.append(current_entry)
    
    return entries

# Backup current boot configuration
def backup_configuration():
    backup_file = os.path.join(tempfile.gettempdir(), "boot_config_backup.json")
    
    # Get current boot order
    default_output = run_bcdedit(["/default"])
    if default_output:
        default_id = default_output.split("{", 1)[1].split("}", 1)[0]
        default_id = "{" + default_id + "}"
    else:
        default_id = ""
    
    # Get timeout
    timeout_output = run_bcdedit(["/timeout"])
    if timeout_output:
        timeout = timeout_output.split(":", 1)[1].strip()
    else:
        timeout = ""
    
    # Get OS entries
    entries = get_os_entries()
    
    # Create backup data
    backup_data = {
        "timestamp": datetime.now().isoformat(),
        "default_id": default_id,
        "timeout": timeout,
        "entries": entries
    }
    
    # Save backup
    with open(backup_file, "w") as f:
        json.dump(backup_data, f, indent=2)
    
    print(f"Boot configuration backed up to {backup_file}")
    return True

# Restore boot configuration from backup
def restore_configuration():
    backup_file = os.path.join(tempfile.gettempdir(), "boot_config_backup.json")
    
    if not os.path.exists(backup_file):
        print("No backup file found. Cannot restore configuration.")
        return False
    
    try:
        with open(backup_file, "r") as f:
            backup_data = json.load(f)
        
        # Restore timeout
        if backup_data.get("timeout"):
            run_bcdedit(["/timeout", backup_data["timeout"]])
            print(f"Restored boot timeout to {backup_data['timeout']} seconds")
        
        # Restore default boot entry
        if backup_data.get("default_id"):
            run_bcdedit(["/default", backup_data["default_id"]])
            print(f"Restored default boot entry to {backup_data['default_id']}")
        
        print("Boot configuration restored successfully")
        return True
    except Exception as e:
        print(f"Error restoring boot configuration: {str(e)}")
        return False

def perform_action():
    if not is_admin():
        print("This script requires administrator privileges.")
        print("Please run as administrator.")
        return False
    
    # Backup current configuration
    print("Backing up current boot configuration...")
    backup_configuration()
    
    # Get current entries
    entries = get_os_entries()
    if not entries:
        print("No OS entries found in the boot configuration.")
        return False
    
    while True:
        print("\nDual Boot Configuration Manager")
        print("==============================")
        print("\nDetected operating systems:")
        
        for i, entry in enumerate(entries, 1):
            print(f"{i}. {entry.get('description', 'Unknown OS')}")
        
        print("\nOptions:")
        print("1. Change default OS")
        print("2. Modify boot timeout")
        print("3. Rename OS entry")
        print("4. Exit")
        
        choice = input("\nEnter your choice (1-4): ")
        
        if choice == "1":
            # Change default OS
            print("\nSelect the OS to boot by default:")
            for i, entry in enumerate(entries, 1):
                print(f"{i}. {entry.get('description', 'Unknown OS')}")
            
            os_choice = input("Enter the number of the OS (or 'c' to cancel): ")
            if os_choice.lower() == 'c':
                continue
                
            try:
                idx = int(os_choice) - 1
                if 0 <= idx < len(entries):
                    identifier = entries[idx].get("identifier")
                    if identifier:
                        run_bcdedit(["/default", identifier])
                        print(f"Default OS set to {entries[idx].get('description', 'Unknown OS')}")
                    else:
                        print("Could not determine the identifier for this OS entry.")
                else:
                    print("Invalid selection.")
            except ValueError:
                print("Invalid input. Please enter a number.")
        
        elif choice == "2":
            # Modify boot timeout
            current_timeout = run_bcdedit(["/timeout"])
            if current_timeout:
                current_timeout = current_timeout.split(":", 1)[1].strip()
                print(f"Current boot timeout is {current_timeout} seconds")
            
            new_timeout = input("Enter new timeout in seconds (3-30 recommended, 0 for no timeout): ")
            
            try:
                timeout_value = int(new_timeout)
                if timeout_value < 0:
                    print("Timeout cannot be negative.")
                    continue
                    
                run_bcdedit(["/timeout", new_timeout])
                print(f"Boot timeout set to {new_timeout} seconds")
            except ValueError:
                print("Invalid input. Please enter a number.")
        
        elif choice == "3":
            # Rename OS entry
            print("\nSelect the OS entry to rename:")
            for i, entry in enumerate(entries, 1):
                print(f"{i}. {entry.get('description', 'Unknown OS')}")
            
            os_choice = input("Enter the number of the OS (or 'c' to cancel): ")
            if os_choice.lower() == 'c':
                continue
                
            try:
                idx = int(os_choice) - 1
                if 0 <= idx < len(entries):
                    identifier = entries[idx].get("identifier")
                    current_name = entries[idx].get("description", "Unknown OS")
                    
                    if identifier:
                        new_name = input(f"Enter new name for '{current_name}': ")
                        if new_name:
                            run_bcdedit(["/set", identifier, "description", new_name])
                            print(f"OS entry renamed to '{new_name}'")
                            # Update local data
                            entries[idx]["description"] = new_name
                        else:
                            print("Name cannot be empty.")
                    else:
                        print("Could not determine the identifier for this OS entry.")
                else:
                    print("Invalid selection.")
            except ValueError:
                print("Invalid input. Please enter a number.")
        
        elif choice == "4":
            # Exit
            print("Exiting Dual Boot Configuration Manager.")
            break
        
        else:
            print("Invalid choice. Please try again.")
    
    return True

def perform_undo():
    if not is_admin():
        print("This script requires administrator privileges.")
        print("Please run as administrator.")
        return False
    
    print("Restoring original dual-boot configuration...")
    return restore_configuration()

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Configure Dual Boot Settings')
    parser.add_argument('--undo', action='store_true', help='Restore original dual-boot configuration')
    args = parser.parse_args()
    
    if args.undo:
        perform_undo()
    else:
        perform_action()

if __name__ == "__main__":
    main()
