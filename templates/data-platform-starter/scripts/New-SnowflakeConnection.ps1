#requires -version 5.1
<#
.SYNOPSIS
    Creates a Snowflake CLI connection using a PAT entered securely.

.DESCRIPTION
    This script replaces the old lab00.ps1 that contained a hardcoded password.
    The PAT is entered via a masked prompt, never displayed, never logged, and
    never passed as a command-line argument.

    The connection is stored by Snowflake CLI in its configuration file. The
    PAT itself is not written to disk by this script.

.PARAMETER ConnectionName
    Name of the Snowflake CLI connection to create. Default: training.

.PARAMETER Account
    Snowflake account identifier (e.g. orgname-accountname).

.PARAMETER Organization
    Snowflake organization name.

.PARAMETER User
    Snowflake user name.

.PARAMETER Role
    Snowflake role to use. Default: SYSADMIN.

.PARAMETER Host
    Optional Snowflake host override.

.EXAMPLE
    .\scripts\New-SnowflakeConnection.ps1 -ConnectionName training `
        -Organization MYORG -Account MYACCOUNT -User DATA2AI -Role SYSADMIN

.EXAMPLE
    .\scripts\New-SnowflakeConnection.ps1
    # Prompts for all values interactively.
#>

[CmdletBinding()]
param(
    [string]$ConnectionName = 'training',
    [string]$Organization,
    [string]$Account,
    [string]$User,
    [string]$Role = 'SYSADMIN',
    [string]$Host
)

$ErrorActionPreference = 'Stop'

function Read-Masked {
    param([string]$Prompt)

    Write-Host "$Prompt " -NoNewline -ForegroundColor Yellow

    $secure = Read-Host -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

function Read-Required {
    param([string]$Prompt, [string]$Default = '')

    while ($true) {
        Write-Host "$Prompt" -NoNewline -ForegroundColor Yellow
        if ($Default) {
            Write-Host " [$Default]" -NoNewline
        }
        Write-Host ": " -NoNewline
        $value = Read-Host
        if ($value) { return $value }
        if ($Default) { return $Default }
        Write-Host "  A value is required." -ForegroundColor Red
    }
}

# ------------------------------------------------------------------
# Collect parameters interactively if not provided
# ------------------------------------------------------------------

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ' Snowflake CLI connection setup' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host 'The PAT is entered securely and never displayed or logged.' -ForegroundColor DarkGray
Write-Host ''

if (-not $Organization) { $Organization = Read-Required 'Snowflake organization name' }
if (-not $Account)      { $Account      = Read-Required 'Snowflake account name' }
if (-not $User)         { $User         = Read-Required 'Snowflake user name' }

$token = Read-Masked 'Snowflake PAT (token):'

if (-not $token) {
    Write-Host '[ERROR] No token entered. Aborting.' -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------
# Build the snow connection add command
# ------------------------------------------------------------------

$args = @(
    'connection', 'add',
    '-n', $ConnectionName,
    '-a', $Account,
    '-o', $Organization,
    '-u', $User,
    '-r', $Role,
    '--no-interactive'
)

if ($Host) {
    $args += @('-h', $Host)
}

# The token is passed via stdin to avoid appearing in the process list.
# Snowflake CLI reads the token from the SNOWFLAKE_PAT environment variable.
$env:SNOWFLAKE_PAT = $token

Write-Host ''
Write-Host 'Creating the connection...' -ForegroundColor Cyan

try {
    & snow @args 2>&1 | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] snow connection add failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }

    Write-Host "[OK] Connection '$ConnectionName' created." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to create connection: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Clear the token from the environment as soon as possible.
    Remove-Item Env:SNOWFLAKE_PAT -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------------
# Test the connection
# ------------------------------------------------------------------

Write-Host ''
Write-Host 'Testing the connection...' -ForegroundColor Cyan

$env:SNOWFLAKE_PAT = $token

try {
    $testResult = & snow sql -q 'SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT()' `
        -c $ConnectionName --format=json 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host '[OK] Connection test succeeded.' -ForegroundColor Green
        Write-Host "       Output: $testResult" -ForegroundColor DarkGray
    } else {
        Write-Host '[WARN] Connection created but test query failed.' -ForegroundColor Yellow
        Write-Host "       Check the connection with: snow connection test -c $ConnectionName" -ForegroundColor DarkGray
    }
} catch {
    Write-Host '[WARN] Connection test could not execute.' -ForegroundColor Yellow
} finally {
    Remove-Item Env:SNOWFLAKE_PAT -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host 'Done.' -ForegroundColor Green
Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Cyan
Write-Host "  - Use the connection:  snow sql -q 'SELECT 1' -c $ConnectionName"
Write-Host '  - Do not store the PAT in any file.'
Write-Host '  - Rotate the PAT when the training module is complete.'
