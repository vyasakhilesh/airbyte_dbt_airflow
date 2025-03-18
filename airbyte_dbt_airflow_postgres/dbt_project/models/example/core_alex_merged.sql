-- models/merged_table.sql
{{ config(materialized='table') }}

WITH combined_data AS (
    SELECT
        a.doi AS core_doi, 
        b.doi AS open_alex_doi
    FROM
        {{ ref('normalize_core_data') }} AS a
    FULL OUTER JOIN
        {{ ref('normalize_open_alex_data') }} AS b
    ON
        a.doi = b.doi
)

SELECT * FROM combined_data