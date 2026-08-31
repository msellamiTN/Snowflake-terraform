#requires -version 5.1
[CmdletBinding()]
param([int]$Task, [switch]$All, [switch]$Report)

$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check([string]$Name, [bool]$Passed, [string]$Hint) {
    $checks.Add([PSCustomObject]@{ Name = $Name; Passed = $Passed; Hint = $Hint })
}
function Test-Tool([string]$Name) {
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path
$workspace = if ($env:STUDENT_WORKSPACE) { $env:STUDENT_WORKSPACE } else { (Get-Location).Path }

Add-Check 'Workspace metadata' (Test-Path (Join-Path $workspace '.student-workspace.json')) 'Recreate the workspace with New-StudentWorkspace.ps1.'
Add-Check 'Git' (Test-Tool 'git') 'Install Git and open a new terminal.'
Add-Check 'Terraform' (Test-Tool 'terraform') 'Install Terraform with the official method for your OS.'
Add-Check 'Snowflake CLI' (Test-Tool 'snow') 'Install Snowflake CLI in a user or virtual environment.'

$envFile = Join-Path $repoRoot '.env'
Add-Check '.env local' (Test-Path $envFile) 'Copy .env.example to .env and replace non-secret placeholders.'
Add-Check '.env ignored' ((& git -C $repoRoot check-ignore .env 2>$null) -eq '.env') 'Add .env to .gitignore before continuing.'
Add-Check 'Secrets ignored' ((& git -C $repoRoot check-ignore secrets/probe.token 2>$null) -eq 'secrets/probe.token') 'Add secrets/ to .gitignore.'

if (Test-Path $envFile) {
    $envText = Get-Content $envFile -Raw
    Add-Check 'No unresolved identifiers' ($envText -notmatch '<[^>]+>') 'Replace every <placeholder> value in .env.'
}

$connection = if ($env:SNOWFLAKE_TERRAFORM_CONNECTION) { $env:SNOWFLAKE_TERRAFORM_CONNECTION } else { 'terraform_svc' }
if (Test-Tool 'snow') {
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & snow connection test -c $connection *> $null
    $snowExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorAction
    Add-Check 'Snowflake connection' ($snowExitCode -eq 0) "Check connection '$connection' without sharing its secret."
} else {
    Add-Check 'Snowflake connection' $false 'Snowflake CLI doit être installé avant le test.'
}

$selected = if ($All -or -not $Task) { $checks } else { @($checks)[$Task - 1] }
foreach ($check in $selected) {
    $status = if ($check.Passed) { 'PASS' } else { 'FAIL' }
    Write-Host "[$status] $($check.Name)"
    if (-not $check.Passed) { Write-Host "       $($check.Hint)" }
}

$passed = @($selected | Where-Object Passed).Count
$total = @($selected).Count
Write-Host "Result: $passed/$total"

if ($Report) {
    $reportDir = Join-Path $repoRoot 'student-track\_reports'
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    $initials = if ($env:STUDENT_INITIALS) { $env:STUDENT_INITIALS } else { 'STUDENT' }
    $reportPath = Join-Path $reportDir "module-00-$initials.md"
    $lines = @('# Module 00 validation report', '', "Score: $passed/$total", '', '| Check | Result |', '|---|---|')
    foreach ($check in $selected) { $lines += "| $($check.Name) | $(if ($check.Passed) { 'PASS' } else { 'FAIL' }) |" }
    $lines | Set-Content -Path $reportPath -Encoding utf8
    Write-Host "Report: $reportPath"
}

if ($passed -ne $total) { exit 1 }
Write-Host 'Ready for Day 1'
exit 0
