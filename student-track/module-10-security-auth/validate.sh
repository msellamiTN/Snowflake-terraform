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

# Task 1: Service user resource
check 1 'Service user resource declared' 'contains main.tf "resource[[:space:]]+\"snowflake_user\"" || contains main.tf "resource[[:space:]]+\"snowflake_service_user\""' 'Declare a snowflake_user for the service principal.'

# Task 2: Public key attribute configured on user
check 2 'RSA public key configured' 'contains main.tf "rsa_public_key[[:space:]]*=" || contains main.tf "rsa_public_key_2[[:space:]]*="' 'Set rsa_public_key on the Snowflake user.'

# Task 3: Zero private key committed in Git
check 3 'Zero private keys in HCL' '! contains main.tf "BEGIN (RSA )?PRIVATE KEY" && ! contains provider.tf "BEGIN (RSA )?PRIVATE KEY"' 'Never put raw RSA private keys in .tf files; load from Azure Key Vault or file.'

# Task 4: Static validation
if run_for 4; then
  check 4 'Terraform available' 'command -v terraform >/dev/null 2>&1' 'Install Terraform.'
  if command -v terraform >/dev/null 2>&1 && [[ -f "$workspace/versions.tf" ]]; then
    (cd "$workspace" && terraform fmt -check >/dev/null 2>&1); check 4 'terraform fmt' '[[ $? -eq 0 ]]' 'Run terraform fmt.'
    (cd "$workspace" && terraform validate >/dev/null 2>&1); check 4 'terraform validate' '[[ $? -eq 0 ]]' 'Run terraform validate to check security definitions.'
  fi
fi

# Task 5: Plan output
check 5 'Plan evidence' 'test -f "$workspace/m10.tfplan.json"' 'Generate plan and save m10.tfplan.json.'

printf 'Result: %d/%d\n' "$passed" "$total"
if $report; then
  report_dir="$repo_root/student-track/_reports"; mkdir -p "$report_dir"
  report_path="$report_dir/module-10-${STUDENT_INITIALS:-STUDENT}.md"
  { printf '# Module 10 validation report\n\nScore: %d/%d\n\n| Task | Check | Result |\n|---:|---|---|\n' "$passed" "$total"; printf '%s\n' "${rows[@]}"; } > "$report_path"
  printf 'Report: %s\n' "$report_path"
fi
[[ $passed -eq $total ]]
