{{ config(materialized='table') }}

-- Extract and normalize fields from the JSONB column `_airbyte_data`
WITH parsed_data AS (
    SELECT
        _id,                                  -- Preserve the primary identifier
        _airbyte_data->>'doi' AS doi,         -- Extract the DOI
        _airbyte_data->>'oai' AS oai,         -- Extract the OAI identifier
        (_airbyte_data->>'year')::INTEGER AS year, -- Extract and cast the year
        _airbyte_data->>'title' AS title,     -- Extract the article title
        _airbyte_data->>'abstract' AS abstract, -- Extract the abstract
        _airbyte_data->'authors' AS authors,  -- Keep the authors array as JSONB
        jsonb_array_elements_text(_airbyte_data->'subject') AS subject, -- Expand subjects
        jsonb_array_elements_text(_airbyte_data->'relations') AS relation -- Expand relations
    FROM {{ source('article_db', 'airbyte_raw_Core_Data') }}
),

-- Flatten authors array into individual rows
authors_normalized AS (
    SELECT
        _id,
        jsonb_array_elements_text(authors) AS author_name -- Expand authors into rows
    FROM parsed_data
)

-- Final table combining normalized data
SELECT
    pd._id,
    pd.doi,
    pd.oai,
    pd.year,
    pd.title,
    pd.abstract,
    pd.subject,
    pd.relation,
    an.author_name
FROM parsed_data pd
LEFT JOIN authors_normalized an ON pd._id = an._id