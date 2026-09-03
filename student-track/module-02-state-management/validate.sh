#!/usr/bin/env bash
set -u

task=''
all=false
report=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) task="$2"; shift 2 ;;
    --all) all=true; shift ;;
    --report) report=true; shift ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
done
workspace="${STUDENT_WORKSPACE:-$PWD}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
passed=0
total=0
rows=()
run_for() { $all || [[ -z "$task" || "$task" == "$1" ]]; }
check() {
  local number="$1" name="$2" condition="$3" hint="$4"
  run_for "$number" || return
  total=$((total + 1))
  if eval "$condition"; then passed=$((passed + 1)); rows+=("| $number | $name | PASS |"); printf '[PASS] T%s %s\n' "$number" "$name"
  else rows+=("| $number | $name | FAIL |"); printf '[FAIL] T%s %s\n       %s\n' "$number" "$name" "$hint"; fi
}
contains() { [[ -f "$workspace/$1" ]] && grep -Eq "$2" "$workspace/$1"; }

# Task 1: Backend configuration declared and supported
check 1 'Backend configuration declared' '[[ -f "$workspace/backend.tf" ]] || contains versions.tf "backend[[:space:]]+\"(azurerm|s3|gcs)\""' 'Declare a remote backend in backend.tf or versions.tf (azurerm, s3, or gcs).'
check 1 'Backend type supported' 'contains backend.tf "backend[[:space:]]+\"(azurerm|s3|gcs)\"" || contains versions.tf "backend[[:space:]]+\"(azurerm|s3|gcs)\""' 'Supported backend types: azurerm (Azure), s3 (AWS), or gcs (Google Cloud).'

# Task 2: Versions and provider pinning
check 2 'Versions file exists' 'test -f "$workspace/versions.tf"' 'Create versions.tf to constrain Terraform and providers.'
check 2 'Snowflake provider configured' 'contains versions.tf "snowflakedb/snowflake" || contains provider.tf "snowflake"' 'Ensure snowflake provider is declared.'

# Task 3: Resource definition
check 3 'Main resource definition' 'contains main.tf "resource[[:space:]]+\"snowflake_" || contains main.tf "resource[[:space:]]+\"azurerm_"' 'Define at least one managed resource in main.tf.'

# Task 4: Static validation
if run_for 4; then
  check 4 'Terraform available' 'command -v terraform >/dev/null 2>&1' 'Install Terraform and verify it is on PATH.'
  if command -v terraform >/dev/null 2>&1 && [[ -f "$workspace/versions.tf" ]]; then
    (cd "$workspace" && terraform fmt -check >/dev/null 2>&1); check 4 'terraform fmt' '[[ $? -eq 0 ]]' 'Run terraform fmt to format your HCL files.'
    (cd "$workspace" && terraform validate >/dev/null 2>&1); check 4 'terraform validate' '[[ $? -eq 0 ]]' 'Run terraform validate to check syntax and arguments.'
  fi
fi

# Task 5: Remote state or plan evidence
check 5 'Remote state initialized or plan saved' '[[ -f "$workspace/m02.tfplan.json" ]] || [[ -f "$workspace/.terraform/terraform.tfstate" ]]' 'Initialize the remote backend with terraform init or export m02.tfplan.json.'

printf 'Result: %d/%d\n' "$passed" "$total"
if $report; then
  report_dir="$repo_root/student-track/_reports"; mkdir -p "$report_dir"
  report_path="$report_dir/module-02-${STUDENT_INITIALS:-STUDENT}.md"
  { printf '# Module 02 validation report\n\nScore: %d/%d\n\n| Task | Check | Result |\n|---:|---|---|\n' "$passed" "$total"; printf '%s\n' "${rows[@]}"; } > "$report_path"
  printf 'Report: %s\n' "$report_path"
fi
[[ $passed -eq $total ]]
