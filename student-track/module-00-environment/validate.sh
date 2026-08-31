#!/usr/bin/env bash
set -u

report=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --report) report=true ;;
    --all) ;;
    --task) shift ;;
  esac
  shift
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
workspace="${STUDENT_WORKSPACE:-$PWD}"
connection="${SNOWFLAKE_TERRAFORM_CONNECTION:-terraform_svc}"
passed=0
total=0
results=()

check() {
  local name="$1" condition="$2" hint="$3"
  total=$((total + 1))
  if eval "$condition"; then
    passed=$((passed + 1))
    results+=("| $name | PASS |")
    printf '[PASS] %s\n' "$name"
  else
    results+=("| $name | FAIL |")
    printf '[FAIL] %s\n       %s\n' "$name" "$hint"
  fi
}

check 'Workspace metadata' 'test -f "$workspace/.student-workspace.json"' 'Run new-student-workspace.sh again.'
check 'Git' 'command -v git >/dev/null 2>&1' 'Install Git and open a new terminal.'
check 'Terraform' 'command -v terraform >/dev/null 2>&1' 'Install Terraform using the official method for your OS.'
check 'Snowflake CLI' 'command -v snow >/dev/null 2>&1' 'Install Snowflake CLI in a user or virtual environment.'
check '.env local' 'test -f "$repo_root/.env"' 'Copy .env.example to .env and replace non-secret placeholders.'
check '.env ignored' 'git -C "$repo_root" check-ignore .env >/dev/null 2>&1' 'Add .env to .gitignore.'
check 'Secrets ignored' 'git -C "$repo_root" check-ignore secrets/probe.token >/dev/null 2>&1' 'Add secrets/ to .gitignore.'
if [[ -f "$repo_root/.env" ]]; then
  check 'No unresolved identifiers' '! grep -Eq "<[^>]+>" "$repo_root/.env"' 'Replace every <placeholder> in .env.'
fi
check 'Snowflake connection' 'command -v snow >/dev/null 2>&1 && snow connection test -c "$connection" >/dev/null 2>&1' "Check connection '$connection' without sharing its secret."

printf 'Result: %d/%d\n' "$passed" "$total"
if $report; then
  report_dir="$repo_root/student-track/_reports"
  mkdir -p "$report_dir"
  report_path="$report_dir/module-00-${STUDENT_INITIALS:-STUDENT}.md"
  {
    printf '# Module 00 validation report\n\nScore: %d/%d\n\n| Check | Result |\n|---|---|\n' "$passed" "$total"
    printf '%s\n' "${results[@]}"
  } > "$report_path"
  printf 'Report: %s\n' "$report_path"
fi
[[ $passed -eq $total ]] || exit 1
printf 'Ready for Day 1\n'
