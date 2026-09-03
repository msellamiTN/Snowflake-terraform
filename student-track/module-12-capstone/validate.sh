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

# Task 1: Remote Azure Blob backend declared
check 1 'Azure Blob remote backend configured' 'contains backend.tf "backend[[:space:]]+\"azurerm\"" || contains versions.tf "backend[[:space:]]+\"azurerm\""' 'Configure backend "azurerm" with storage account and container.'

# Task 2: Landing zone module composed
check 2 'Landing zone module composed' 'contains main.tf "module[[:space:]]+\"(landing_zone|data_platform)\""' 'Instantiate the landing zone module in main.tf.'

# Task 3: RBAC module or rules composed
check 3 'RBAC architecture composed' 'contains main.tf "module[[:space:]]+\"rbac\"" || contains main.tf "snowflake_account_role"' 'Instantiate RBAC module or declare role hierarchy in main.tf.'

# Task 4: Static validation
if run_for 4; then
  check 4 'Terraform available' 'command -v terraform >/dev/null 2>&1' 'Install Terraform.'
  if command -v terraform >/dev/null 2>&1 && [[ -f "$workspace/versions.tf" ]]; then
    (cd "$workspace" && terraform fmt -check >/dev/null 2>&1); check 4 'terraform fmt' '[[ $? -eq 0 ]]' 'Run terraform fmt -recursive.'
    (cd "$workspace" && terraform validate >/dev/null 2>&1); check 4 'terraform validate' '[[ $? -eq 0 ]]' 'Run terraform validate to check capstone assembly.'
  fi
fi

# Task 5: Capstone plan evidence
check 5 'Capstone plan evidence' 'test -f "$workspace/m12.tfplan.json"' 'Generate final capstone plan and export m12.tfplan.json.'

printf 'Result: %d/%d\n' "$passed" "$total"
if $report; then
  report_dir="$repo_root/student-track/_reports"; mkdir -p "$report_dir"
  report_path="$report_dir/module-12-${STUDENT_INITIALS:-STUDENT}.md"
  { printf '# Module 12 Capstone validation report\n\nScore: %d/%d\n\n| Task | Check | Result |\n|---:|---|---|\n' "$passed" "$total"; printf '%s\n' "${rows[@]}"; } > "$report_path"
  printf 'Report: %s\n' "$report_path"
fi
[[ $passed -eq $total ]]
