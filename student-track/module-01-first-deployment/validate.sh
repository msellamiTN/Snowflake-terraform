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

check 1 'versions.tf exists' 'test -f "$workspace/versions.tf"' 'Create versions.tf.'
check 1 'Snowflake provider pinned' 'contains versions.tf "snowflakedb/snowflake" && contains versions.tf "~>[[:space:]]*2\\.14\\.0"' 'Pin ~> 2.14.0.'
check 1 'provider uses profile' 'contains provider.tf "profile[[:space:]]*=[[:space:]]*var\\.snowflake_profile"' 'Use the Snowflake CLI profile.'
check 1 'No provider credential' '! contains provider.tf "password[[:space:]]*=|token[[:space:]]*=|private_key[[:space:]]*="' 'Remove credentials from provider.tf.'
check 2 'Required variables' 'contains variables.tf "variable[[:space:]]+\"snowflake_profile\"" && contains variables.tf "variable[[:space:]]+\"learner_prefix\"" && contains variables.tf "variable[[:space:]]+\"environment\"" && contains variables.tf "variable[[:space:]]+\"warehouse_size\""' 'Create the four variables.'
check 2 'Unique naming locals' 'contains locals.tf "var\\.learner_prefix" && contains locals.tf "database_name" && contains locals.tf "warehouse_name"' 'Build names from learner_prefix.'
check 2 'Local tfvars ignored' 'git -C "$workspace" check-ignore terraform.tfvars >/dev/null 2>&1' 'Ignore terraform.tfvars.'
check 3 'Database resource' 'contains main.tf "resource[[:space:]]+\"snowflake_database\"[[:space:]]+\"raw\""' 'Create snowflake_database.raw.'
check 3 'Schema resource' 'contains main.tf "resource[[:space:]]+\"snowflake_schema\"[[:space:]]+\"ingestion\""' 'Create snowflake_schema.ingestion.'
check 3 'Implicit dependency' 'contains main.tf "database[[:space:]]*=[[:space:]]*snowflake_database\\.raw\\.name"' 'Reference the database from the schema.'
check 3 'Cost-controlled warehouse' 'contains main.tf "snowflake_warehouse" && contains main.tf "auto_suspend[[:space:]]*=[[:space:]]*60" && contains main.tf "initially_suspended[[:space:]]*=[[:space:]]*true"' 'Configure suspension controls.'
check 3 'Outputs' 'contains outputs.tf "output[[:space:]]+\"database_name\"" && contains outputs.tf "output[[:space:]]+\"schema_name\"" && contains outputs.tf "output[[:space:]]+\"warehouse_name\""' 'Create three outputs.'
if run_for 4; then
  check 4 'Terraform available' 'command -v terraform >/dev/null 2>&1' 'Install Terraform.'
  if command -v terraform >/dev/null 2>&1 && [[ -f "$workspace/versions.tf" ]]; then
    (cd "$workspace" && terraform fmt -check >/dev/null 2>&1); check 4 'terraform fmt' '[[ $? -eq 0 ]]' 'Run terraform fmt.'
    (cd "$workspace" && terraform init -backend=false -input=false >/dev/null 2>&1); init_exit=$?; check 4 'terraform init' '[[ $init_exit -eq 0 ]]' 'Check provider access.'
    if [[ $init_exit -eq 0 ]]; then (cd "$workspace" && terraform validate >/dev/null 2>&1); validate_exit=$?; check 4 'terraform validate' '[[ $validate_exit -eq 0 ]]' 'Read terraform validate output.'; fi
  fi
fi
check 5 'Plan evidence' 'test -f "$workspace/m01.tfplan.json"' 'Export terraform show -json to m01.tfplan.json.'

printf 'Result: %d/%d\n' "$passed" "$total"
if $report; then
  report_dir="$repo_root/student-track/_reports"; mkdir -p "$report_dir"
  report_path="$report_dir/module-01-${STUDENT_INITIALS:-STUDENT}.md"
  { printf '# Module 01 validation report\n\nScore: %d/%d\n\n| Task | Check | Result |\n|---:|---|---|\n' "$passed" "$total"; printf '%s\n' "${rows[@]}"; } > "$report_path"
  printf 'Report: %s\n' "$report_path"
fi
[[ $passed -eq $total ]]
