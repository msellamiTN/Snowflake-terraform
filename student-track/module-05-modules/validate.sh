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

# Task 1: Module directory structure
check 1 'Module directory structure' '[[ -d "$workspace/modules/landing-zone" ]] || [[ -d "$workspace/modules" ]]' 'Create a reusable module in modules/landing-zone/ with main.tf, variables.tf, outputs.tf.'

# Task 2: Module interface (variables and outputs)
check 2 'Module inputs declared' '[[ -f "$workspace/modules/landing-zone/variables.tf" ]] && grep -Eq "variable[[:space:]]+\"" "$workspace/modules/landing-zone/variables.tf"' 'Define input variables for the child module.'
check 2 'Module outputs declared' '[[ -f "$workspace/modules/landing-zone/outputs.tf" ]] && grep -Eq "output[[:space:]]+\"" "$workspace/modules/landing-zone/outputs.tf"' 'Define output values from the child module.'

# Task 3: Calling module block in root
check 3 'Module block in root main.tf' 'contains main.tf "module[[:space:]]+\""' 'Instantiate the module using a module "name" {} block.'
check 3 'Module source parameter' 'contains main.tf "source[[:space:]]*="' 'Set source pointing to the relative path of the child module.'

# Task 4: Static validation
if run_for 4; then
  check 4 'Terraform available' 'command -v terraform >/dev/null 2>&1' 'Install Terraform and ensure it is on PATH.'
  if command -v terraform >/dev/null 2>&1 && [[ -f "$workspace/versions.tf" ]]; then
    (cd "$workspace" && terraform fmt -check >/dev/null 2>&1); check 4 'terraform fmt' '[[ $? -eq 0 ]]' 'Run terraform fmt -recursive.'
    (cd "$workspace" && terraform init -backend=false -input=false >/dev/null 2>&1); init_exit=$?
    check 4 'terraform init module resolution' '[[ $init_exit -eq 0 ]]' 'Run terraform init to index local modules.'
    if [[ $init_exit -eq 0 ]]; then
      (cd "$workspace" && terraform validate >/dev/null 2>&1); check 4 'terraform validate' '[[ $? -eq 0 ]]' 'Run terraform validate to check cross-module contracts.'
    fi
  fi
fi

# Task 5: Plan output
check 5 'Plan evidence' 'test -f "$workspace/m05.tfplan.json"' 'Generate plan and save m05.tfplan.json.'

printf 'Result: %d/%d\n' "$passed" "$total"
if $report; then
  report_dir="$repo_root/student-track/_reports"; mkdir -p "$report_dir"
  report_path="$report_dir/module-05-${STUDENT_INITIALS:-STUDENT}.md"
  { printf '# Module 05 validation report\n\nScore: %d/%d\n\n| Task | Check | Result |\n|---:|---|---|\n' "$passed" "$total"; printf '%s\n' "${rows[@]}"; } > "$report_path"
  printf 'Report: %s\n' "$report_path"
fi
[[ $passed -eq $total ]]
