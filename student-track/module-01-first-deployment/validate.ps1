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

$versions = Get-Text 'versions.tf'
$provider = Get-Text 'provider.tf'
$variables = Get-Text 'variables.tf'
$locals = Get-Text 'locals.tf'
$main = Get-Text 'main.tf'
$outputs = Get-Text 'outputs.tf'

Add-Check 1 'versions.tf exists' (Test-Path (Join-Path $workspace 'versions.tf')) 'Create versions.tf in the workspace root.'
Add-Check 1 'Snowflake provider pinned' ($versions -match 'snowflakedb/snowflake' -and $versions -match '~>\s*2\.14\.0') 'Declare snowflakedb/snowflake with ~> 2.14.0.'
Add-Check 1 'provider.tf uses profile' ($provider -match 'profile\s*=\s*var\.snowflake_profile') 'Use the Snowflake CLI profile; do not add a password or token.'
Add-Check 1 'No credential in provider' ($provider -notmatch 'password\s*=|token\s*=|private_key\s*=') 'Remove credentials from provider.tf.'

Add-Check 2 'Required variables' ($variables -match 'variable\s+"snowflake_profile"' -and $variables -match 'variable\s+"learner_prefix"' -and $variables -match 'variable\s+"environment"' -and $variables -match 'variable\s+"warehouse_size"') 'Create the four variables from the guide.'
Add-Check 2 'Unique naming locals' ($locals -match 'var\.learner_prefix' -and $locals -match 'database_name' -and $locals -match 'warehouse_name') 'Build names from learner_prefix and environment.'
Add-Check 2 'Local tfvars ignored' ((& git -C $workspace check-ignore terraform.tfvars 2>$null) -eq 'terraform.tfvars') 'terraform.tfvars must remain ignored.'

Add-Check 3 'Database resource' ($main -match 'resource\s+"snowflake_database"\s+"raw"') 'Create snowflake_database.raw.'
Add-Check 3 'Schema resource' ($main -match 'resource\s+"snowflake_schema"\s+"ingestion"') 'Create snowflake_schema.ingestion.'
Add-Check 3 'Implicit dependency' ($main -match 'database\s*=\s*snowflake_database\.raw\.name') 'Reference the database resource from the schema.'
Add-Check 3 'Cost-controlled warehouse' ($main -match 'resource\s+"snowflake_warehouse"\s+"etl"' -and $main -match 'auto_suspend\s*=\s*60' -and $main -match 'initially_suspended\s*=\s*true') 'Add the warehouse with auto_suspend=60 and initially_suspended=true.'
Add-Check 3 'Outputs' ($outputs -match 'output\s+"database_name"' -and $outputs -match 'output\s+"schema_name"' -and $outputs -match 'output\s+"warehouse_name"') 'Create the three required outputs.'

if ($All -or -not $Task -or $Task -eq 4) {
    $terraform = Get-Command terraform -ErrorAction SilentlyContinue
    Add-Check 4 'Terraform available' ($null -ne $terraform) 'Install Terraform and open a new terminal.'
    if ($terraform -and (Test-Path (Join-Path $workspace 'versions.tf'))) {
        Push-Location $workspace
        try {
            & terraform fmt -check *> $null
            Add-Check 4 'terraform fmt' ($LASTEXITCODE -eq 0) 'Run terraform fmt and retry.'
            & terraform init -backend=false -input=false *> $null
            $initExit = $LASTEXITCODE
            Add-Check 4 'terraform init' ($initExit -eq 0) 'Check network access and provider version.'
            if ($initExit -eq 0) {
                & terraform validate *> $null
                Add-Check 4 'terraform validate' ($LASTEXITCODE -eq 0) 'Read the exact terraform validate error.'
            }
        } finally { Pop-Location }
    }
}

$planJson = Join-Path $workspace 'm01.tfplan.json'
Add-Check 5 'Plan evidence' (Test-Path $planJson) 'Save the plan and export it with terraform show -json m01.tfplan.'
if (Test-Path $planJson) {
    try {
        $plan = Get-Content $planJson -Raw | ConvertFrom-Json
        $creates = @($plan.resource_changes | Where-Object { $_.change.actions -contains 'create' })
        Add-Check 5 'Three resources planned' ($creates.Count -eq 3) 'Expected one database, one schema, and one warehouse.'
        $destructive = @($plan.resource_changes | Where-Object { $_.change.actions -contains 'delete' })
        Add-Check 5 'No deletion planned' ($destructive.Count -eq 0) 'Stop and inspect every delete action.'
    } catch {
        Add-Check 5 'Readable plan JSON' $false 'Regenerate m01.tfplan.json with terraform show -json.'
    }
}

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
    $reportPath = Join-Path $reportDir "module-01-$initials.md"
    $lines = @('# Module 01 validation report', '', "Score: $passed/$total", '', '| Task | Check | Result |', '|---:|---|---|')
    foreach ($result in $results) { $lines += "| $($result.Task) | $($result.Name) | $(if ($result.Passed) { 'PASS' } else { 'FAIL' }) |" }
    $lines | Set-Content $reportPath -Encoding utf8
    Write-Host "Report: $reportPath"
}
if ($passed -ne $total) { exit 1 }
exit 0
