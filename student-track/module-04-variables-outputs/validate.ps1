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

$variables = Get-Text 'variables.tf'
$locals = Get-Text 'locals.tf'
$outputs = Get-Text 'outputs.tf'

# Task 1: Type constraints in variables.tf
Add-Check 1 'variables.tf exists' (Test-Path (Join-Path $workspace 'variables.tf')) 'Create variables.tf in workspace root.'
Add-Check 1 'Typed variables declared' ($variables -match 'type\s*=\s*(string|list|map|number|bool|object)') 'Add explicit type constraints to all variables.'

# Task 2: Custom validation rules
$hasValidationBlock = ($variables -match 'validation\s*\{' -and $variables -match 'condition\s*=' -and $variables -match 'error_message\s*=')
Add-Check 2 'Validation block defined' $hasValidationBlock 'Implement custom validation {} with condition and error_message.'

# Task 3: Locals computation
Add-Check 3 'locals.tf exists' (Test-Path (Join-Path $workspace 'locals.tf')) 'Create locals.tf in workspace root.'
Add-Check 3 'Computed naming locals' ($locals -match 'locals\s*\{') 'Use locals to encapsulate computed resource names.'

# Task 4: Static validation
if ($All -or -not $Task -or $Task -eq 4) {
    $terraform = Get-Command terraform -ErrorAction SilentlyContinue
    Add-Check 4 'Terraform available' ($null -ne $terraform) 'Install Terraform and ensure it is on PATH.'
    if ($terraform -and (Test-Path (Join-Path $workspace 'versions.tf'))) {
        Push-Location $workspace
        try {
            & terraform fmt -check *> $null
            Add-Check 4 'terraform fmt' ($LASTEXITCODE -eq 0) 'Run terraform fmt.'
            & terraform validate *> $null
            Add-Check 4 'terraform validate' ($LASTEXITCODE -eq 0) 'Run terraform validate to check your validation logic.'
        } finally { Pop-Location }
    }
}

# Task 5: Outputs defined
Add-Check 5 'outputs.tf defined' (Test-Path (Join-Path $workspace 'outputs.tf')) 'Create outputs.tf with relevant outputs.'
Add-Check 5 'Output declarations' ($outputs -match 'output\s+"') 'Declare outputs to expose infrastructure metadata.'

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
    $reportPath = Join-Path $reportDir "module-04-$initials.md"
    $lines = @('# Module 04 validation report', '', "Score: $passed/$total", '', '| Task | Check | Result |', '|---:|---|---|')
    foreach ($result in $results) { $lines += "| $($result.Task) | $($result.Name) | $(if ($result.Passed) { 'PASS' } else { 'FAIL' }) |" }
    $lines | Set-Content $reportPath -Encoding utf8
    Write-Host "Report: $reportPath"
}

if ($passed -ne $total) { exit 1 }
exit 0
