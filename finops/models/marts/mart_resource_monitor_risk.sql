{{ config(materialized='table') }}

with monitor_status as (
    select
        name as resource_monitor_name,
        credit_quota,
        used_credits,
        remaining_credits,
        usage_percent,
        risk_status,
        frequency
    from {{ ref('stg_resource_monitors') }}
)

select
    resource_monitor_name,
    credit_quota,
    used_credits,
    remaining_credits,
    usage_percent,
    risk_status,
    frequency,
    case
        when risk_status = 'CRITICAL' then 'Suspend threshold reached — warehouses may be suspended'
        when risk_status = 'WARNING' then '90% quota consumed — review usage immediately'
        when risk_status = 'NOTIFY' then '75% quota consumed — notification sent'
        else 'Within budget'
    end as action_required
from monitor_status
order by usage_percent desc
