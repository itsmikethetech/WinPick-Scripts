# NAME: Remove Third-Party Bloatware
# DEVELOPER: MikeTheTech
# DESCRIPTION: Identifies and removes common third-party bloatware applications.
# UNDOABLE: No
# UNDO_DESC: This script cannot automatically reinstall removed applications.
# LINK: https://www.patreon.com/c/mikethetech
# This script identifies and helps remove common third-party bloatware applications

import os
import sys
import argparse
import subprocess
import winreg
import ctypes
from datetime import datetime

# Check if running as administrator
def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

# Get list of installed programs from registry
def get_installed_programs():
    programs = []
    
    # Check both 32-bit and 64-bit registry locations
    registry_paths = [
        r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        r"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    ]
    
    for reg_path in registry_paths:
        try:
            registry = winreg.ConnectRegistry(None, winreg.HKEY_LOCAL_MACHINE)
            key = winreg.OpenKey(registry, reg_path)
            
            for i in range(0, winreg.QueryInfoKey(key)[0]):
                try:
                    subkey_name = winreg.EnumKey(key, i)
                    subkey = winreg.OpenKey(key, subkey_name)
                    
                    try:
                        name = winreg.QueryValueEx(subkey, "DisplayName")[0]
                        uninstall_string = winreg.QueryValueEx(subkey, "UninstallString")[0]
                        
                        programs.append({
                            "name": name,
                            "uninstall_string": uninstall_string
                        })
                    except (WindowsError, IndexError):
                        pass
                        
                    winreg.CloseKey(subkey)
                except (WindowsError, IndexError):
                    pass
                    
            winreg.CloseKey(key)
            winreg.CloseKey(registry)
        except WindowsError:
            pass
            
    return programs

# List of common bloatware keywords
bloatware_keywords = [
    "trial", "demo", "mcafee", "norton", "antivirus", "avast", "avg", 
    "adware", "optimizer", "booster", "cleaner", "speedup", "browser toolbar",
    "offer", "coupon", "shopping assistant", "pc health", "support assistant",
    "helper", "webadvisor", "pcmatic", "driver update"
]

def perform_action():
    print("Scanning for third-party bloatware applications...")
    
    if not is_admin():
        print("WARNING: This script should be run as administrator for full functionality.")
        print("Some operations may fail without administrative privileges.")
        print()
    
    # Get installed programs
    programs = get_installed_programs()
    potential_bloatware = []
    
    # Find potential bloatware based on keywords
    for program in programs:
        program_name = program["name"].lower()
        
        for keyword in bloatware_keywords:
            if keyword.lower() in program_name:
                potential_bloatware.append(program)
                break
    
    if not potential_bloatware:
        print("No potential bloatware applications found.")
        return
    
    # Create log directory if it doesn't exist
    log_dir = os.path.join(os.environ["TEMP"], "BloatwareRemoval")
    os.makedirs(log_dir, exist_ok=True)
    
    # Log file
    log_file = os.path.join(log_dir, f"removal_log_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt")
    
    # Display potential bloatware and allow user to select for removal
    print("\nPotential bloatware applications found:")
    print("---------------------------------------")
    
    for i, program in enumerate(potential_bloatware, 1):
        print(f"{i}. {program['name']}")
    
    print("\nSelect applications to remove (comma-separated numbers, or 'all' for all, or 'q' to quit):")
    selection = input("> ")
    
    if selection.lower() == 'q':
        print("Operation cancelled.")
        return
    
    selected_indices = []
    if selection.lower() == 'all':
        selected_indices = list(range(1, len(potential_bloatware) + 1))
    else:
        try:
            selected_indices = [int(idx.strip()) for idx in selection.split(",")]
        except ValueError:
            print("Invalid input. Operation cancelled.")
            return
    
    # Remove selected applications
    with open(log_file, "w") as log:
        log.write(f"Bloatware Removal Log - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log.write("=" * 50 + "\n\n")
        
        for idx in selected_indices:
            if 1 <= idx <= len(potential_bloatware):
                program = potential_bloatware[idx-1]
                print(f"\nAttempting to remove: {program['name']}")
                log.write(f"Removing: {program['name']}\n")
                log.write(f"Uninstall command: {program['uninstall_string']}\n")
                
                try:
                    # Most uninstall strings are either direct executables or use msiexec
                    if "msiexec" in program['uninstall_string'].lower():
                        # For MSI-based uninstallers, add the quiet switch
                        command = program['uninstall_string'] + " /quiet /norestart"
                        subprocess.run(command, shell=True, check=True)
                    else:
                        # For other uninstallers, just run the command
                        subprocess.run(program['uninstall_string'], shell=True, check=True)
                        
                    print(f"  Successfully initiated uninstall for {program['name']}")
                    log.write(f"Status: Uninstall initiated successfully\n\n")
                except subprocess.SubprocessError as e:
                    print(f"  Failed to uninstall {program['name']}: {str(e)}")
                    log.write(f"Status: Failed - {str(e)}\n\n")
            else:
                print(f"Invalid selection: {idx}")
    
    print(f"\nOperation completed. Log saved to: {log_file}")
    print("\nNote: Some uninstallers may have launched in separate windows.")
    print("Please complete any pending uninstall wizards that may have opened.")

def perform_undo():
    print("This script cannot automatically reinstall removed applications.")
    print("Please check the removal logs in %TEMP%\\BloatwareRemoval\\ for a list of removed applications.")
    print("You will need to manually reinstall any applications you wish to restore.")

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Remove Third-Party Bloatware')
    parser.add_argument('--undo', action='store_true', help='Show undo information')
    args = parser.parse_args()
    
    if args.undo:
        perform_undo()
    else:
        perform_action()

if __name__ == "__main__":
    main()
