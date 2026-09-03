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
$moduleDir = Join-Path $workspace 'modules/landing-zone'
$hasModuleDir = (Test-Path $moduleDir) -or (Test-Path (Join-Path $workspace 'modules'))

# Task 1: Module directory structure
Add-Check 1 'Module directory structure' $hasModuleDir 'Create a reusable module in modules/landing-zone/ with main.tf, variables.tf, outputs.tf.'

# Task 2: Module interface (variables and outputs)
$moduleVars = if (Test-Path (Join-Path $moduleDir 'variables.tf')) { Get-Content (Join-Path $moduleDir 'variables.tf') -Raw } else { '' }
$moduleOutputs = if (Test-Path (Join-Path $moduleDir 'outputs.tf')) { Get-Content (Join-Path $moduleDir 'outputs.tf') -Raw } else { '' }
Add-Check 2 'Module inputs declared' ($moduleVars -match 'variable\s+"') 'Define input variables for the child module.'
Add-Check 2 'Module outputs declared' ($moduleOutputs -match 'output\s+"') 'Define output values from the child module.'

# Task 3: Calling module block in root
Add-Check 3 'Module block in root main.tf' ($main -match 'module\s+"') 'Instantiate the module using a module "name" {} block.'
Add-Check 3 'Module source parameter' ($main -match 'source\s*=') 'Set source pointing to the relative path of the child module.'

# Task 4: Static validation
if ($All -or -not $Task -or $Task -eq 4) {
    $terraform = Get-Command terraform -ErrorAction SilentlyContinue
    Add-Check 4 'Terraform available' ($null -ne $terraform) 'Install Terraform and ensure it is on PATH.'
    if ($terraform -and (Test-Path (Join-Path $workspace 'versions.tf'))) {
        Push-Location $workspace
        try {
            & terraform fmt -check *> $null
            Add-Check 4 'terraform fmt' ($LASTEXITCODE -eq 0) 'Run terraform fmt -recursive.'
            & terraform init -backend=false -input=false *> $null
            $initExit = $LASTEXITCODE
            Add-Check 4 'terraform init module resolution' ($initExit -eq 0) 'Run terraform init to index local modules.'
            if ($initExit -eq 0) {
                & terraform validate *> $null
                Add-Check 4 'terraform validate' ($LASTEXITCODE -eq 0) 'Run terraform validate to check cross-module contracts.'
            }
        } finally { Pop-Location }
    }
}

# Task 5: Plan output
$planJson = Join-Path $workspace 'm05.tfplan.json'
Add-Check 5 'Plan evidence' (Test-Path $planJson) 'Generate plan and save m05.tfplan.json.'

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
    $reportPath = Join-Path $reportDir "module-05-$initials.md"
    $lines = @('# Module 05 validation report', '', "Score: $passed/$total", '', '| Task | Check | Result |', '|---:|---|---|')
    foreach ($result in $results) { $lines += "| $($result.Task) | $($result.Name) | $(if ($result.Passed) { 'PASS' } else { 'FAIL' }) |" }
    $lines | Set-Content $reportPath -Encoding utf8
    Write-Host "Report: $reportPath"
}

if ($passed -ne $total) { exit 1 }
exit 0
