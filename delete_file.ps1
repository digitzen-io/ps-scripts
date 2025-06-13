###########################################################################
### Script Name: delete_file.ps1
### Description: This script deletes a file(s) from multiple workstations listed in a CSV file.
### Author: Adam Gelhausen
### Date: 2025-04-11
### Sudo Code:
    # 1. Import a CSV file containing workstation and file information. (WorkstationName, DestinationPath)
    # 2. Iterate through each workstation in the CSV.
    # 3. For each workstation, delete a file from the specified location.
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
$confirmation = Read-Host "This script will delete a file(s) from each workstation. Do you want to continue? (Y/N)"
if ($confirmation -ne 'Y') {
    Write-Host "Script execution cancelled."
    exit
}

# Iterate through each item in the CSV
foreach ($workstation in $workstations) {
    # Define the path for the DLL file
    $destinationPath = "\\$($workstation.WorkstationName)\$($workstation.DestinationPath)"

    # Copy the DLL file to the destination path
    Remove-Item -Path $destinationPath -Force -ErrorAction Stop
    if ($?) {
        Write-Host "Successfully removed $($workstation.DestinationPath) from $($workstation.WorkstationName)"
    } else {
        Write-Host "Failed to remove $($workstation.DestinationPath) from $($workstation.WorkstationName)"
    }
}