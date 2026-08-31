# FinOps — dbt Snowflake Monitoring

Standalone dbt project for Snowflake cost monitoring and FinOps analytics using `ACCOUNT_USAGE` views.

## Prerequisites

- Python 3.12
- Snowflake account with `ACCOUNTADMIN` or `GOVERNANCE` role (required for `ACCOUNT_USAGE` access)
- A dedicated warehouse for dbt (e.g., `WH_FINOPS_DEV`)

## Setup

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\Activate.ps1  # Windows PowerShell

# Install dependencies
pip install -r requirements.txt

# Copy profiles
cp profiles.yml.example ~/.dbt/profiles.yml
# Edit ~/.dbt/profiles.yml with your credentials

# Install dbt packages
dbt deps

# Run models
dbt build

# Inspect results
dbt show --select mart_warehouse_credits_daily --limit 10
```

## ACCOUNT_USAGE Latency

Snowflake `ACCOUNT_USAGE` views have a latency of **1-2 hours** (some up to 3 hours). This means:
- Models reflect data up to 2 hours ago.
- Freshness tests account for this latency.
- For real-time monitoring, use `SNOWFLAKE.LOCAL_USAGE` views (requires Enterprise edition).

## Required Snowflake Privileges

The dbt user needs:
- `USAGE` on the `SNOWFLAKE` database
- `USAGE` on the `ACCOUNT_USAGE` schema
- `SELECT` on all `ACCOUNT_USAGE` views
- `CREATE DATABASE` and `CREATE SCHEMA` for the FinOps output database/schema

## Models

### Staging (views in `staging` schema)

| Model | Source | Description |
|-------|--------|-------------|
| `stg_warehouse_metering` | `WAREHOUSE_METERING_HISTORY` | Credit usage by warehouse |
| `stg_query_history` | `QUERY_HISTORY` | Query execution details |
| `stg_storage_usage` | `STORAGE_USAGE` | Storage by database |
| `stg_resource_monitors` | `RESOURCE_MONITORS` | Monitor configs and usage |

### Marts (tables in `marts` schema)

| Model | Description | Tags |
|-------|-------------|------|
| `mart_warehouse_credits_daily` | Daily credits with 7-day avg and cumulative | finops |
| `mart_resource_monitor_risk` | Monitor risk status (OK/NOTIFY/WARNING/CRITICAL) | finops |
| `mart_inactive_warehouses` | Warehouse activity status (30-day window) | finops |
| `mart_expensive_queries` | Flagged queries (long-running, high-credit, high-scan) | finops |
| `mart_storage_trends` | 30-day storage trends with growth percentage | finops |

## Tests

- `not_null` on all key columns
- `unique` on query_id, warehouse_name, resource_monitor_name
- `accepted_values` for risk_status, activity_status, risk_flag
- `dbt_utils.accepted_range` for usage_percent (0-200)

## Exposures

- **finops_dashboard**: Main dashboard consuming all mart models
- **warehouse_credits_report**: Weekly credit report
- **resource_monitor_alerts**: Automated alerting on monitor thresholds

## Packages

| Package | Version | Purpose |
|---------|---------|---------|
| `getsnowflake/snowflake` | 4.6.0 | Snowflake monitoring macros and models |
| `dbt-labs/dbt_utils` | 1.3.3 | General-purpose macros (accepted_range, etc.) |
