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

$backend = Get-Text 'backend.tf'
$versions = Get-Text 'versions.tf'
$main = Get-Text 'main.tf'

# Task 1: Backend configuration (Azure azurerm, AWS s3, or GCP gcs)
$hasBackendFile = (Test-Path (Join-Path $workspace 'backend.tf')) -or ($versions -match 'backend\s+"(azurerm|s3|gcs)"')
Add-Check 1 'Backend configuration declared' $hasBackendFile 'Declare a remote backend in backend.tf or versions.tf (azurerm, s3, or gcs).'

$hasValidBackendBlock = ($backend -match 'backend\s+"azurerm"' -or $backend -match 'backend\s+"s3"' -or $backend -match 'backend\s+"gcs"' -or $versions -match 'backend\s+"(azurerm|s3|gcs)"')
Add-Check 1 'Backend type supported' $hasValidBackendBlock 'Supported backend types: azurerm (Azure), s3 (AWS), or gcs (Google Cloud).'

# Task 2: Provider and versions pinning
Add-Check 2 'Versions file exists' (Test-Path (Join-Path $workspace 'versions.tf')) 'Create versions.tf to constrain Terraform and providers.'
Add-Check 2 'Snowflake provider configured' ($versions -match 'snowflakedb/snowflake' -or (Get-Text 'provider.tf') -match 'snowflake') 'Ensure snowflake provider is declared.'

# Task 3: State inspection & resource definition
Add-Check 3 'Main resource definition' ($main -match 'resource\s+"snowflake_' -or $main -match 'resource\s+"azurerm_') 'Define at least one managed resource in main.tf.'

# Task 4: Terraform initialization & validation
if ($All -or -not $Task -or $Task -eq 4) {
    $terraform = Get-Command terraform -ErrorAction SilentlyContinue
    Add-Check 4 'Terraform available' ($null -ne $terraform) 'Install Terraform and verify it is on PATH.'
    if ($terraform -and (Test-Path (Join-Path $workspace 'versions.tf'))) {
        Push-Location $workspace
        try {
            & terraform fmt -check *> $null
            Add-Check 4 'terraform fmt' ($LASTEXITCODE -eq 0) 'Run terraform fmt to format your HCL files.'
            & terraform validate *> $null
            Add-Check 4 'terraform validate' ($LASTEXITCODE -eq 0) 'Run terraform validate to check syntax and arguments.'
        } finally { Pop-Location }
    }
}

# Task 5: Remote state migration or plan evidence
$planJson = Join-Path $workspace 'm02.tfplan.json'
$hasStateOrPlan = (Test-Path $planJson) -or (Test-Path (Join-Path $workspace '.terraform/terraform.tfstate'))
Add-Check 5 'Remote state initialized or plan saved' $hasStateOrPlan 'Initialize the remote backend with terraform init or export m02.tfplan.json.'

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
    $reportPath = Join-Path $reportDir "module-02-$initials.md"
    $lines = @('# Module 02 validation report', '', "Score: $passed/$total", '', '| Task | Check | Result |', '|---:|---|---|')
    foreach ($result in $results) { $lines += "| $($result.Task) | $($result.Name) | $(if ($result.Passed) { 'PASS' } else { 'FAIL' }) |" }
    $lines | Set-Content $reportPath -Encoding utf8
    Write-Host "Report: $reportPath"
}

if ($passed -ne $total) { exit 1 }
exit 0
