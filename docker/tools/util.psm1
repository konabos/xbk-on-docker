function Get-EnvVar {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Key
  )

  select-string -Path ".env" -Pattern "^$Key=(.+)$" | % { $_.Matches.Groups[1].Value }
}


function Read-UserEnvFile {
  param(
    [Parameter()]
    [string] $EnvFile = ".env.user"
  )

  if (Test-Path $EnvFile) {
    Write-Host "User specific .env file found. Starting Docker with custom user settings." -ForegroundColor Green
    Write-Host "Variable overrides:-" -ForegroundColor Yellow

    Get-Content $EnvFile | Where-Object { $_ -notmatch '^#.*' -and $_ -notmatch '^\s*$' } | ForEach-Object {
      $var, $val = $_.trim().Split('=')
      Write-Host "  $var=$val" -ForegroundColor Yellow
      Set-Item -Path "env:$($var)" -Value $val
    }
  }
}

function Write-Animation {
  param(
    [int]$i,
    [string[]]$colors
  )
  
  if ($IsMacOS) {
    Write-Host "." -NoNewline -ForegroundColor $colors[$i % 6]
  } else {
    $frames = "(>'-')>", "^('-')^", "<('-'<)", "^('-')^"
    Write-Host "`r`t$($frames[$i % 4])" -NoNewline -ForegroundColor $colors[$i % 6]
  }
}

function Wait-SiteResponsive {
  param(
    [Parameter()]
    [string] $EndpointUrl = "http://localhost:8080/api/http/routers/kentico@docker"
  )

  Write-Host "Waiting for website's container to become available..." -ForegroundColor Green
  $startTime = Get-Date
  $i = 0
  $colors = "Red", "Yellow", "Green", "Cyan", "Blue", "Magenta"

  do {
    try {
      $status = Invoke-RestMethod $EndpointUrl
    }
    catch {
      if ($_.Exception.Response.StatusCode.value__ -ne "404") {
        throw
      }
    }

    Write-Animation -i $i -colors $colors
    Start-Sleep -Milliseconds 250
    $i++
  } while ($status.status -ne "enabled" -and $startTime.AddSeconds(30) -gt (Get-Date))

  Write-Host "`n"

  if (-not $status.status -eq "enabled") {
    $status
    Write-Error "Timeout waiting for website become available via Traefik proxy. Check website container logs."
  }

  Write-Host "Waiting for the website to become available ..." -ForegroundColor Green
  $startTime = Get-Date

  do {
    try {
      $response = Invoke-WebRequest -URI "https://localhost/"
    }
    catch {}
    
    Write-Animation -i $i -colors $colors
    Start-Sleep -Milliseconds 250
    $i++
  } while ($response.StatusCode -ne 200 -and $startTime.AddSeconds(30) -gt (Get-Date))

  Write-Host "`n"
}

Export-ModuleMember -Function *
