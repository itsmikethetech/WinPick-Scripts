# NAME: Python Script Template
# DEVELOPER: MikeTheTech
# LINK: https://github.com/itsmikethetech
# DESCRIPTION: A template for creating new Python scripts with undo capability
# UNDOABLE: Yes
# UNDO_DESC: Reverts any changes made by this script
#
# This is a Python script template with undo capability

import os
import sys
import argparse
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def main():
    """Main entry point for the script"""
    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description='Template script with undo capability'
    )
    parser.add_argument('--undo', action='store_true', 
                        help='Undo the changes made by this script')
    parser.add_argument('--verbose', action='store_true',
                        help='Enable verbose output')
    args = parser.parse_args()
    
    # Set log level based on verbose flag
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    
    # Execute the appropriate action
    try:
        if args.undo:
            logger.info("Starting undo operation")
            perform_undo()
            logger.info("Undo operation completed successfully")
        else:
            logger.info("Starting main operation")
            perform_action()
            logger.info("Main operation completed successfully")
    except Exception as e:
        logger.error(f"An error occurred: {str(e)}")
        return 1
    
    return 0

def perform_action():
    """Perform the main action of the script"""
    logger.debug("Executing perform_action()")
    
    # Your main code here
    # Example:
    logger.info("Performing main action...")
    
    # Create a backup if needed
    create_backup()
    
    # Example action
    logger.info("Action completed")

def perform_undo():
    """Undo the changes made by the script"""
    logger.debug("Executing perform_undo()")
    
    # Your undo code here
    # Example:
    logger.info("Performing undo action...")
    
    # Restore from backup if needed
    restore_backup()
    
    # Example undo action
    logger.info("Undo operation completed")

def create_backup():
    """Create a backup before making changes"""
    logger.debug("Creating backup")
    # Implement backup logic here
    # Example:
    # with open('original_file.txt', 'r') as src, open('original_file.txt.bak', 'w') as bak:
    #     bak.write(src.read())

def restore_backup():
    """Restore from backup"""
    logger.debug("Restoring from backup")
    # Implement restore logic here
    # Example:
    # if os.path.exists('original_file.txt.bak'):
    #     with open('original_file.txt.bak', 'r') as bak, open('original_file.txt', 'w') as dest:
    #         dest.write(bak.read())
    #     os.remove('original_file.txt.bak')

if __name__ == "__main__":
    sys.exit(main())
