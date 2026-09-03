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

# Task 1: Map or set collection variable
check 1 'Collection variable declared' 'contains variables.tf "type[[:space:]]*=[[:space:]]*(map|set|list\(object)"' 'Declare a map, set or list of objects to drive iterations.'

# Task 2: for_each meta-argument used
check 2 'for_each used' 'contains main.tf "for_each[[:space:]]*="' 'Use for_each instead of count to maintain stable resource addresses.'

# Task 3: each.key or each.value references
check 3 'each context referenced' 'contains main.tf "each\\.key" || contains main.tf "each\\.value"' 'Reference each.key or each.value in the iterated resource block.'

# Task 4: Static validation
if run_for 4; then
  check 4 'Terraform available' 'command -v terraform >/dev/null 2>&1' 'Install Terraform and ensure it is on PATH.'
  if command -v terraform >/dev/null 2>&1 && [[ -f "$workspace/versions.tf" ]]; then
    (cd "$workspace" && terraform fmt -check >/dev/null 2>&1); check 4 'terraform fmt' '[[ $? -eq 0 ]]' 'Run terraform fmt.'
    (cd "$workspace" && terraform validate >/dev/null 2>&1); check 4 'terraform validate' '[[ $? -eq 0 ]]' 'Run terraform validate to check dynamic logic.'
  fi
fi

# Task 5: Plan output
check 5 'Plan evidence' 'test -f "$workspace/m06.tfplan.json"' 'Generate plan and save m06.tfplan.json.'

printf 'Result: %d/%d\n' "$passed" "$total"
if $report; then
  report_dir="$repo_root/student-track/_reports"; mkdir -p "$report_dir"
  report_path="$report_dir/module-06-${STUDENT_INITIALS:-STUDENT}.md"
  { printf '# Module 06 validation report\n\nScore: %d/%d\n\n| Task | Check | Result |\n|---:|---|---|\n' "$passed" "$total"; printf '%s\n' "${rows[@]}"; } > "$report_path"
  printf 'Report: %s\n' "$report_path"
fi
[[ $passed -eq $total ]]
