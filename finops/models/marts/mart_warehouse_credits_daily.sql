{{ config(materialized='table') }}

with daily as (
    select
        warehouse_name,
        date_trunc('day', usage_date) as day,
        sum(credits_total) as credits_used,
        sum(credits_used_compute) as credits_compute,
        sum(credits_used_cloud_services) as credits_cloud_services
    from {{ ref('stg_warehouse_metering') }}
    group by 1, 2
)

select
    warehouse_name,
    day,
    credits_used,
    credits_compute,
    credits_cloud_services,
    avg(credits_used) over (
        partition by warehouse_name
        order by day
        rows between 6 preceding and current row
    ) as credits_7day_avg,
    sum(credits_used) over (
        partition by warehouse_name
        order by day
    ) as credits_cumulative
from daily
order by warehouse_name, day
