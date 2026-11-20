WITH items AS (
    SELECT
        order_id,
        COUNT(*) AS total_items,
        SUM(item_price) AS items_revenue,
        SUM(freight_value) AS freight_value
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id
),

payments AS (
    SELECT
        order_id,
        SUM(payment_value) AS payment_value,
        COUNT(*) AS payment_records
    FROM {{ ref('stg_payments') }}
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    o.order_status,
    o.purchased_at,
    o.approved_at,
    o.shipped_at,
    o.delivered_at,
    o.estimated_delivery_at,

    COALESCE(i.total_items, 0) AS total_items,
    COALESCE(i.items_revenue, 0) AS items_revenue,
    COALESCE(i.freight_value, 0) AS freight_value,
    COALESCE(p.payment_value, 0) AS payment_value,
    COALESCE(p.payment_records, 0) AS payment_records,

    CASE
        WHEN o.delivered_at IS NOT NULL
         AND o.purchased_at IS NOT NULL
        THEN EXTRACT(
            EPOCH FROM (o.delivered_at - o.purchased_at)
        ) / 86400.0
    END AS delivery_days,

    CASE
        WHEN o.delivered_at IS NOT NULL
         AND o.estimated_delivery_at IS NOT NULL
        THEN o.delivered_at > o.estimated_delivery_at
    END AS is_late_delivery

FROM {{ ref('stg_orders') }} o
LEFT JOIN {{ ref('dim_customers') }} c
    ON o.customer_id = c.customer_id
LEFT JOIN items i
    ON o.order_id = i.order_id
LEFT JOIN payments p
    ON o.order_id = p.order_id
