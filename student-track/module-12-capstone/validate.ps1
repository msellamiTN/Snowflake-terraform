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

function Get-Text([string]$Name) {
    $path = Join-Path $workspace $Name
    if (Test-Path $path) { return Get-Content $path -Raw }
    return ''
}

$main = Get-Text 'main.tf'
$backend = Get-Text 'backend.tf'

# Task 1: Remote Azure Blob backend declared
$hasAzureBackend = ($backend -match 'backend\s+"azurerm"' -or (Get-Text 'versions.tf') -match 'backend\s+"azurerm"')
Add-Check 1 'Azure Blob remote backend configured' $hasAzureBackend 'Configure backend "azurerm" with storage account and container.'

# Task 2: Landing zone module composed
$hasLandingModule = ($main -match 'module\s+"landing_zone"' -or $main -match 'module\s+"data_platform"')
Add-Check 2 'Landing zone module composed' $hasLandingModule 'Instantiate the landing zone module in main.tf.'

# Task 3: RBAC module or rules composed
$hasRbac = ($main -match 'module\s+"rbac"' -or $main -match 'snowflake_account_role')
Add-Check 3 'RBAC architecture composed' $hasRbac 'Instantiate RBAC module or declare role hierarchy in main.tf.'

# Task 4: Static validation
if ($All -or -not $Task -or $Task -eq 4) {
    $terraform = Get-Command terraform -ErrorAction SilentlyContinue
    Add-Check 4 'Terraform available' ($null -ne $terraform) 'Install Terraform.'
    if ($terraform -and (Test-Path (Join-Path $workspace 'versions.tf'))) {
        Push-Location $workspace
        try {
            & terraform fmt -check *> $null
            Add-Check 4 'terraform fmt' ($LASTEXITCODE -eq 0) 'Run terraform fmt -recursive.'
            & terraform validate *> $null
            Add-Check 4 'terraform validate' ($LASTEXITCODE -eq 0) 'Run terraform validate to check capstone assembly.'
        } finally { Pop-Location }
    }
}

# Task 5: Capstone plan evidence
$planJson = Join-Path $workspace 'm12.tfplan.json'
Add-Check 5 'Capstone plan evidence' (Test-Path $planJson) 'Generate final capstone plan and export m12.tfplan.json.'

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
    $reportPath = Join-Path $reportDir "module-12-$initials.md"
    $lines = @('# Module 12 Capstone validation report', '', "Score: $passed/$total", '', '| Task | Check | Result |', '|---:|---|---|')
    foreach ($result in $results) { $lines += "| $($result.Task) | $($result.Name) | $(if ($result.Passed) { 'PASS' } else { 'FAIL' }) |" }
    $lines | Set-Content $reportPath -Encoding utf8
    Write-Host "Report: $reportPath"
}

if ($passed -ne $total) { exit 1 }
exit 0
