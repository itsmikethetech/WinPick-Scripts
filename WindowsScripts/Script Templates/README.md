# Script Templates

This directory contains template scripts to help you create new scripts for the WinPick application. These templates follow the standardized format required by the application to properly display script information and support undo functionality.

## Available Templates

- **Template.py** - Python script template
- **Template.ps1** - PowerShell script template
- **Template.bat** - Batch script template

## Metadata Format

All scripts should include metadata in the header comments with the following format:

### For Python and PowerShell scripts:
```
# NAME: Friendly Script Name
# DESCRIPTION: Detailed description of what the script does
# UNDOABLE: Yes/No
# UNDO_DESC: Description of what the undo action does (if applicable)
```

### For Batch scripts:
```
:: NAME: Friendly Script Name
:: DESCRIPTION: Detailed description of what the script does
:: UNDOABLE: Yes/No
:: UNDO_DESC: Description of what the undo action does (if applicable)
```

## Undo Functionality

If your script supports undo functionality (`UNDOABLE: Yes`), it should:

1. Include an implementation for the undo action
2. Accept command line parameters to trigger the undo action:
   - Python: `--undo` flag
   - PowerShell: `-Undo` switch
   - Batch: `undo` as the first parameter

## Best Practices

1. Always create backups of files or settings before modifying them
2. Include proper error handling and logging
3. Display clear progress messages to the user
4. For complex operations, consider implementing a dry-run mode
5. Test your script thoroughly, including the undo functionality
6. Document any prerequisites or limitations in the description

## Creating a New Script

You can create new scripts either by:

1. Copying and modifying one of these templates
2. Using the "New Script" button in the WinPick application
