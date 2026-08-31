{{ config(materialized='view') }}

with monitors as (
    select
        name,
        credit_quota,
        used_credits,
        remaining_credits,
        level,
        frequency,
        notify_at,
        suspend_at,
        suspend_immediately_at
    from {{ source('snowflake_account_usage', 'RESOURCE_MONITORS') }}
)

select
    name,
    credit_quota,
    used_credits,
    remaining_credits,
    level,
    frequency,
    notify_at,
    suspend_at,
    suspend_immediately_at,
    case
        when credit_quota > 0 then round((used_credits / credit_quota) * 100, 2)
        else 0
    end as usage_percent,
    case
        when credit_quota > 0 and used_credits / credit_quota >= 1.0 then 'CRITICAL'
        when credit_quota > 0 and used_credits / credit_quota >= 0.9 then 'WARNING'
        when credit_quota > 0 and used_credits / credit_quota >= 0.75 then 'NOTIFY'
        else 'OK'
    end as risk_status
from monitors
