{{ config(materialized='view') }}

with storage as (
    select
        usage_date,
        database_name,
        bytes_used,
        bytes_deleted
    from {{ source('snowflake_account_usage', 'STORAGE_USAGE') }}
    where usage_date >= '{{ var("start_date") }}'
)

select
    usage_date,
    database_name,
    bytes_used,
    bytes_deleted,
    bytes_used / power(1024, 3) as storage_gb
from storage
