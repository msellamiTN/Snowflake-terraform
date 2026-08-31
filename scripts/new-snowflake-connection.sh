#!/usr/bin/env bash
#
# Creates a Snowflake CLI connection using a PAT entered securely.
#
# The PAT is entered via a masked prompt, never displayed, never logged, and
# never passed as a command-line argument. It is exported to the
# SNOWFLAKE_PAT environment variable only for the duration of the snow
# commands, then unset.
#
# Usage:
#   ./scripts/new-snowflake-connection.sh
#   ./scripts/new-snowflake-connection.sh -n training -o MYORG -a MYACCOUNT -u DATA2AI -r SYSADMIN

set -uo pipefail

connection_name='training'
organization=''
account=''
user=''
role='SYSADMIN'
host=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--connection-name) connection_name="$2"; shift 2 ;;
    -o|--organization)    organization="$2"; shift 2 ;;
    -a|--account)         account="$2"; shift 2 ;;
    -u|--user)            user="$2"; shift 2 ;;
    -r|--role)            role="$2"; shift 2 ;;
    -h|--host)            host="$2"; shift 2 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
done

read_required() {
  local prompt="$1" value
  while true; do
    printf '%s: ' "$prompt"
    read -r value
    if [[ -n "$value" ]]; then printf '%s' "$value"; return 0; fi
    printf '  A value is required.\n' >&2
  done
}

read_masked() {
  local prompt="$1" value
  printf '%s ' "$prompt"
  read -rs value
  printf '\n'
  printf '%s' "$value"
}

printf '\n============================================================\n'
printf ' Snowflake CLI connection setup\n'
printf '============================================================\n'
printf '\nThe PAT is entered securely and never displayed or logged.\n\n'

[[ -z "$organization" ]] && organization="$(read_required 'Snowflake organization name')"
[[ -z "$account" ]]      && account="$(read_required 'Snowflake account name')"
[[ -z "$user" ]]         && user="$(read_required 'Snowflake user name')"

token="$(read_masked 'Snowflake PAT (token):')"

if [[ -z "$token" ]]; then
  printf '[ERROR] No token entered. Aborting.\n'
  exit 1
fi

# ------------------------------------------------------------------
# Build the snow connection add command
# ------------------------------------------------------------------

snow_args=(connection add -n "$connection_name" -a "$account" -o "$organization" -u "$user" -r "$role" --no-interactive)

if [[ -n "$host" ]]; then
  snow_args+=(-h "$host")
fi

# Export the token only for the snow subprocess.
export SNOWFLAKE_PAT="$token"

printf '\nCreating the connection...\n'

if snow "${snow_args[@]}" 2>&1; then
  printf "[OK] Connection '%s' created.\n" "$connection_name"
else
  printf "[ERROR] snow connection add failed with exit code %d\n" "$?"
  unset SNOWFLAKE_PAT
  exit 1
fi

# ------------------------------------------------------------------
# Test the connection
# ------------------------------------------------------------------

printf '\nTesting the connection...\n'

if snow sql -q 'SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT()' -c "$connection_name" --format=json 2>&1; then
  printf '[OK] Connection test succeeded.\n'
else
  printf '[WARN] Connection created but test query failed.\n'
  printf "       Check with: snow connection test -c %s\n" "$connection_name"
fi

# Clear the token from the environment.
unset SNOWFLAKE_PAT

printf '\nDone.\n'
printf '\nNext steps:\n'
printf "  - Use the connection:  snow sql -q 'SELECT 1' -c %s\n" "$connection_name"
printf '  - Do not store the PAT in any file.\n'
printf '  - Rotate the PAT when the training module is complete.\n'
