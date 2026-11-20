SELECT
    order_id,
    customer_id,
    LOWER(TRIM(order_status)) AS order_status,
    NULLIF(order_purchase_timestamp, '')::timestamp AS purchased_at,
    NULLIF(order_approved_at, '')::timestamp AS approved_at,
    NULLIF(order_delivered_carrier_date, '')::timestamp AS shipped_at,
    NULLIF(order_delivered_customer_date, '')::timestamp AS delivered_at,
    NULLIF(order_estimated_delivery_date, '')::timestamp AS estimated_delivery_at

FROM {{ source('olist', 'olist_orders') }}
