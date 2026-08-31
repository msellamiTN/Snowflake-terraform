{{ config(materialized='table') }}

with storage as (
    select
        database_name,
        usage_date,
        storage_gb,
        lag(storage_gb) over (
            partition by database_name
            order by usage_date
        ) as prev_storage_gb
    from {{ ref('stg_storage_usage') }}
    where usage_date >= dateadd('day', -30, current_date())
)

select
    database_name,
    usage_date,
    storage_gb,
    prev_storage_gb,
    storage_gb - prev_storage_gb as storage_delta_gb,
    case
        when prev_storage_gb > 0
        then round(((storage_gb - prev_storage_gb) / prev_storage_gb) * 100, 2)
        else 0
    end as growth_percent
from storage
order by database_name, usage_date
