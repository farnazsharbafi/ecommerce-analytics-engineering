SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    o.purchased_at,
    o.order_status,

    oi.item_price,
    oi.freight_value,
    oi.item_price + oi.freight_value AS total_item_value

FROM {{ ref('stg_order_items') }} oi

INNER JOIN {{ ref('stg_orders') }} o
    ON oi.order_id = o.order_id
