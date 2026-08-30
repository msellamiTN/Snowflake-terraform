#requires -version 5.1
<#
.SYNOPSIS
    Installe automatiquement TOUS les outils requis pour la formation Terraform & Snowflake.
.DESCRIPTION
    Ce script télécharge et installe chaque outil manquant — aucune intervention manuelle requise.
    Outils installés :
      1. Terraform 1.14.5       (téléchargement direct + PATH)
      2. Snowflake CLI           (pip install ou installeur officiel)
      3. Git                     (winget ou téléchargement .exe)
      4. OpenSSL                 (fourni avec Git, ajouté au PATH)
      5. VS Code                 (winget ou téléchargement .exe)
      6. Azure CLI               (winget ou téléchargement .msi)
      7. tflint                  (téléchargement direct + PATH)
      8. Python 3.12             (winget ou téléchargement .exe — requis pour Snowflake CLI)
    Le script est idempotent : un outil déjà installé à la bonne version est skippé.
.EXAMPLE
    .\scripts\Install-Tools.ps1
    .\scripts\Install-Tools.ps1 -Force    # Réinstalle tout
#>

[CmdletBinding()]
param(
    [string]$TerraformVersion = "1.14.5",
    [string]$TflintVersion    = "0.50.0",
    [string]$PythonVersion    = "3.12",
    [string]$TfInstallDir     = "C:\tools\tf-bin",
    [string]$TflintInstallDir = "C:\tools\tflint-bin",
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# ── Helpers ──────────────────────────────────────────────────────────────────

function Write-Step($num, $total, $name) {
    Write-Host "`n── $num/$total — $name ──" -ForegroundColor Cyan
}

function Write-Ok($msg)   { Write-Host "  ✅ $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host "  ❌ $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "  ℹ️  $msg" -ForegroundColor Yellow }
function Write-Log($msg)  { Write-Host "  $msg" -ForegroundColor DarkGray }

function Test-CommandExists($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Add-ToUserPath($dir) {
    $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    if ($currentPath -notlike "*$dir*") {
        [Environment]::SetEnvironmentVariable('PATH', "$dir;$currentPath", 'User')
        Write-Info "Ajouté au PATH utilisateur : $dir"
    }
    if ($env:PATH -notlike "*$dir*") {
        $env:PATH = "$dir;$env:PATH"
    }
}

function Get-WingetPackage($packageId) {
    try {
        $result = winget list --id $packageId --accept-source-agreements 2>&1
        return ($result -match $packageId)
    } catch {
        return $false
    }
}

function Install-WingetPackage($packageId, $displayName) {
    if (Get-WingetPackage $packageId) {
        Write-Ok "$displayName déjà installé (winget)"
        return $true
    }
    Write-Info "Installation de $displayName via winget..."
    try {
        winget install --id $packageId --accept-package-agreements --accept-source-agreements --silent 2>&1 |
            ForEach-Object { Write-Log $_ }
        if (Get-WingetPackage $packageId) {
            Write-Ok "$displayName installé via winget"
            return $true
        } else {
            Write-Err "winget install échoué pour $displayName"
            return $false
        }
    } catch {
        Write-Err "winget indisponible ou échec: $($_.Exception.Message)"
        return $false
    }
}

function Install-DirectDownload($name, $url, $outFile, $destDir, $exeName) {
    Write-Info "Téléchargement de $name depuis $url..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        if ($outFile -match '\.zip$') {
            Expand-Archive -Path $outFile -DestinationPath $destDir -Force
        } elseif ($outFile -match '\.msi$') {
            Start-Process msiexec.exe -ArgumentList "/i `"$outFile`" /quiet /norestart" -Wait
        } else {
            Copy-Item $outFile (Join-Path $destDir $exeName) -Force
        }
        Remove-Item $outFile -Force -ErrorAction SilentlyContinue
        Write-Ok "$name installé dans $destDir"
        return $true
    } catch {
        Write-Err "Échec téléchargement $name : $($_.Exception.Message)"
        return $false
    }
}

# ── Results ──────────────────────────────────────────────────────────────────

$results = @()
$totalSteps = 8

# ── 1. Terraform ─────────────────────────────────────────────────────────────

Write-Step 1 $totalSteps "Terraform $TerraformVersion"

$tfOk = $false
if (-not $Force -and (Test-CommandExists 'terraform')) {
    $ver = & terraform version 2>&1 | Select-Object -First 1
    if ($ver -match $TerraformVersion) {
        Write-Ok "Terraform $TerraformVersion déjà installé — $ver"
        $tfOk = $true
    } else {
        Write-Info "Version actuelle: $ver — réinstallation vers $TerraformVersion"
    }
}
if (-not $tfOk) {
    $url = "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_${TerraformVersion}_windows_amd64.zip"
    $zip = Join-Path $env:TEMP "terraform_${TerraformVersion}.zip"
    $tfOk = Install-DirectDownload "Terraform" $url $zip $TfInstallDir "terraform.exe"
    if ($tfOk) { Add-ToUserPath $TfInstallDir }
}
$results += [PSCustomObject]@{ Tool = "Terraform"; Ok = $tfOk }

# ── 2. Python ────────────────────────────────────────────────────────────────

Write-Step 2 $totalSteps "Python $PythonVersion"

$pyOk = $false
if (-not $Force -and (Test-CommandExists 'python')) {
    $ver = & python --version 2>&1
    if ($ver -match $PythonVersion) {
        Write-Ok "Python $PythonVersion déjà installé — $ver"
        $pyOk = $true
    } else {
        Write-Info "Version actuelle: $ver — installation de Python $PythonVersion"
    }
}
if (-not $pyOk) {
    # Try winget first
    $pyOk = Install-WingetPackage "Python.Python.3.12" "Python 3.12"
    if (-not $pyOk) {
        # Fallback: direct download
        $url = "https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe"
        $exe = Join-Path $env:TEMP "python-3.12.8-amd64.exe"
        try {
            Write-Info "Téléchargement de Python 3.12..."
            Invoke-WebRequest -Uri $url -OutFile $exe -UseBasicParsing
            Start-Process $exe -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
            Remove-Item $exe -Force -ErrorAction SilentlyContinue
            $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ";" + [Environment]::GetEnvironmentVariable('PATH', 'User')
            if (Test-CommandExists 'python') {
                Write-Ok "Python 3.12 installé"
                $pyOk = $true
            } else {
                Write-Err "Python installé mais non détecté — rouvrez PowerShell"
            }
        } catch {
            Write-Err "Échec installation Python: $($_.Exception.Message)"
        }
    }
}
$results += [PSCustomObject]@{ Tool = "Python"; Ok = $pyOk }

# ── 3. Snowflake CLI ─────────────────────────────────────────────────────────

Write-Step 3 $totalSteps "Snowflake CLI"

$snowOk = $false
if (-not $Force -and (Test-CommandExists 'snow')) {
    $ver = & snow --version 2>&1
    Write-Ok "Snowflake CLI déjà installé — $ver"
    $snowOk = $true
}
if (-not $snowOk) {
    if (Test-CommandExists 'python') {
        Write-Info "Installation via pip..."
        try {
            & python -m pip install snowflake-cli 2>&1 | ForEach-Object { Write-Log $_ }
            if (Test-CommandExists 'snow') {
                $ver = & snow --version 2>&1
                Write-Ok "Snowflake CLI installé — $ver"
                $snowOk = $true
            } else {
                Write-Err "pip install terminé mais 'snow' non détecté"
            }
        } catch {
            Write-Err "Échec pip: $($_.Exception.Message)"
        }
    } else {
        Write-Err "Python requis pour Snowflake CLI. Installez Python d'abord."
    }
}
$results += [PSCustomObject]@{ Tool = "Snowflake CLI"; Ok = $snowOk }

# ── 4. Git ───────────────────────────────────────────────────────────────────

Write-Step 4 $totalSteps "Git"

$gitOk = $false
if (-not $Force -and (Test-CommandExists 'git')) {
    $ver = & git --version 2>&1
    Write-Ok "Git déjà installé — $ver"
    $gitOk = $true
}
if (-not $gitOk) {
    # Try winget
    $gitOk = Install-WingetPackage "Git.Git" "Git"
    if (-not $gitOk) {
        # Fallback: direct download
        $url = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
        $exe = Join-Path $env:TEMP "Git-installer.exe"
        try {
            Write-Info "Téléchargement de Git..."
            Invoke-WebRequest -Uri $url -OutFile $exe -UseBasicParsing
            Start-Process $exe -ArgumentList "/VERYSILENT /NORESTART /COMPONENTS=gitlfs,assoc,assoc_sh" -Wait
            Remove-Item $exe -Force -ErrorAction SilentlyContinue
            $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ";" + [Environment]::GetEnvironmentVariable('PATH', 'User')
            if (Test-CommandExists 'git') {
                Write-Ok "Git installé"
                $gitOk = $true
            } else {
                Write-Err "Git installé mais non détecté — rouvrez PowerShell"
            }
        } catch {
            Write-Err "Échec téléchargement Git: $($_.Exception.Message)"
        }
    }
}
$results += [PSCustomObject]@{ Tool = "Git"; Ok = $gitOk }

# ── 5. OpenSSL ───────────────────────────────────────────────────────────────

Write-Step 5 $totalSteps "OpenSSL"

$sslOk = $false
$openssl = Get-Command openssl -ErrorAction SilentlyContinue
if (-not $openssl -and (Test-Path "C:\Program Files\Git\mingw64\bin\openssl.exe")) {
    Add-ToUserPath "C:\Program Files\Git\mingw64\bin"
    $openssl = Get-Command openssl -ErrorAction SilentlyContinue
}
if ($openssl) {
    $ver = & openssl version 2>&1
    Write-Ok "OpenSSL déjà disponible — $ver"
    $sslOk = $true
} else {
    if ($gitOk) {
        # Git was just installed — OpenSSL comes with it
        $gitOpenssl = "C:\Program Files\Git\mingw64\bin\openssl.exe"
        if (Test-Path $gitOpenssl) {
            Add-ToUserPath "C:\Program Files\Git\mingw64\bin"
            $ver = & openssl version 2>&1
            Write-Ok "OpenSSL disponible via Git — $ver"
            $sslOk = $true
        } else {
            Write-Err "OpenSSL non trouvé malgré Git installé"
        }
    } else {
        Write-Err "OpenSSL non trouvé. Installez Git (inclut OpenSSL)."
    }
}
$results += [PSCustomObject]@{ Tool = "OpenSSL"; Ok = $sslOk }

# ── 6. VS Code ───────────────────────────────────────────────────────────────

Write-Step 6 $totalSteps "VS Code"

$codeOk = $false
if (-not $Force -and (Test-CommandExists 'code')) {
    $ver = & code --version 2>&1 | Select-Object -First 1
    Write-Ok "VS Code déjà installé — $ver"
    $codeOk = $true
}
if (-not $codeOk) {
    # Try winget
    $codeOk = Install-WingetPackage "Microsoft.VisualStudioCode" "VS Code"
    if (-not $codeOk) {
        # Fallback: direct download
        $url = "https://update.code.visualstudio.com/latest/win32-x64/stable"
        $exe = Join-Path $env:TEMP "VSCodeSetup.exe"
        try {
            Write-Info "Téléchargement de VS Code..."
            Invoke-WebRequest -Uri $url -OutFile $exe -UseBasicParsing
            Start-Process $exe -ArgumentList "/verysilent /norestart /mergetasks=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -Wait
            Remove-Item $exe -Force -ErrorAction SilentlyContinue
            $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ";" + [Environment]::GetEnvironmentVariable('PATH', 'User')
            if (Test-CommandExists 'code') {
                Write-Ok "VS Code installé"
                $codeOk = $true
            } else {
                Write-Err "VS Code installé mais non détecté — rouvrez PowerShell"
            }
        } catch {
            Write-Err "Échec téléchargement VS Code: $($_.Exception.Message)"
        }
    }
}

# Install VS Code extensions
if ($codeOk) {
    Write-Info "Installation des extensions VS Code..."
    $extensions = @(
        "HashiCorp.terraform",
        "ms-azuretools.vscode-azureterraform",
        "ms-python.python",
        "redhat.vscode-yaml",
        "shd101wyy.markdown-preview-enhanced"
    )
    foreach ($ext in $extensions) {
        try {
            & code --install-extension $ext --force 2>&1 | Out-Null
            Write-Log "Extension installée: $ext"
        } catch {
            Write-Log "Extension skip: $ext"
        }
    }
    Write-Ok "Extensions VS Code installées"
}
$results += [PSCustomObject]@{ Tool = "VS Code"; Ok = $codeOk }

# ── 7. Azure CLI ─────────────────────────────────────────────────────────────

Write-Step 7 $totalSteps "Azure CLI"

$azOk = $false
if (-not $Force -and (Test-CommandExists 'az')) {
    $ver = (& az version 2>&1 | ConvertFrom-Json).'azure-cli'
    Write-Ok "Azure CLI déjà installé — v$ver"
    $azOk = $true
}
if (-not $azOk) {
    # Try winget
    $azOk = Install-WingetPackage "Microsoft.AzureCLI" "Azure CLI"
    if (-not $azOk) {
        # Fallback: direct download MSI
        $url = "https://aka.ms/installazurecliwindowsx64"
        $msi = Join-Path $env:TEMP "azure-cli.msi"
        try {
            Write-Info "Téléchargement d'Azure CLI..."
            Invoke-WebRequest -Uri $url -OutFile $msi -UseBasicParsing
            Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /quiet /norestart" -Wait
            Remove-Item $msi -Force -ErrorAction SilentlyContinue
            $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ";" + [Environment]::GetEnvironmentVariable('PATH', 'User')
            if (Test-CommandExists 'az') {
                Write-Ok "Azure CLI installé"
                $azOk = $true
            } else {
                Write-Err "Azure CLI installé mais non détecté — rouvrez PowerShell"
            }
        } catch {
            Write-Err "Échec téléchargement Azure CLI: $($_.Exception.Message)"
        }
    }
}
$results += [PSCustomObject]@{ Tool = "Azure CLI"; Ok = $azOk }

# ── 8. tflint ────────────────────────────────────────────────────────────────

Write-Step 8 $totalSteps "tflint v$TflintVersion"

$tflintOk = $false
if (-not $Force -and (Test-CommandExists 'tflint')) {
    $ver = & tflint --version 2>&1 | Select-Object -First 1
    Write-Ok "tflint déjà installé — $ver"
    $tflintOk = $true
}
if (-not $tflintOk) {
    $url = "https://github.com/terraform-linters/tflint/releases/download/v${TflintVersion}/tflint_windows_amd64.zip"
    $zip = Join-Path $env:TEMP "tflint_${TflintVersion}.zip"
    $tflintOk = Install-DirectDownload "tflint" $url $zip $TflintInstallDir "tflint.exe"
    if ($tflintOk) { Add-ToUserPath $TflintInstallDir }
}
$results += [PSCustomObject]@{ Tool = "tflint"; Ok = $tflintOk }

# ── Résumé ───────────────────────────────────────────────────────────────────

Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  RÉSUMÉ DE L'INSTALLATION AUTOMATIQUE" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

$allOk = $true
foreach ($r in $results) {
    $icon = if ($r.Ok) { "✅" } else { "❌" }
    Write-Host "  $icon $($r.Tool)"
    if (-not $r.Ok) { $allOk = $false }
}

Write-Host ""
if ($allOk) {
    Write-Host "🎉 Tous les outils sont installés ! Vous pouvez commencer la formation." -ForegroundColor Green
} else {
    $failed = $results | Where-Object { -not $_.Ok }
    Write-Host "⚠️  $($failed.Count) outil(s) non installé(s) :" -ForegroundColor Yellow
    foreach ($f in $failed) {
        Write-Host "     — $($f.Tool)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "  ⚠️  Si un outil n'est pas reconnu, FERMEZ et ROUVREZ PowerShell." -ForegroundColor Yellow
Write-Host "     Le PATH n'est rafraîchi qu'à l'ouverture d'une nouvelle session." -ForegroundColor Yellow
Write-Host ""
