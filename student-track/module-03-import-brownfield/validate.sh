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

# Task 1: Versions and setup
check 1 'versions.tf exists' 'test -f "$workspace/versions.tf"' 'Create versions.tf in the workspace root.'
check 1 'Terraform version >= 1.5.0 for import block' 'contains versions.tf "required_version"' 'Terraform 1.5+ is required to support the import {} block.'

# Task 2: Import block or resource mapping declared
check 2 'Import block declared' 'contains import.tf "import[[:space:]]*\\{" || contains main.tf "import[[:space:]]*\\{" || contains main.tf "resource[[:space:]]+\"snowflake_"' 'Declare an import {} block with "to" and "id" attributes.'

# Task 3: Target resource in main.tf
check 3 'Target resource in main.tf' 'contains main.tf "resource[[:space:]]+\"snowflake_(database|schema|warehouse)\""' 'Define the target snowflake resource corresponding to the imported object.'

# Task 4: Static validation
if run_for 4; then
  check 4 'Terraform available' 'command -v terraform >/dev/null 2>&1' 'Install Terraform and ensure it is on PATH.'
  if command -v terraform >/dev/null 2>&1 && [[ -f "$workspace/versions.tf" ]]; then
    (cd "$workspace" && terraform fmt -check >/dev/null 2>&1); check 4 'terraform fmt' '[[ $? -eq 0 ]]' 'Run terraform fmt to format your files.'
    (cd "$workspace" && terraform validate >/dev/null 2>&1); check 4 'terraform validate' '[[ $? -eq 0 ]]' 'Run terraform validate to check syntax.'
  fi
fi

# Task 5: Import plan or generated config
check 5 'Import plan or generated config' '[[ -f "$workspace/m03.tfplan.json" ]] || [[ -f "$workspace/generated.tf" ]]' 'Run terraform plan with import or generate-config-out, and save m03.tfplan.json.'

printf 'Result: %d/%d\n' "$passed" "$total"
if $report; then
  report_dir="$repo_root/student-track/_reports"; mkdir -p "$report_dir"
  report_path="$report_dir/module-03-${STUDENT_INITIALS:-STUDENT}.md"
  { printf '# Module 03 validation report\n\nScore: %d/%d\n\n| Task | Check | Result |\n|---:|---|---|\n' "$passed" "$total"; printf '%s\n' "${rows[@]}"; } > "$report_path"
  printf 'Report: %s\n' "$report_path"
fi
[[ $passed -eq $total ]]
