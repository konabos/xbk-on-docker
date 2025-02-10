param(
    [Parameter()]
    [switch]$Init
)

Import-Module -Name (Join-Path $PSScriptRoot ".\logo")
Import-Module -Name (Join-Path $PSScriptRoot ".\tools\util")
Show-Start

#----------------------------------------------------------
## check docker daemon is running
#----------------------------------------------------------

if (-Not (docker ps)) {
    Write-Host "Unable to connect to Docker. Are you sure the Docker daemon is running?" -ForegroundColor Red
    Break
}

#----------------------------------------------------------
## clean up
#----------------------------------------------------------

docker system prune -f

#----------------------------------------------------------
## load variables
#----------------------------------------------------------

$applicationHost = Get-EnvVar -Key APPLICATION_HOST
$kenticoProjectType = Get-EnvVar -Key KENTICO_PROJECT_TYPE
$kenticoAdminPassword = Get-EnvVar -Key KENTICO_ADMIN_PASSWORD
$mssqlServer = Get-EnvVar -Key MSSQL_SERVER
$mssqlUser = Get-EnvVar -Key MSSQL_USER
$mssqlPassword = Get-EnvVar -Key MSSQL_PASSWORD
$mssqlDatabase = Get-EnvVar -Key MSSQL_DATABASE

$licenseFileName = Get-EnvVar -Key LICENSE_FILE_NAME
# Get OpenSSL path based on OS
if ($IsMacOS) {
    $opensslPath = "openssl"  # On macOS, OpenSSL is typically in PATH
} else {
    $opensslPath = Get-EnvVar -Key OPENSSL_EXE_PATH  # Windows needs explicit path
}

#----------------------------------------------------------
## check traefik ssl certs present
#----------------------------------------------------------

if (-not (Test-Path .\certs\servercert.pem)) {
    .\tools\mkcert.ps1 -OpenSslPath $opensslPath
}

#----------------------------------------------------------
## check if user override env file exists
#----------------------------------------------------------

Read-UserEnvFile

#----------------------------------------------------------
## start docker
#----------------------------------------------------------

docker compose up -d

if ($Init) {
    Push-Location (Join-Path $PSScriptRoot ..\src)

    Write-Host "Instalation of kentico begins ..." -ForegroundColor Green 
    dotnet new uninstall kentico.xperience.templates
    dotnet new install kentico.xperience.templates --force -v=q
    dotnet new $kenticoProjectType -n xbk --force

    $licensePath = Join-Path (Get-Location).Path ".." $licenseFileName
    dotnet kentico-xperience-dbmanager -- -s $mssqlServer -d $mssqlDatabase -u $mssqlUser -p $mssqlPassword -a $kenticoAdminPassword --hash-string-salt "hash_string_salt" --license-file $licensePath --recreate-existing-database

    New-Item "appsettings.Docker.json" -Force -ItemType File -Value "{`"ConnectionStrings`":{`"CMSConnectionString`":`"Data Source=mssql,1433;Initial Catalog=xbk;Integrated Security=False;Persist Security Info=False;User ID=$mssqlUser;Password=$mssqlPassword;Connect Timeout=60;Encrypt=False;Current Language=English;`"}}"
    New-Item "appsettings.Development.json" -Force -ItemType File -Value "{`"ConnectionStrings`":{`"CMSConnectionString`":`"Data Source=localhost,1433;Initial Catalog=xbk;Integrated Security=False;Persist Security Info=False;User ID=$mssqlUser;Password=$mssqlPassword;Connect Timeout=60;Encrypt=False;Current Language=English;`"}}"


    dotnet publish xbk.csproj -c Release -o "..\docker\data\website"

    Pop-Location
}

Wait-SiteResponsive

Write-Host "`n`nDone... opening https://$($applicationHost)" -ForegroundColor DarkGray
Start-Process "https://$applicationHost"