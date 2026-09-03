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

dev_dir=""
if [[ -d "$workspace/environments/dev" ]]; then
  dev_dir="$workspace/environments/dev"
elif [[ -d "$workspace/dev" ]]; then
  dev_dir="$workspace/dev"
fi

# Task 1: Environment directory separation
check 1 'DEV environment folder exists' '[[ -n "$dev_dir" && -d "$dev_dir" ]]' 'Create environments/dev directory structure.'

# Task 2: Separate state keys per environment
check 2 'Environment state isolation' '[[ -n "$dev_dir" ]] && ([[ -f "$dev_dir/backend.tf" ]] && grep -Eq "key[[:space:]]*=[[:space:]]*\"(environments/)?dev" "$dev_dir/backend.tf" || [[ -f "$dev_dir/main.tf" ]])' 'Ensure DEV and PROD use distinct remote state keys.'

# Task 3: No hardcoded environment strings in modules
check 3 'Parameterized environment' '[[ -n "$dev_dir" && -f "$dev_dir/main.tf" ]] && grep -Eq "environment[[:space:]]*=[[:space:]]*\"DEV\"|var\\.environment" "$dev_dir/main.tf"' 'Pass environment as variable rather than hardcoding.'

# Task 4: Static validation in DEV environment
if run_for 4; then
  check 4 'Terraform available' 'command -v terraform >/dev/null 2>&1' 'Install Terraform.'
  if command -v terraform >/dev/null 2>&1 && [[ -n "$dev_dir" && -d "$dev_dir" ]]; then
    (cd "$dev_dir" && terraform fmt -check >/dev/null 2>&1); check 4 'DEV terraform fmt' '[[ $? -eq 0 ]]' 'Run terraform fmt in environments/dev.'
    (cd "$dev_dir" && terraform validate >/dev/null 2>&1); check 4 'DEV terraform validate' '[[ $? -eq 0 ]]' 'Run terraform validate in environments/dev.'
  fi
fi

# Task 5: Promotion artifact or plan
check 5 'Plan evidence' '[[ -f "$workspace/m08.tfplan.json" ]] || ([[ -n "$dev_dir" ]] && [[ -f "$dev_dir/terraform.tfstate" ]])' 'Generate plan and save m08.tfplan.json.'

printf 'Result: %d/%d\n' "$passed" "$total"
if $report; then
  report_dir="$repo_root/student-track/_reports"; mkdir -p "$report_dir"
  report_path="$report_dir/module-08-${STUDENT_INITIALS:-STUDENT}.md"
  { printf '# Module 08 validation report\n\nScore: %d/%d\n\n| Task | Check | Result |\n|---:|---|---|\n' "$passed" "$total"; printf '%s\n' "${rows[@]}"; } > "$report_path"
  printf 'Report: %s\n' "$report_path"
fi
[[ $passed -eq $total ]]
