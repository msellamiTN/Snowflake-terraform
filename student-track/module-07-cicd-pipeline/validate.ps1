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

$azurePipeline = Get-Text 'azure-pipelines.yml'
$githubWorkflow = Get-Text '.github/workflows/terraform.yml'
$hasCiFile = (Test-Path (Join-Path $workspace 'azure-pipelines.yml')) -or (Test-Path (Join-Path $workspace '.github/workflows/terraform.yml'))

# Task 1: Pipeline definition file
Add-Check 1 'CI pipeline file exists' $hasCiFile 'Create azure-pipelines.yml or .github/workflows/terraform.yml.'

# Task 2: Validate & plan stages
$pipelineContent = if ($azurePipeline) { $azurePipeline } else { $githubWorkflow }
$hasValidateStage = ($pipelineContent -match 'terraform\s+validate' -or $pipelineContent -match 'Validate')
$hasPlanStage = ($pipelineContent -match 'terraform\s+plan' -or $pipelineContent -match 'Plan')
Add-Check 2 'Validation stage declared' $hasValidateStage 'Include a validation step (fmt/validate) in the pipeline.'
Add-Check 2 'Plan stage declared' $hasPlanStage 'Include a speculative plan step in the pipeline.'

# Task 3: Apply stage with approval gate
$hasApplyStage = ($pipelineContent -match 'terraform\s+apply' -or $pipelineContent -match 'Apply')
Add-Check 3 'Apply stage declared' $hasApplyStage 'Include an apply step conditional on main/approval.'

# Task 4: Security and secrets hygiene in CI
$noHardcodedSecrets = ($pipelineContent -notmatch 'password:\s*["\w]+' -and $pipelineContent -notmatch 'token:\s*["\w]{10,}')
Add-Check 4 'Zero hardcoded secrets in CI' $noHardcodedSecrets 'Use pipeline variable groups, GitHub secrets, or OIDC federation.'

# Task 5: Static syntax check of YAML
$yamlValid = $hasCiFile -and ($pipelineContent.Length -gt 50)
Add-Check 5 'Pipeline file populated' $yamlValid 'Ensure the CI pipeline definition contains complete steps.'

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
    $reportPath = Join-Path $reportDir "module-07-$initials.md"
    $lines = @('# Module 07 validation report', '', "Score: $passed/$total", '', '| Task | Check | Result |', '|---:|---|---|')
    foreach ($result in $results) { $lines += "| $($result.Task) | $($result.Name) | $(if ($result.Passed) { 'PASS' } else { 'FAIL' }) |" }
    $lines | Set-Content $reportPath -Encoding utf8
    Write-Host "Report: $reportPath"
}

if ($passed -ne $total) { exit 1 }
exit 0
