{{ config(materialized='view') }}

with queries as (
    select
        query_id,
        query_text,
        query_type,
        user_name,
        warehouse_name,
        warehouse_size,
        start_time,
        end_time,
        total_elapsed_time,
        bytes_scanned,
        rows_produced,
        credits_used_cloud_services,
        compilation_time,
        execution_time
    from {{ source('snowflake_account_usage', 'QUERY_HISTORY') }}
    where start_time >= '{{ var("start_date") }}'
)

select
    query_id,
    query_text,
    query_type,
    user_name,
    warehouse_name,
    warehouse_size,
    start_time,
    end_time,
    total_elapsed_time,
    bytes_scanned,
    rows_produced,
    credits_used_cloud_services,
    compilation_time,
    execution_time,
    datediff('second', start_time, end_time) as duration_seconds
from queries
