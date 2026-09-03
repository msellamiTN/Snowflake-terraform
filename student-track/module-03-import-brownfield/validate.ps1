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
$importTf = Get-Text 'import.tf'
$versions = Get-Text 'versions.tf'

# Task 1: Versions and setup
Add-Check 1 'versions.tf exists' (Test-Path (Join-Path $workspace 'versions.tf')) 'Create versions.tf in the workspace root.'
Add-Check 1 'Terraform version >= 1.5.0 for import block' ($versions -match 'required_version') 'Terraform 1.5+ is required to support the import {} block.'

# Task 2: Import block or resource mapping declared
$hasImportDeclaration = ($importTf -match 'import\s*\{' -or $main -match 'import\s*\{' -or $main -match 'resource\s+"snowflake_')
Add-Check 2 'Import block declared' $hasImportDeclaration 'Declare an import {} block with "to" and "id" attributes.'

# Task 3: Target resource definition
Add-Check 3 'Target resource in main.tf' ($main -match 'resource\s+"snowflake_(database|schema|warehouse)"') 'Define the target snowflake resource corresponding to the imported object.'

# Task 4: Static validation
if ($All -or -not $Task -or $Task -eq 4) {
    $terraform = Get-Command terraform -ErrorAction SilentlyContinue
    Add-Check 4 'Terraform available' ($null -ne $terraform) 'Install Terraform and ensure it is on PATH.'
    if ($terraform -and (Test-Path (Join-Path $workspace 'versions.tf'))) {
        Push-Location $workspace
        try {
            & terraform fmt -check *> $null
            Add-Check 4 'terraform fmt' ($LASTEXITCODE -eq 0) 'Run terraform fmt to format your files.'
            & terraform validate *> $null
            Add-Check 4 'terraform validate' ($LASTEXITCODE -eq 0) 'Run terraform validate to check syntax.'
        } finally { Pop-Location }
    }
}

# Task 5: Zero-drift or planned import evidence
$planJson = Join-Path $workspace 'm03.tfplan.json'
$hasImportEvidence = (Test-Path $planJson) -or (Test-Path (Join-Path $workspace 'generated.tf'))
Add-Check 5 'Import plan or generated config' $hasImportEvidence 'Run terraform plan with import or generate-config-out, and save m03.tfplan.json.'

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
    $reportPath = Join-Path $reportDir "module-03-$initials.md"
    $lines = @('# Module 03 validation report', '', "Score: $passed/$total", '', '| Task | Check | Result |', '|---:|---|---|')
    foreach ($result in $results) { $lines += "| $($result.Task) | $($result.Name) | $(if ($result.Passed) { 'PASS' } else { 'FAIL' }) |" }
    $lines | Set-Content $reportPath -Encoding utf8
    Write-Host "Report: $reportPath"
}

if ($passed -ne $total) { exit 1 }
exit 0
