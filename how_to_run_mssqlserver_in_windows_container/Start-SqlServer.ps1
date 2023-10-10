param(
    [Parameter(Mandatory = $false)]
    [string]$sa_password,

    [Parameter(Mandatory = $false)]
    [string]$attach_dbs
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$env:ACCEPT_EULA = 'Y'

Write-Verbose "Starting SQL Server"
Start-Service EventLog, MSSQLSERVER

Write-Verbose "Changing SA login credentials"
$sqlcmd = "ALTER LOGIN sa with password=" + "'" + $sa_password + "'" + ";ALTER LOGIN sa ENABLE;"
& sqlcmd -b -Q $sqlcmd
if ($LASTEXITCODE -ne 0) { exit($LASTEXITCODE) }

$attach_dbs_cleaned = $attach_dbs.TrimStart('\\').TrimEnd('\\')
$dbs = $attach_dbs_cleaned | ConvertFrom-Json

if ($null -ne $dbs -And $dbs.Length -gt 0) {
    Write-Verbose "Attaching $($dbs.Length) database(s)"

    Foreach ($db in $dbs) {
        $files = @();
        Foreach ($file in $db.dbFiles) {
            $files += "(FILENAME = N'$($file)')";
        }

        $files = $files -join ","
        $sqlcmd = "IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = '" + $($db.dbName) + "') BEGIN EXEC sp_detach_db [$($db.dbName)] END;CREATE DATABASE [$($db.dbName)] ON $($files) FOR ATTACH;"

        Write-Verbose "Invoke-Sqlcmd -Query $($sqlcmd)"
        & sqlcmd -b -Q $sqlcmd
        if ($LASTEXITCODE -ne 0) { exit($LASTEXITCODE) }
    }
}

Write-Verbose "SQL Server Started"

$lastCheck = (Get-Date).AddSeconds(-2)
while ($true) {
    Get-EventLog -LogName Application -Source "MSSQL*" -After $lastCheck | Select-Object TimeGenerated, EntryType, Message | Sort-Object TimeGenerated
    $lastCheck = Get-Date
    Start-Sleep -Seconds 2
}