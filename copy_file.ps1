###########################################################################
### Script Name: copy_file.ps1
### Description: This script copies a file(s) to multiple workstations listed in a CSV file.
### Author: Adam Gelhausen
### Date: 2025-04-11
### Sudo Code:
    # 1. Import a CSV file containing workstation and file information. (WorkstationName, SourcePath, DestinationPath)
    # 2. Iterate through each workstation in the CSV.
    # 3. For each workstation, copy a file to a specified location.
    # 4. Log success or failure of the operation.
    # 5. End of script.
###########################################################################

# Import the CSV file
$workstations = Import-Csv -Path ".\workstation_list.csv"

# Confirm if script has been run with admin privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script must be run as an administrator. Script execution cancelled."
    exit
}

# Prompt to confirm script execution
$confirmation = Read-Host "This script will copy a file(s) to each workstation as defined in the controlling CSV. Do you want to continue? (Y/N)"
if ($confirmation -ne 'Y') {
    Write-Host "Script execution cancelled."
    exit
}

# Iterate through each item in the CSV
foreach ($workstation in $workstations) {
    # Define the source path for the file
    $sourcePath = $workstation.SourcePath

    # Define the destination path for the file
    $destinationPath = "\\$($workstation.WorkstationName)\$($workstation.DestinationPath)"

    # Copy the file to the destination path
    Copy-Item -Path $sourcePath -Destination $destinationPath -Force -ErrorAction Stop
    if ($?) {
        Write-Host "Successfully copied $($workstation.SourcePath) to $($destinationPath)"
    } else {
        Write-Host "Failed to copy $($workstation.SourcePath) to $($destinationPath)"
    }
}