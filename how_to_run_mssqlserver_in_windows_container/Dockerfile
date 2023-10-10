# escape=`
ARG WIN_VERSION=ltsc2019
FROM mcr.microsoft.com/windows/servercore:${WIN_VERSION}

ARG SQL_VERSION=2022 `
    SQL_2019_EXE_URL='https://download.microsoft.com/download/8/4/c/84c6c430-e0f5-476d-bf43-eaaa222a72e0/SQLServer2019-DEV-x64-ENU.exe' `
    SQL_2019_BOX_URL='https://download.microsoft.com/download/8/4/c/84c6c430-e0f5-476d-bf43-eaaa222a72e0/SQLServer2019-DEV-x64-ENU.box' `
    SQL_2022_EXE_URL='https://download.microsoft.com/download/3/8/d/38de7036-2433-4207-8eae-06e247e17b25/SQLServer2022-DEV-x64-ENU.exe' `
    SQL_2022_BOX_URL='https://download.microsoft.com/download/3/8/d/38de7036-2433-4207-8eae-06e247e17b25/SQLServer2022-DEV-x64-ENU.box'

ENV sa_password="PleaseChangeMe!" `
    attach_dbs="[]"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY Start-SqlServer.ps1 /

WORKDIR /

RUN $SqlExeUrl = if ($env:SQL_VERSION -eq '2019') { $env:SQL_2019_EXE_URL } else { $env:SQL_2022_EXE_URL }; `
    $SqlBoxUrl = if ($env:SQL_VERSION -eq '2019') { $env:SQL_2019_BOX_URL } else { $env:SQL_2022_BOX_URL }; `
    Invoke-WebRequest -Uri $SqlExeUrl -OutFile C:\SQL.exe; `
    Invoke-WebRequest -Uri $SqlBoxUrl -OutFile C:\SQL.box; `
    Start-Process -Wait -FilePath C:\SQL.exe -ArgumentList /qs, /x:setup; `
    C:\setup\setup.exe /q /ACTION=Install /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=1 /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS /SQLMAXDOP=1 /SQLBACKUPDIR='C:\Server\MSSQL\Backup' /SQLUSERDBDIR='C:\Server\MSSQL\DB' /SQLUSERDBLOGDIR='C:\Server\MSSQL\DB'; `
    Remove-Item C:\SQL.exe, C:\SQL.box, C:\setup -Recurse -Force; `
    Stop-Service MSSQLSERVER; `
    $SqlNumber = if ($env:SQL_VERSION -eq '2019') { 15 } else { 16 }; `
    Set-ItemProperty -path ('HKLM:\software\microsoft\microsoft sql server\mssql' + $SqlNumber + '.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall') -Name tcpdynamicports -Value ''; `
    Set-ItemProperty -path ('HKLM:\software\microsoft\microsoft sql server\mssql' + $SqlNumber + '.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall') -Name tcpport -Value 1433; `
    Set-ItemProperty -path ('HKLM:\software\microsoft\microsoft sql server\mssql' + $SqlNumber + '.MSSQLSERVER\mssqlserver\') -Name LoginMode -Value 2

HEALTHCHECK CMD [ "sqlcmd", "-Q", "select 1" ]

CMD .\Start-SqlServer -sa_password $env:sa_password -attach_dbs \"$env:attach_dbs\" -Verbose
