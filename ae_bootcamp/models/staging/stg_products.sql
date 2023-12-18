with source as (

    SELECT
        cast(supplier_ids as integer) as supplier_id,
        id,
        product_code,
        product_name,
        description,
        standard_cost,
        list_price,
        reorder_level,
        target_level,
        quantity_per_unit,
        discontinued,
        minimum_reorder_quantity,
        category,
        attachments,    
    FROM {{ source('northwind', 'products') }}
    WHERE supplier_ids NOT LIKE "%;%"
)
select 
    *,
    current_timestamp() as ingestion_timestamp
from source
