# INI

---
Module: INI_Legacy.psm1
Updated: 11/02/2018
Author: Configuration Management
Version: 1.0

This module loads and processes an ini file. Use the function Get-IniFile to input the file contents into a key\value array (hash table).
The **Legacy** version is for POSReady 2009 or 7.

Use the `Get-Help` function to get information on a particular function.

NOTE: When creating a modular function, Powershell prefers to use certain verbs. Use `Get-Verb` to see a list of preferred verbs.

Disclosure:
This module is transposed from the following script: [Get-IniContent](https://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91)

All functions will be described in detail. All credit goes to the original author, Oliver Lipkau <oliver@lipkau.net>.

## Installation

```powershell
Import-Module <path>\INI.psm1
```

## Syntax

```powershell
Get-IniFile [-File] <path>
```

```powershell
Write-IniFile [-Append] [-File] <path> [-Hashtable] <hashtable_object>
```

## Examples

```powershell
$iniFile = Get-IniFile example.ini

$iniFile.section.key = "New Value"

Write-IniFile example.ini $iniFile
```

## Error Codes

(-1): The script could not be initialized.
Get-IniFile - INI_PROCESSING_FAILED (4000): Could not process or load the ini file
Write-IniFile - FILE_CREATE_FAILED (4000): Could not load or create a file
Write-IniFile - INI_WRITE_FAILED (4001): Failed to write to the ini file

## References

[Usage Syntax](https://stackoverflow.com/questions/9725675/is-there-a-standard-format-for-command-line-shell-help-text)
[CmdletBinding](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute?view=powershell-6)
[Advanced Function Parameters](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-6)
[Anatomy of a PowerShell Advanced Function](https://www.petri.com/anatomy-powershell-advanced-function)
[Script Modules](https://stackoverflow.com/questions/27138483/how-can-i-re-use-import-script-code-in-powershell-scripts)
