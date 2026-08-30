#requires -version 5.1
<#
.SYNOPSIS
    Installation automatique de l'environnement de formation
    Terraform & Snowflake.

.DESCRIPTION
    Installe/verifie :
      1. Terraform 1.14.5
      2. Python 3.12
      3. Snowflake CLI
      4. Git
      5. OpenSSL
      6. VS Code
      7. Azure CLI
      8. tflint 0.50.0

    Compatible Windows PowerShell 5.1.
    Script idempotent : les outils deja conformes sont conserves.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Force
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

$ErrorActionPreference = "Stop"

# ============================================================
# CONFIGURATION
# ============================================================

$TotalSteps = 8
$Results = @()

# ============================================================
# HELPERS
# ============================================================

function Write-Step {
    param(
        [int]$Number,
        [int]$Total,
        [string]$Name
    )

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host " $Number/$Total - $Name" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Err {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Yellow
}

function Write-Log {
    param([string]$Message)
    Write-Host "       $Message" -ForegroundColor DarkGray
}

function Test-CommandExists {
    param([string]$Name)

    $command = Get-Command $Name -ErrorAction SilentlyContinue

    if ($null -ne $command) {
        return $true
    }

    return $false
}

function Refresh-Path {
    $machinePath = [Environment]::GetEnvironmentVariable(
        "PATH",
        "Machine"
    )

    $userPath = [Environment]::GetEnvironmentVariable(
        "PATH",
        "User"
    )

    $env:PATH = "$machinePath;$userPath"
}

function Add-ToUserPath {
    param([string]$Directory)

    if (-not (Test-Path $Directory)) {
        return
    }

    $currentUserPath = [Environment]::GetEnvironmentVariable(
        "PATH",
        "User"
    )

    if ([string]::IsNullOrWhiteSpace($currentUserPath)) {
        $currentUserPath = ""
    }

    $escapedDirectory = [Regex]::Escape($Directory)

    if ($currentUserPath -notmatch "(^|;)$escapedDirectory(;|$)") {

        if ($currentUserPath.Length -gt 0) {
            $newPath = "$Directory;$currentUserPath"
        }
        else {
            $newPath = $Directory
        }

        [Environment]::SetEnvironmentVariable(
            "PATH",
            $newPath,
            "User"
        )

        Write-Info "PATH utilisateur ajoute : $Directory"
    }

    if ($env:PATH -notmatch "(^|;)$escapedDirectory(;|$)") {
        $env:PATH = "$Directory;$env:PATH"
    }
}

function Test-WingetAvailable {

    if (-not (Test-CommandExists "winget")) {
        return $false
    }

    try {
        $null = winget --version 2>&1
        return $true
    }
    catch {
        return $false
    }
}

function Get-WingetPackageInstalled {
    param([string]$PackageId)

    if (-not (Test-WingetAvailable)) {
        return $false
    }

    try {

        $output = winget list `
            --id $PackageId `
            --exact `
            --accept-source-agreements 2>&1

        foreach ($line in $output) {
            if ($line -match [Regex]::Escape($PackageId)) {
                return $true
            }
        }

        return $false
    }
    catch {
        return $false
    }
}

function Install-WingetPackage {
    param(
        [string]$PackageId,
        [string]$DisplayName
    )

    if (-not (Test-WingetAvailable)) {
        Write-Info "winget indisponible."
        return $false
    }

    if (-not $Force) {

        if (Get-WingetPackageInstalled $PackageId) {
            Write-Ok "$DisplayName deja installe via winget."
            return $true
        }
    }

    Write-Info "Installation de $DisplayName via winget..."

    try {

        winget install `
            --id $PackageId `
            --exact `
            --accept-package-agreements `
            --accept-source-agreements `
            --silent 2>&1 |
            ForEach-Object {
                Write-Log $_
            }

        Start-Sleep -Seconds 2

        Refresh-Path

        if (Get-WingetPackageInstalled $PackageId) {
            Write-Ok "$DisplayName installe."
            return $true
        }

        Write-Err "winget n'a pas confirme l'installation de $DisplayName."
        return $false
    }
    catch {

        Write-Err "Echec winget pour $DisplayName."
        Write-Log $_.Exception.Message

        return $false
    }
}

function Download-File {
    param(
        [string]$Url,
        [string]$OutputFile
    )

    Write-Info "Telechargement : $Url"

    try {

        Invoke-WebRequest `
            -Uri $Url `
            -OutFile $OutputFile `
            -UseBasicParsing

        if (-not (Test-Path $OutputFile)) {
            throw "Le fichier telecharge n'existe pas."
        }

        return $true
    }
    catch {

        Write-Err "Echec du telechargement."
        Write-Log $_.Exception.Message

        return $false
    }
}

function Install-ZipExecutable {
    param(
        [string]$Name,
        [string]$Url,
        [string]$InstallDirectory,
        [string]$ExecutableName
    )

    $tempZip = Join-Path `
        $env:TEMP `
        ("{0}-{1}.zip" -f $Name, (Get-Random))

    try {

        if (-not (Test-Path $InstallDirectory)) {
            New-Item `
                -ItemType Directory `
                -Path $InstallDirectory `
                -Force |
                Out-Null
        }

        if (-not (Download-File $Url $tempZip)) {
            return $false
        }

        Write-Info "Extraction de $Name..."

        Expand-Archive `
            -Path $tempZip `
            -DestinationPath $InstallDirectory `
            -Force

        $exe = Get-ChildItem `
            -Path $InstallDirectory `
            -Filter $ExecutableName `
            -Recurse `
            -File `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1

        if ($null -eq $exe) {
            throw "$ExecutableName introuvable apres extraction."
        }

        # Si l'executable est dans un sous-dossier,
        # on le remonte dans le dossier principal.
        $target = Join-Path `
            $InstallDirectory `
            $ExecutableName

        if ($exe.FullName -ne $target) {

            Copy-Item `
                -Path $exe.FullName `
                -Destination $target `
                -Force
        }

        Add-ToUserPath $InstallDirectory

        Write-Ok "$Name installe dans $InstallDirectory."

        return $true
    }
    catch {

        Write-Err "Echec installation de $Name."
        Write-Log $_.Exception.Message

        return $false
    }
    finally {

        if (Test-Path $tempZip) {
            Remove-Item `
                $tempZip `
                -Force `
                -ErrorAction SilentlyContinue
        }
    }
}

function Test-VersionContains {
    param(
        [string]$Actual,
        [string]$Expected
    )

    if ([string]::IsNullOrWhiteSpace($Actual)) {
        return $false
    }

    return ($Actual -match [Regex]::Escape($Expected))
}

# ============================================================
# ADMINISTRATOR CHECK
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " TERRAFORM & SNOWFLAKE - INSTALLATION ENVIRONNEMENT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

$isAdmin = $currentPrincipal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {

    Write-Info "PowerShell n'est pas lance en administrateur."
    Write-Info "Le script peut fonctionner, mais certaines installations"
    Write-Info "peuvent necessiter des droits administrateur."
    Write-Host ""
}

# ============================================================
# 1 - TERRAFORM
# ============================================================

Write-Step 1 $TotalSteps "Terraform $TerraformVersion"

$tfOk = $false

if (-not $Force -and (Test-CommandExists "terraform")) {

    try {

        $tfVersionOutput = & terraform version 2>&1 |
            Select-Object -First 1

        if (Test-VersionContains `
            $tfVersionOutput `
            $TerraformVersion) {

            Write-Ok "Terraform $TerraformVersion deja installe."
            Write-Log $tfVersionOutput

            $tfOk = $true
        }
        else {

            Write-Info "Version actuelle : $tfVersionOutput"
            Write-Info "Installation de Terraform $TerraformVersion."
        }
    }
    catch {
        Write-Info "Terraform detecte mais version impossible a lire."
    }
}

if (-not $tfOk) {

    $terraformUrl = `
        "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_${TerraformVersion}_windows_amd64.zip"

    $tfOk = Install-ZipExecutable `
        "Terraform" `
        $terraformUrl `
        $TfInstallDir `
        "terraform.exe"
}

$Results += [PSCustomObject]@{
    Tool = "Terraform"
    Version = $TerraformVersion
    Ok = $tfOk
}

# ============================================================
# 2 - PYTHON
# ============================================================

Write-Step 2 $TotalSteps "Python $PythonVersion"

$pyOk = $false

Refresh-Path

if (-not $Force -and (Test-CommandExists "python")) {

    try {

        $pythonVersionOutput = & python --version 2>&1

        if (Test-VersionContains `
            $pythonVersionOutput `
            $PythonVersion) {

            Write-Ok "Python $PythonVersion deja installe."
            Write-Log $pythonVersionOutput

            $pyOk = $true
        }
        else {

            Write-Info "Version actuelle : $pythonVersionOutput"
        }
    }
    catch {
        Write-Info "Python detecte mais version impossible a lire."
    }
}

if (-not $pyOk) {

    $pyOk = Install-WingetPackage `
        "Python.Python.3.12" `
        "Python 3.12"

    if (-not $pyOk) {

        $pythonInstaller = Join-Path `
            $env:TEMP `
            "python-3.12.8-amd64.exe"

        $pythonUrl = `
            "https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe"

        try {

            if (Download-File $pythonUrl $pythonInstaller) {

                Write-Info "Installation silencieuse de Python..."

                Start-Process `
                    -FilePath $pythonInstaller `
                    -ArgumentList `
                    "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0" `
                    -Wait

                Refresh-Path

                if (Test-CommandExists "python") {

                    $pythonVersionOutput = & python --version 2>&1

                    Write-Ok "Python installe."
                    Write-Log $pythonVersionOutput

                    $pyOk = $true
                }
                else {

                    Write-Err "Python installe mais non detecte."
                }
            }
        }
        catch {

            Write-Err "Echec installation Python."
            Write-Log $_.Exception.Message
        }
        finally {

            if (Test-Path $pythonInstaller) {
                Remove-Item `
                    $pythonInstaller `
                    -Force `
                    -ErrorAction SilentlyContinue
            }
        }
    }
}

$Results += [PSCustomObject]@{
    Tool = "Python"
    Version = $PythonVersion
    Ok = $pyOk
}

Refresh-Path

# ============================================================
# 3 - SNOWFLAKE CLI
# ============================================================

Write-Step 3 $TotalSteps "Snowflake CLI"

$snowOk = $false

if (-not $Force -and (Test-CommandExists "snow")) {

    try {

        $snowVersion = & snow --version 2>&1

        Write-Ok "Snowflake CLI deja installe."
        Write-Log $snowVersion

        $snowOk = $true
    }
    catch {
        Write-Info "Commande snow detectee mais verification impossible."
    }
}

if (-not $snowOk) {

    Refresh-Path

    if (Test-CommandExists "python") {

        try {

            Write-Info "Mise a jour de pip..."

            & python -m pip install `
                --upgrade pip 2>&1 |
                ForEach-Object {
                    Write-Log $_
                }

            Write-Info "Installation de Snowflake CLI..."

            & python -m pip install `
                snowflake-cli 2>&1 |
                ForEach-Object {
                    Write-Log $_
                }

            Refresh-Path

            if (Test-CommandExists "snow") {

                $snowVersion = & snow --version 2>&1

                Write-Ok "Snowflake CLI installe."
                Write-Log $snowVersion

                $snowOk = $true
            }
            else {

                # Recherche du dossier Scripts Python.
                $pythonScripts = @(
                    "$env:APPDATA\Python\Python312\Scripts",
                    "$env:LOCALAPPDATA\Programs\Python\Python312\Scripts",
                    "C:\Program Files\Python312\Scripts"
                )

                foreach ($scriptDir in $pythonScripts) {

                    if (Test-Path $scriptDir) {

                        Add-ToUserPath $scriptDir
                        Refresh-Path

                        if (Test-CommandExists "snow") {

                            Write-Ok "Snowflake CLI detecte apres ajout du PATH."

                            $snowOk = $true
                            break
                        }
                    }
                }
            }
        }
        catch {

            Write-Err "Echec installation Snowflake CLI."
            Write-Log $_.Exception.Message
        }
    }
    else {

        Write-Err "Python n'est pas disponible."
        Write-Info "Snowflake CLI necessite Python."
    }
}

$Results += [PSCustomObject]@{
    Tool = "Snowflake CLI"
    Version = "latest"
    Ok = $snowOk
}

# ============================================================
# 4 - GIT
# ============================================================

Write-Step 4 $TotalSteps "Git"

$gitOk = $false

if (-not $Force -and (Test-CommandExists "git")) {

    try {

        $gitVersion = & git --version 2>&1

        Write-Ok "Git deja installe."
        Write-Log $gitVersion

        $gitOk = $true
    }
    catch {
        Write-Info "Git detecte mais verification impossible."
    }
}

if (-not $gitOk) {

    $gitOk = Install-WingetPackage `
        "Git.Git" `
        "Git"

    if (-not $gitOk) {

        Write-Info "Tentative d'installation directe de Git..."

        $gitUrl = `
            "https://github.com/git-for-windows/git/releases/latest/download/Git-64-bit.exe"

        $gitInstaller = Join-Path `
            $env:TEMP `
            "Git-64-bit.exe"

        try {

            if (Download-File $gitUrl $gitInstaller) {

                Start-Process `
                    -FilePath $gitInstaller `
                    -ArgumentList `
                    "/VERYSILENT /NORESTART" `
                    -Wait

                Refresh-Path

                if (Test-CommandExists "git") {

                    Write-Ok "Git installe."

                    $gitOk = $true
                }
                else {

                    Write-Err "Git installe mais non detecte."
                }
            }
        }
        catch {

            Write-Err "Echec installation Git."
            Write-Log $_.Exception.Message
        }
        finally {

            if (Test-Path $gitInstaller) {

                Remove-Item `
                    $gitInstaller `
                    -Force `
                    -ErrorAction SilentlyContinue
            }
        }
    }
}

$Results += [PSCustomObject]@{
    Tool = "Git"
    Version = "latest"
    Ok = $gitOk
}

Refresh-Path

# ============================================================
# 5 - OPENSSL
# ============================================================

Write-Step 5 $TotalSteps "OpenSSL"

$sslOk = $false

Refresh-Path

if (Test-CommandExists "openssl") {

    try {

        $opensslVersion = & openssl version 2>&1

        Write-Ok "OpenSSL disponible."
        Write-Log $opensslVersion

        $sslOk = $true
    }
    catch {
        Write-Info "OpenSSL detecte mais version impossible a lire."
    }
}

if (-not $sslOk) {

    $gitOpenSSLPaths = @(
        "C:\Program Files\Git\mingw64\bin\openssl.exe",
        "C:\Program Files\Git\usr\bin\openssl.exe"
    )

    foreach ($opensslPath in $gitOpenSSLPaths) {

        if (Test-Path $opensslPath) {

            $opensslDir = Split-Path `
                $opensslPath `
                -Parent

            Add-ToUserPath $opensslDir
            Refresh-Path

            if (Test-CommandExists "openssl") {

                $opensslVersion = & openssl version 2>&1

                Write-Ok "OpenSSL disponible via Git."
                Write-Log $opensslVersion

                $sslOk = $true
                break
            }
        }
    }
}

if (-not $sslOk) {

    Write-Err "OpenSSL non disponible."
    Write-Info "Installez Git for Windows puis relancez le script."
}

$Results += [PSCustomObject]@{
    Tool = "OpenSSL"
    Version = "Git/OpenSSL"
    Ok = $sslOk
}

# ============================================================
# 6 - VS CODE
# ============================================================

Write-Step 6 $TotalSteps "VS Code"

$codeOk = $false

if (-not $Force -and (Test-CommandExists "code")) {

    try {

        $codeVersion = & code --version 2>&1 |
            Select-Object -First 1

        Write-Ok "VS Code deja installe."
        Write-Log "Version : $codeVersion"

        $codeOk = $true
    }
    catch {
        Write-Info "VS Code detecte mais verification impossible."
    }
}

if (-not $codeOk) {

    $codeOk = Install-WingetPackage `
        "Microsoft.VisualStudioCode" `
        "VS Code"

    if (-not $codeOk) {

        $codeInstaller = Join-Path `
            $env:TEMP `
            "VSCodeSetup.exe"

        $codeUrl = `
            "https://update.code.visualstudio.com/latest/win32-x64-user/stable"

        try {

            if (Download-File $codeUrl $codeInstaller) {

                Start-Process `
                    -FilePath $codeInstaller `
                    -ArgumentList `
                    "/VERYSILENT /NORESTART /MERGETASKS=addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" `
                    -Wait

                Refresh-Path

                if (Test-CommandExists "code") {

                    Write-Ok "VS Code installe."

                    $codeOk = $true
                }
                else {

                    Write-Err "VS Code installe mais non detecte."
                }
            }
        }
        catch {

            Write-Err "Echec installation VS Code."
            Write-Log $_.Exception.Message
        }
        finally {

            if (Test-Path $codeInstaller) {

                Remove-Item `
                    $codeInstaller `
                    -Force `
                    -ErrorAction SilentlyContinue
            }
        }
    }
}

# ------------------------------------------------------------
# VS CODE EXTENSIONS
# ------------------------------------------------------------

if ($codeOk) {

    Refresh-Path

    $extensions = @(
        "HashiCorp.terraform",
        "ms-azuretools.vscode-azureterraform",
        "ms-python.python",
        "redhat.vscode-yaml",
        "shd101wyy.markdown-preview-enhanced"
    )

    Write-Info "Installation des extensions VS Code..."

    foreach ($extension in $extensions) {

        try {

            Write-Log "Extension : $extension"

            & code `
                --install-extension $extension `
                --force 2>&1 |
                ForEach-Object {
                    Write-Log $_
                }

        }
        catch {

            Write-Log "Extension non installee : $extension"
        }
    }

    Write-Ok "Traitement des extensions VS Code termine."
}

$Results += [PSCustomObject]@{
    Tool = "VS Code"
    Version = "latest"
    Ok = $codeOk
}

# ============================================================
# 7 - AZURE CLI
# ============================================================

Write-Step 7 $TotalSteps "Azure CLI"

$azOk = $false

if (-not $Force -and (Test-CommandExists "az")) {

    try {

        $azVersion = `
            (& az version 2>&1 |
            ConvertFrom-Json).'azure-cli'

        Write-Ok "Azure CLI deja installe."
        Write-Log "Version : $azVersion"

        $azOk = $true
    }
    catch {

        Write-Info "Azure CLI detecte."
        $azOk = $true
    }
}

if (-not $azOk) {

    $azOk = Install-WingetPackage `
        "Microsoft.AzureCLI" `
        "Azure CLI"

    if (-not $azOk) {

        $azureInstaller = Join-Path `
            $env:TEMP `
            "azure-cli.msi"

        $azureUrl = `
            "https://aka.ms/installazurecliwindowsx64"

        try {

            if (Download-File $azureUrl $azureInstaller) {

                Start-Process `
                    -FilePath "msiexec.exe" `
                    -ArgumentList `
                    "/i `"$azureInstaller`" /quiet /norestart" `
                    -Wait

                Refresh-Path

                if (Test-CommandExists "az") {

                    Write-Ok "Azure CLI installe."

                    $azOk = $true
                }
                else {

                    Write-Err "Azure CLI installe mais non detecte."
                }
            }
        }
        catch {

            Write-Err "Echec installation Azure CLI."
            Write-Log $_.Exception.Message
        }
        finally {

            if (Test-Path $azureInstaller) {

                Remove-Item `
                    $azureInstaller `
                    -Force `
                    -ErrorAction SilentlyContinue
            }
        }
    }
}

$Results += [PSCustomObject]@{
    Tool = "Azure CLI"
    Version = "latest"
    Ok = $azOk
}

# ============================================================
# 8 - TFLINT
# ============================================================

Write-Step 8 $TotalSteps "tflint $TflintVersion"

$tflintOk = $false

Refresh-Path

if (-not $Force -and (Test-CommandExists "tflint")) {

    try {

        $tflintVersionOutput = `
            & tflint --version 2>&1 |
            Select-Object -First 1

        Write-Ok "tflint deja installe."
        Write-Log $tflintVersionOutput

        $tflintOk = $true
    }
    catch {
        Write-Info "tflint detecte mais verification impossible."
    }
}

if (-not $tflintOk) {

    $tflintUrl = `
        "https://github.com/terraform-linters/tflint/releases/download/v$TflintVersion/tflint_windows_amd64.zip"

    $tflintOk = Install-ZipExecutable `
        "tflint" `
        $tflintUrl `
        $TflintInstallDir `
        "tflint.exe"
}

$Results += [PSCustomObject]@{
    Tool = "tflint"
    Version = $TflintVersion
    Ok = $tflintOk
}

# ============================================================
# FINAL PATH REFRESH
# ============================================================

Refresh-Path

# ============================================================
# FINAL VERIFICATION
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " VERIFICATION FINALE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$verificationCommands = @(
    "terraform",
    "python",
    "snow",
    "git",
    "openssl",
    "code",
    "az",
    "tflint"
)

foreach ($commandName in $verificationCommands) {

    if (Test-CommandExists $commandName) {
        Write-Ok "$commandName : disponible"
    }
    else {
        Write-Err "$commandName : NON DETECTE"
    }
}

# ============================================================
# SUMMARY
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " RESUME DE L'INSTALLATION" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$allOk = $true

foreach ($result in $Results) {

    if ($result.Ok) {

        Write-Host `
            "[OK]    $($result.Tool) - $($result.Version)" `
            -ForegroundColor Green
    }
    else {

        Write-Host `
            "[FAILED] $($result.Tool) - $($result.Version)" `
            -ForegroundColor Red

        $allOk = $false
    }
}

Write-Host ""

if ($allOk) {

    Write-Host "============================================================" -ForegroundColor Green
    Write-Host " INSTALLATION TERMINEE AVEC SUCCES" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green

    Write-Host ""
    Write-Host "L'environnement Terraform & Snowflake est pret." -ForegroundColor Green
}
else {

    $failed = $Results |
        Where-Object { -not $_.Ok }

    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host " INSTALLATION PARTIELLE" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Yellow

    Write-Host ""
    Write-Host "Outils en echec :" -ForegroundColor Yellow

    foreach ($item in $failed) {
        Write-Host "  - $($item.Tool)" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Relancez le script apres avoir corrige les erreurs." `
        -ForegroundColor Yellow
}

Write-Host ""
Write-Host "IMPORTANT :" -ForegroundColor Yellow
Write-Host "Si une commande reste introuvable, fermez puis rouvrez PowerShell."
Write-Host ""

# ============================================================
# DISPLAY USEFUL VERSIONS
# ============================================================

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " VERSIONS DETECTEES" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

if (Test-CommandExists "terraform") {
    try {
        & terraform version 2>&1 |
            Select-Object -First 1
    }
    catch {}
}

if (Test-CommandExists "python") {
    try {
        & python --version 2>&1
    }
    catch {}
}

if (Test-CommandExists "snow") {
    try {
        & snow --version 2>&1
    }
    catch {}
}

if (Test-CommandExists "git") {
    try {
        & git --version 2>&1
    }
    catch {}
}

if (Test-CommandExists "openssl") {
    try {
        & openssl version 2>&1
    }
    catch {}
}

if (Test-CommandExists "az") {
    try {
        & az version 2>&1 |
            ConvertFrom-Json |
            Select-Object -ExpandProperty 'azure-cli'
    }
    catch {}
}

if (Test-CommandExists "tflint") {
    try {
        & tflint --version 2>&1 |
            Select-Object -First 1
    }
    catch {}
}

Write-Host ""
Write-Host "Fin du script." -ForegroundColor Cyan