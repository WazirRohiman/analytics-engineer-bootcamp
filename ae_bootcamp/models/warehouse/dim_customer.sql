WITH source as (
    SELECT
        id as customer_id,
        company,
        last_name,
        first_name,
        email_address,
        job_title,
        business_phone,
        home_phone,
        mobile_phone,
        fax_number,
        address,
        city,
        state_province,
        zip_postal_code,
        country_region,
        web_page,
        notes,
        attachments,
        current_timestamp() as insertion_timestamp,
    FROM {{ ref('stg_customer') }}
),

-- the following sql statement will find rows are that duplicated based on the customer_id partition
unique_source as (
    SELECT *,
        row_number() over (partition by customer_id) as row_number
    FROM source
)
-- the table will only filter out row_number is 1
SELECT *
EXCEPT
    (row_number),
FROM unique_source
WHERE row_number = 1
