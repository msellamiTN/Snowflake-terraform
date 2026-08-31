{{ config(materialized='table') }}

with expensive as (
    select
        query_id,
        query_type,
        user_name,
        warehouse_name,
        warehouse_size,
        start_time,
        duration_seconds,
        bytes_scanned,
        rows_produced,
        credits_used_cloud_services,
        case
            when bytes_scanned > 0 and rows_produced > 0
            then bytes_scanned / rows_produced
            else null
        end as bytes_per_row,
        case
            when duration_seconds > 600 then 'LONG_RUNNING'
            when credits_used_cloud_services > 1.0 then 'HIGH_CREDITS'
            when bytes_scanned > power(1024, 4) then 'HIGH_SCAN'
            else 'OK'
        end as risk_flag
    from {{ ref('stg_query_history') }}
    where start_time >= dateadd('day', -7, current_date())
)

select
    query_id,
    query_type,
    user_name,
    warehouse_name,
    warehouse_size,
    start_time,
    duration_seconds,
    bytes_scanned,
    bytes_scanned / power(1024, 3) as scanned_gb,
    rows_produced,
    credits_used_cloud_services,
    bytes_per_row,
    risk_flag
from expensive
where risk_flag != 'OK'
order by credits_used_cloud_services desc
