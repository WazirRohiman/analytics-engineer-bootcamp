--the following statement is to partition the table
-- discuss the field that will be filtering frequently with the business to know what to partition on
{{  config(
    partition_by={
        "field": "creation_date",
        "data_type": "date"
    }
)    
}}

WITH source AS (
    SELECT
        c.id as customer_id,
        e.id as employee_id,
        pod.purchase_order_id,
        pod.product_id,
        pod.quantity,
        pod.unit_cost,
        pod.date_received,
        pod.posted_to_inventory,
        pod.inventory_id,
        po.supplier_id,
        po.created_by,
        po.submitted_date,
        date(po.creation_date) as creation_date,
        po.status_id,
        po.expected_date,
        po.shipping_fee,
        po.taxes,
        po.payment_date,
        po.payment_amount,
        po.payment_method,
        po.notes,
        po.approved_by,
        po.approved_date,
        po.submitted_by,
        current_timestamp() as insertion_timestamp,
    FROM {{ ref('stg_purchase_orders') }} po 
    LEFT JOIN {{ ref('stg_purchase_order_details') }} pod 
    ON pod.purchase_order_id = po.id
    LEFT JOIN {{ ref('stg_products') }} p 
    ON p.id = pod.product_id
    LEFT JOIN {{ ref('stg_order_details') }} od
    ON od.product_id = p.id
    LEFT JOIN {{ ref('stg_orders') }} o
    ON o.id = od.order_id
    LEFT JOIN {{ ref('stg_employees') }} e
    ON e.id = po.created_by
    LEFT JOIN {{ ref('stg_customer') }} c
    ON c.id = o.customer_id
    WHERE o.customer_id IS NOT NULL
),

unique_source as (
    select *,
        row_number() over(partition by customer_id, employee_id, product_id, purchase_order_id, inventory_id, supplier_id, creation_date) as row_number
    from source
)

select *
EXCEPT
        (row_number),
from unique_source
where row_number = 1