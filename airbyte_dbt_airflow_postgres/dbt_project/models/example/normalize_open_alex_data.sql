{{ config(materialized='table') }}

-- Extract and normalize fields from the JSONB column
WITH parsed_data AS (
    SELECT
        data->>'id' AS id,                                   -- Retain the base 'id' column
        data->>'doi' AS doi,                 -- Extract 'doi' from the JSONB column
        data->>'type' AS article_type,       -- Extract 'type'
        data->>'title' AS title,             -- Extract 'title'
        (data->'biblio'->>'issue')::TEXT AS issue,   -- Extract nested 'issue'
        (data->'biblio'->>'volume')::TEXT AS volume, -- Extract nested 'volume'
        (data->'biblio'->>'first_page') AS first_page, -- Extract nested 'first_page'
        (data->'biblio'->>'last_page') AS last_page, -- Extract nested 'last_page'
        data->>'language' AS language,       -- Extract 'language'
        data->>'updated' AS updated_at,      -- Extract 'updated'
        data->>'publication_date' AS publication_date, -- Extract 'publication_date'
        jsonb_array_elements(data->'topics') AS topics -- Expand JSONB arrays for topics
    FROM {{ source('public', 'open_alex') }}
),

-- Flatten topics array into individual rows
topics_normalized AS (
    SELECT
        id,                                   -- Retain the base 'id' column
        topics->>'id' AS topic_id,           -- Extract 'id' from the JSONB array
        topics->>'display_name' AS topic_name, -- Extract 'display_name'
        topics->'field'->>'display_name' AS topic_field, -- Extract nested field
        topics->>'score' AS topic_score      -- Extract 'score'
    FROM parsed_data
)

-- Final select combining normalized data
SELECT
    pd.id,
    pd.doi,
    pd.article_type,
    pd.title,
    pd.issue,
    pd.volume,
    pd.first_page,
    pd.last_page,
    pd.language,
    pd.updated_at,
    pd.publication_date,
    tn.topic_id,
    tn.topic_name,
    tn.topic_field,
    tn.topic_score
FROM parsed_data pd
LEFT JOIN topics_normalized tn ON pd.id = tn.id