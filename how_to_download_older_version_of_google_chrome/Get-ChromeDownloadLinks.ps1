[CmdletBinding()]
param
(
    [Parameter(ValueFromPipeline = $true, HelpMessage = 'Chrome Version (Mac >= 94, Win >= 97)')]
    [String]$ChromeVersion = '100'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$returnedResult = New-Object PSObject -Property @{
    'Win x64' = @()
    'Win x32' = @()
    'Mac Silicon' = @()
    'Mac Intel' = @()
}


function Get-DownloadLinks($Platform, $Xml) {
    $webRequest = @{
        Method    = 'Post'
        Uri       = 'https://tools.google.com/service/update2'
        Headers   = @{
            'Content-Type' = 'application/x-www-form-urlencoded'
            'X-Goog-Update-Interactivity' = 'fg'
        }
        Body      = $Xml
    }

    $result = Invoke-WebRequest @webRequest -UseBasicParsing
    $contentXml = [xml]$result.Content
    $status = $contentXml.response.app.updatecheck.status
    if ($status -eq 'ok') {
        $package = $contentXml.response.app.updatecheck.manifest.packages.package
        $urls = $contentXml.response.app.updatecheck.urls.url | ForEach-Object { $_.codebase + $package.name }
        Write-Host "--- Chrome $platform found. Hash=$($package.hash) Hash_sha256=$($package.hash_sha256)). ---"
        Write-Host $urls
		$returnedResult.$platform = $urls
    }
    else {
        Write-Host "Chrome not found (status: $status)"
    }
}

$requestId = ([String][Guid]::NewGuid()).ToUpper()
$sessionId = ([String][Guid]::NewGuid()).ToUpper()

$xmlWin64 = @"
<?xml version="1.0" encoding="UTF-8"?>
<request protocol="3.0" updater="Omaha" updaterversion="1.3.36.111" shell_version="1.3.36.111"
    ismachine="1" sessionid="{$sessionId}" installsource="update3web-ondemand"
    requestid="{$requestId}" dedup="cr" domainjoined="0">
    <hw physmemory="4" sse="1" sse2="1" sse3="1" ssse3="1" sse41="1" sse42="1" avx="1" />
    <os platform="win" version="10.0" sp="" arch="x64" />
    <app appid="{8A69D345-D564-463C-AFF1-A69D9E530F96}" version="5.0.375" nextversion=""
        ap="x64-stable-statsdef_0" lang="" brand="GCEB" client="" installage="0">
        <updatecheck targetversionprefix="$ChromeVersion"/>
    </app>
</request>
"@

Get-DownloadLinks -Platform 'Win x64' -Xml $xmlWin64

$requestId = ([String][Guid]::NewGuid()).ToUpper()
$sessionId = ([String][Guid]::NewGuid()).ToUpper()

$xmlWin32 = @"
<?xml version="1.0" encoding="UTF-8"?>
<request protocol="3.0" updater="Omaha" updaterversion="1.3.36.111" shell_version="1.3.36.111"
    ismachine="1" sessionid="{$sessionId}" installsource="update3web-ondemand"
    requestid="{$requestId}" dedup="cr" domainjoined="0">
    <hw physmemory="4" sse="1" sse2="1" sse3="1" ssse3="1" sse41="1" sse42="1" avx="1" />
    <os platform="win" version="10.0" sp="" arch="x86" />
    <app appid="{8A69D345-D564-463C-AFF1-A69D9E530F96}" version="5.0.375" nextversion=""
        ap="x86-stable-statsdef_0" lang="" brand="GCEB" client="" installage="0">
        <updatecheck targetversionprefix="$ChromeVersion"/>
    </app>
</request>
"@

Get-DownloadLinks -Platform 'Win x32' -Xml $xmlWin32

$requestId = ([String][Guid]::NewGuid()).ToUpper()
$sessionId = ([String][Guid]::NewGuid()).ToUpper()

$xmlMacSilicon = @"
<?xml version="1.0" encoding="UTF-8"?>
<request protocol="3.0" version="KeystoneAdmin-0" ismachine="0"
    requestid="{$requestId}" dedup="cr"
    sessionid="{$sessionId}" installsource="ondemandupdate">
    <os platform="mac" version="13.1" arch="arm64e" sp="13.1.0_arm64e"></os>
    <app appid="com.google.Chrome" version="5.0.375" cohort="1:1y5:" cohortname="Stable"
        lang="en-us" installage="75" ap="universal" brand="GGRO" signed="1">
        <updatecheck targetversionprefix="$ChromeVersion"></updatecheck>
    </app>
</request>
"@

Get-DownloadLinks -Platform 'Mac Silicon' -Xml $xmlMacSilicon

$requestId = ([String][Guid]::NewGuid()).ToUpper()
$sessionId = ([String][Guid]::NewGuid()).ToUpper()

$xmlMacIntel = @"
<?xml version="1.0" encoding="UTF-8"?>
<request protocol="3.0" version="KeystoneAdmin-0" ismachine="0"
    requestid="{$requestId}" dedup="cr"
    sessionid="{$sessionId}" installsource="ondemandupdate">
    <os platform="mac" version="13.2" arch="x86_64h" sp="13.2.1_x86_64h"></os>
    <app appid="com.google.Chrome" version="5.0.375" cohort="1:1y5:" cohortname="Stable"
        lang="en-us" installage="1166" ap="universal" brand="GGLG" signed="1">
        <updatecheck targetversionprefix="$ChromeVersion"></updatecheck>
    </app>
</request>
"@

Get-DownloadLinks -Platform 'Mac Intel' -Xml $xmlMacIntel

Return $returnedResult
