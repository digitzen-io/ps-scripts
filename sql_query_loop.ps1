###########################################################################
### Script Name: sql_query_loop.ps1
### Description: This script runs a SQL query at specified intervals and exports the results to a CSV file.
### Author: Adam Gelhausen
### Date: 2025-04-25
### Sudo Code:
    #  1. Define a list of minutes and seconds to check.
    #  2. Load a SQL query from a file.
    #  3. Define server, database, username, and password.
    #  4. Build the connection string for SQL Server.
    #  5. Create a SqlConnection object.
    #  6. Begin an infinite loop to check the time every second.
    #  7. Check if the current time matches the specified minute and second.
    #  8. If it matches, open the connection to SQL Server.
    #  9. Execute the SQL query and export the results to a CSV file.
    # 10. Handle any exceptions that occur during execution.
    # 11. Close the connection to SQL Server.
    # 12. Repeat the process every second until the script is stopped.
    # 13. End of script.
### Notes:
    # - The script is designed to run indefinitely, checking the time every second.
    # - The SQL query is loaded from a file, allowing for easy modification without changing the script.
    # - The output CSV file is named with a timestamp to avoid overwriting previous results.
###########################################################################

# Define the list of minutes and seconds to check
# This script will run every 5 minutes at the 59th second of the minute
$minuteCheckList = 4, 9, 14, 19, 24, 29, 34, 39, 44, 49, 54, 59
$secondCheckList = 59

# Define server, database, username, and password
$serverName = "your_server_name"
$databaseName = "your_database_name"
# Uncomment the following lines if using SQL authentication
# $userName = "your_username"
# $password = "your_password"

# Build the connection string
# For Windows Authentication
$connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=True"
# Uncomment the following line if using SQL authentication
# $connectionString = "Server=$serverName;Database=$databaseName;User ID=$userName;Password=$password;"

# Create a SqlConnection object
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)

# Load the SQL query from a file
$sqlQuery = Get-Content -Path ".\sql_query.sql" -Raw
if (-not $sqlQuery) {
    Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff") | Error | SQL query file is empty or not found. Program will exit." -ForegroundColor Red
    exit
}

Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff") | Info | Script successfully initialized, beginning execution..."

# Begin an infinite loop to check the time every second
while ($true) {
    $currentTime = Get-Date
    $currentMinute = $currentTime.Minute
    $currentSecond = $currentTime.Second

    # Check if the current time matches the specified minute and second
    if (($currentMinute -in $minuteCheckList) -and ($currentSecond -in $secondCheckList)) {
        try {
            # Open the connection
            $connection.Open()
            Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff") | Info | Successfully connected to SQL Server!"
        
            # Execute the SQL query and export the results to a CSV file
            $command = New-Object System.Data.SqlClient.SqlCommand($sqlQuery, $connection)
            $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
            $dataSet = New-Object System.Data.DataSet
            $adapter.Fill($dataSet) | Out-Null
            $dataSet.Tables[0] | Export-Csv -Path ".\output_$($currentTime.ToString("yyyy-MM-dd_HH-mm-ss")).csv" -NoTypeInformation -Force
            Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff") | Info | SQL query executed successfully and output saved to output_$($currentTime.ToString("yyyy-MM-dd_HH-mm-ss")).csv."
        }
        catch {
            Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff") | Error | Unexpected error encountered! The exception message was: $($_.Exception.Message)" -ForegroundColor Red
        }
        finally {
            # Close the connection
            if ($connection.State -eq "Open") {
                $connection.Close()
                Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff") | Info | Connection to SQL Server closed."
            }
        }
    }

    Start-Sleep -Seconds 1
}