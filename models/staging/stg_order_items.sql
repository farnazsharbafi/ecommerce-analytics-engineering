SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    NULLIF(shipping_limit_date, '')::timestamp AS shipping_limit_at,
    price::numeric AS item_price,
    freight_value::numeric AS freight_value
FROM {{ source('olist', 'olist_order_items') }}
