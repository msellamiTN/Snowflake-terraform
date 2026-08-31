{{ config(materialized='view') }}

with metering as (
    select
        warehouse_id,
        warehouse_name,
        start_time,
        end_time,
        credits_used,
        credits_used_cloud_services,
        credits_used_compute
    from {{ source('snowflake_account_usage', 'WAREHOUSE_METERING_HISTORY') }}
    where start_time >= '{{ var("start_date") }}'
)

select
    warehouse_id,
    warehouse_name,
    date(start_time) as usage_date,
    start_time,
    end_time,
    credits_used,
    credits_used_cloud_services,
    credits_used_compute,
    credits_used_cloud_services + credits_used_compute as credits_total
from metering
