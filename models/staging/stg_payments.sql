SELECT
    order_id,
    payment_sequential,
    LOWER(TRIM(payment_type)) AS payment_type,
    payment_installments,
    payment_value::numeric AS payment_value

FROM {{ source('olist', 'olist_order_payments') }}
