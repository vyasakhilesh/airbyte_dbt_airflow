{{ config(materialized='table') }}

SELECT id
FROM {{ source('public', 'sample_table') }}
LIMIT 10