{{ config(materialized='table') }}

with wh_usage as (
    select
        warehouse_name,
        max(usage_date) as last_used_date,
        sum(credits_total) as total_credits_30d,
        count(distinct usage_date) as active_days_30d
    from {{ ref('stg_warehouse_metering') }}
    where usage_date >= dateadd('day', -30, current_date())
    group by 1
),

wh_definitions as (
    select name as warehouse_name
    from {{ source('snowflake_account_usage', 'WAREHOUSES') }}
)

select
    wh_definitions.warehouse_name,
    coalesce(wh_usage.last_used_date, '1970-01-01'::date) as last_used_date,
    coalesce(wh_usage.total_credits_30d, 0) as total_credits_30d,
    coalesce(wh_usage.active_days_30d, 0) as active_days_30d,
    case
        when wh_usage.last_used_date is null then 'NEVER_USED'
        when datediff('day', wh_usage.last_used_date, current_date()) > 7 then 'INACTIVE_7D'
        when datediff('day', wh_usage.last_used_date, current_date()) > 1 then 'INACTIVE_1D'
        else 'ACTIVE'
    end as activity_status
from wh_definitions
left join wh_usage on wh_definitions.warehouse_name = wh_usage.warehouse_name
order by active_days_30d asc
