##################################
# Configure TLS/HTTPS certificates
##################################

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] 
    $OpenSslPath
)

try {
    Push-Location (Join-Path $PSScriptRoot ..\certs)
    Write-Host "Generating certificates..." -ForegroundColor Green
    
    $certsDirectory = Join-Path $PSScriptRoot ..\certs
    Write-Host $certsDirectory
    $openssl = $OpenSslPath

    # Generate certificates (same for both OS)
    & $openssl req -x509 -config (Join-Path $certsDirectory openssl-ca-generate.cnf) -days 365 -newkey rsa:4096 -sha256 -nodes -out (Join-Path $certsDirectory cacert.pem) -outform PEM
    & $openssl x509 -in (Join-Path $certsDirectory cacert.pem) -text -noout
    & $openssl x509 -purpose -in (Join-Path $certsDirectory cacert.pem) -inform PEM
    & $openssl req -config (Join-Path $certsDirectory openssl-server.cnf) -newkey rsa:2048 -sha256 -nodes -out (Join-Path $certsDirectory servercert.csr) -outform PEM
    & $openssl req -text -noout -verify -in (Join-Path $certsDirectory servercert.csr)
    & $openssl ca -config (Join-Path $certsDirectory openssl-ca-sign.cnf) -policy signing_policy -extensions signing_req -out (Join-Path $certsDirectory servercert.pem) -infiles (Join-Path $certsDirectory servercert.csr)
    & $openssl x509 -in (Join-Path $certsDirectory servercert.pem) -text -noout
    & $openssl pkcs12 -export -out (Join-Path $certsDirectory servercert.pfx) -inkey (Join-Path $certsDirectory serverkey.pem) -in (Join-Path $certsDirectory servercert.pem)

    # OS-specific certificate installation
    if ($IsMacOS) {
        # Install CA certificate to system keychain
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain (Join-Path $certsDirectory cacert.pem)
        
        # Install server certificate to system keychain
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain (Join-Path $certsDirectory servercert.pem)
    }
    else {
        # Windows certificate installation
        $importParamsCA = @{
            FilePath          = (Join-Path $certsDirectory cacert.pem)
            CertStoreLocation = 'Cert:\LocalMachine\Root'
        }
        Import-Certificate @importParamsCA

        $importParamsCert = @{
            FilePath          = (Join-Path $certsDirectory servercert.pem)
            CertStoreLocation = 'Cert:\LocalMachine\Root'
        }
        Import-Certificate @importParamsCert
    }
}
catch {
    Write-Host "An error occurred while attempting to generate TLS certificate: $_" -ForegroundColor Red
}
finally {
    Pop-Location
}
