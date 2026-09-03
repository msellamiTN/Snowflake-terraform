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
$provider = Get-Text 'provider.tf'

# Task 1: Service user resource
$hasServiceUser = ($main -match 'resource\s+"snowflake_user"' -or $main -match 'resource\s+"snowflake_service_user"')
Add-Check 1 'Service user resource declared' $hasServiceUser 'Declare a snowflake_user for the service principal.'

# Task 2: Public key attribute configured on user
$hasPublicKey = ($main -match 'rsa_public_key\s*=' -or $main -match 'rsa_public_key_2\s*=')
Add-Check 2 'RSA public key configured' $hasPublicKey 'Set rsa_public_key on the Snowflake user.'

# Task 3: Zero private key committed in Git
$noPrivateKeyInHcl = ($main -notmatch 'BEGIN (RSA )?PRIVATE KEY' -and $provider -notmatch 'BEGIN (RSA )?PRIVATE KEY')
Add-Check 3 'Zero private keys in HCL' $noPrivateKeyInHcl 'Never put raw RSA private keys in .tf files; load from Azure Key Vault or file.'

# Task 4: Static validation
if ($All -or -not $Task -or $Task -eq 4) {
    $terraform = Get-Command terraform -ErrorAction SilentlyContinue
    Add-Check 4 'Terraform available' ($null -ne $terraform) 'Install Terraform.'
    if ($terraform -and (Test-Path (Join-Path $workspace 'versions.tf'))) {
        Push-Location $workspace
        try {
            & terraform fmt -check *> $null
            Add-Check 4 'terraform fmt' ($LASTEXITCODE -eq 0) 'Run terraform fmt.'
            & terraform validate *> $null
            Add-Check 4 'terraform validate' ($LASTEXITCODE -eq 0) 'Run terraform validate to check security definitions.'
        } finally { Pop-Location }
    }
}

# Task 5: Plan output
$planJson = Join-Path $workspace 'm10.tfplan.json'
Add-Check 5 'Plan evidence' (Test-Path $planJson) 'Generate plan and save m10.tfplan.json.'

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
    $reportPath = Join-Path $reportDir "module-10-$initials.md"
    $lines = @('# Module 10 validation report', '', "Score: $passed/$total", '', '| Task | Check | Result |', '|---:|---|---|')
    foreach ($result in $results) { $lines += "| $($result.Task) | $($result.Name) | $(if ($result.Passed) { 'PASS' } else { 'FAIL' }) |" }
    $lines | Set-Content $reportPath -Encoding utf8
    Write-Host "Report: $reportPath"
}

if ($passed -ne $total) { exit 1 }
exit 0
