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

# Task 1: Type constraints in variables.tf
check 1 'variables.tf exists' 'test -f "$workspace/variables.tf"' 'Create variables.tf in workspace root.'
check 1 'Typed variables declared' 'contains variables.tf "type[[:space:]]*=[[:space:]]*(string|list|map|number|bool|object)"' 'Add explicit type constraints to all variables.'

# Task 2: Custom validation rules
check 2 'Validation block defined' 'contains variables.tf "validation[[:space:]]*\\{" && contains variables.tf "condition[[:space:]]*=" && contains variables.tf "error_message[[:space:]]*="' 'Implement custom validation {} with condition and error_message.'

# Task 3: Locals computation
check 3 'locals.tf exists' 'test -f "$workspace/locals.tf"' 'Create locals.tf in workspace root.'
check 3 'Computed naming locals' 'contains locals.tf "locals[[:space:]]*\\{"' 'Use locals to encapsulate computed resource names.'

# Task 4: Static validation
if run_for 4; then
  check 4 'Terraform available' 'command -v terraform >/dev/null 2>&1' 'Install Terraform and ensure it is on PATH.'
  if command -v terraform >/dev/null 2>&1 && [[ -f "$workspace/versions.tf" ]]; then
    (cd "$workspace" && terraform fmt -check >/dev/null 2>&1); check 4 'terraform fmt' '[[ $? -eq 0 ]]' 'Run terraform fmt.'
    (cd "$workspace" && terraform validate >/dev/null 2>&1); check 4 'terraform validate' '[[ $? -eq 0 ]]' 'Run terraform validate to check your validation logic.'
  fi
fi

# Task 5: Outputs defined
check 5 'outputs.tf defined' 'test -f "$workspace/outputs.tf"' 'Create outputs.tf with relevant outputs.'
check 5 'Output declarations' 'contains outputs.tf "output[[:space:]]+\""' 'Declare outputs to expose infrastructure metadata.'

printf 'Result: %d/%d\n' "$passed" "$total"
if $report; then
  report_dir="$repo_root/student-track/_reports"; mkdir -p "$report_dir"
  report_path="$report_dir/module-04-${STUDENT_INITIALS:-STUDENT}.md"
  { printf '# Module 04 validation report\n\nScore: %d/%d\n\n| Task | Check | Result |\n|---:|---|---|\n' "$passed" "$total"; printf '%s\n' "${rows[@]}"; } > "$report_path"
  printf 'Report: %s\n' "$report_path"
fi
[[ $passed -eq $total ]]
