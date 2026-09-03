#requires -version 5.1
[CmdletBinding()]
param([ValidateRange(1, 5)][int]$Task, [switch]$All, [switch]$Report)

$workspace = if ($env:STUDENT_WORKSPACE) { $env:STUDENT_WORKSPACE } else { (Get-Location).Path }
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path
$results = [System.Collections.Generic.List[object]]::new()

function Add-Check([int]$TaskNumber, [string]$Name, [bool]$Passed, [string]$Hint) {
    if ($All -or -not $Task -or $Task -eq $TaskNumber) {
        $results.Add([PSCustomObject]@{ Task = $TaskNumber; Name = $Name; Passed = $Passed; Hint = $Hint })
    }
}

$devDir = Join-Path $workspace 'environments/dev'
$prodDir = Join-Path $workspace 'environments/prod'
$hasEnvDirs = (Test-Path $devDir) -or (Test-Path (Join-Path $workspace 'dev'))

# Task 1: Environment directory separation
Add-Check 1 'DEV environment folder exists' $hasEnvDirs 'Create environments/dev directory structure.'

# Task 2: Separate state keys per environment
$devBackend = if (Test-Path (Join-Path $devDir 'backend.tf')) { Get-Content (Join-Path $devDir 'backend.tf') -Raw } else { '' }
$hasSeparateStateKey = ($devBackend -match 'key\s*=\s*"dev' -or $devBackend -match 'key\s*=\s*"environments/dev')
Add-Check 2 'Environment state isolation' ($hasSeparateStateKey -or (Test-Path (Join-Path $devDir 'main.tf'))) 'Ensure DEV and PROD use distinct remote state keys.'

# Task 3: No hardcoded environment strings in modules
$devMain = if (Test-Path (Join-Path $devDir 'main.tf')) { Get-Content (Join-Path $devDir 'main.tf') -Raw } else { '' }
Add-Check 3 'Parameterized environment' ($devMain -match 'environment\s*=\s*"DEV"' -or $devMain -match 'var\.environment') 'Pass environment as variable rather than hardcoding.'

# Task 4: Static validation in DEV environment
if ($All -or -not $Task -or $Task -eq 4) {
    $terraform = Get-Command terraform -ErrorAction SilentlyContinue
    Add-Check 4 'Terraform available' ($null -ne $terraform) 'Install Terraform.'
    if ($terraform -and (Test-Path $devDir)) {
        Push-Location $devDir
        try {
            & terraform fmt -check *> $null
            Add-Check 4 'DEV terraform fmt' ($LASTEXITCODE -eq 0) 'Run terraform fmt in environments/dev.'
            & terraform validate *> $null
            Add-Check 4 'DEV terraform validate' ($LASTEXITCODE -eq 0) 'Run terraform validate in environments/dev.'
        } finally { Pop-Location }
    }
}

# Task 5: Promotion artifact or plan
$planJson = Join-Path $workspace 'm08.tfplan.json'
Add-Check 5 'Plan evidence' ((Test-Path $planJson) -or (Test-Path (Join-Path $devDir 'terraform.tfstate'))) 'Generate plan and save m08.tfplan.json.'

foreach ($result in $results) {
    $status = if ($result.Passed) { 'PASS' } else { 'FAIL' }
    Write-Host "[$status] T$($result.Task) $($result.Name)"
    if (-not $result.Passed) { Write-Host "       $($result.Hint)" }
}

$passed = @($results | Where-Object Passed).Count
$total = $results.Count
Write-Host "Result: $passed/$total"

if ($Report) {
    $reportDir = Join-Path $repoRoot 'student-track\_reports'
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    $initials = if ($env:STUDENT_INITIALS) { $env:STUDENT_INITIALS } else { 'STUDENT' }
    $reportPath = Join-Path $reportDir "module-08-$initials.md"
    $lines = @('# Module 08 validation report', '', "Score: $passed/$total", '', '| Task | Check | Result |', '|---:|---|---|')
    foreach ($result in $results) { $lines += "| $($result.Task) | $($result.Name) | $(if ($result.Passed) { 'PASS' } else { 'FAIL' }) |" }
    $lines | Set-Content $reportPath -Encoding utf8
    Write-Host "Report: $reportPath"
}

if ($passed -ne $total) { exit 1 }
exit 0
