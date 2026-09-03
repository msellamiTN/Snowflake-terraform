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

ci_file=""
if [[ -f "$workspace/azure-pipelines.yml" ]]; then
  ci_file="$workspace/azure-pipelines.yml"
elif [[ -f "$workspace/.github/workflows/terraform.yml" ]]; then
  ci_file="$workspace/.github/workflows/terraform.yml"
fi

# Task 1: Pipeline definition file
check 1 'CI pipeline file exists' '[[ -n "$ci_file" && -f "$ci_file" ]]' 'Create azure-pipelines.yml or .github/workflows/terraform.yml.'

# Task 2: Validate & plan stages
check 2 'Validation stage declared' '[[ -n "$ci_file" ]] && grep -Eq "terraform[[:space:]]+validate|Validate" "$ci_file"' 'Include a validation step (fmt/validate) in the pipeline.'
check 2 'Plan stage declared' '[[ -n "$ci_file" ]] && grep -Eq "terraform[[:space:]]+plan|Plan" "$ci_file"' 'Include a speculative plan step in the pipeline.'

# Task 3: Apply stage with approval gate
check 3 'Apply stage declared' '[[ -n "$ci_file" ]] && grep -Eq "terraform[[:space:]]+apply|Apply" "$ci_file"' 'Include an apply step conditional on main/approval.'

# Task 4: Security and secrets hygiene in CI
check 4 'Zero hardcoded secrets in CI' '[[ -n "$ci_file" ]] && ! grep -Eq "password:[[:space:]]*[\"0-9a-zA-Z]+|token:[[:space:]]*[\"0-9a-zA-Z]{10,}" "$ci_file"' 'Use pipeline variable groups, GitHub secrets, or OIDC federation.'

# Task 5: Static syntax check of YAML
check 5 'Pipeline file populated' '[[ -n "$ci_file" && $(wc -c < "$ci_file") -gt 50 ]]' 'Ensure the CI pipeline definition contains complete steps.'

printf 'Result: %d/%d\n' "$passed" "$total"
if $report; then
  report_dir="$repo_root/student-track/_reports"; mkdir -p "$report_dir"
  report_path="$report_dir/module-07-${STUDENT_INITIALS:-STUDENT}.md"
  { printf '# Module 07 validation report\n\nScore: %d/%d\n\n| Task | Check | Result |\n|---:|---|---|\n' "$passed" "$total"; printf '%s\n' "${rows[@]}"; } > "$report_path"
  printf 'Report: %s\n' "$report_path"
fi
[[ $passed -eq $total ]]
