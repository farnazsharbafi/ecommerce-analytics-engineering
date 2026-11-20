WITH monthly_orders AS (

    SELECT
        DATE_TRUNC('month', purchased_at)::date AS order_month,
        order_id,
        customer_unique_id,
        order_status,
        payment_value,
        items_revenue,
        delivery_days,
        is_late_delivery

    FROM {{ ref('fct_orders') }}

    WHERE purchased_at IS NOT NULL

)

SELECT
    order_month,

    COUNT(*) AS total_orders,

    COUNT(DISTINCT customer_unique_id) AS unique_customers,

    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
    ) AS delivered_orders,

    ROUND(
        SUM(payment_value) FILTER (
            WHERE order_status = 'delivered'
        ), 2
    ) AS total_revenue,

    ROUND(
        SUM(items_revenue) FILTER (
            WHERE order_status = 'delivered'
        ), 2
    ) AS merchandise_revenue,

    ROUND(
        AVG(payment_value) FILTER (
            WHERE order_status = 'delivered'
        ), 2
    ) AS avg_order_value,

    ROUND(
        AVG(delivery_days) FILTER (
            WHERE order_status = 'delivered'
        ), 2
    ) AS avg_delivery_days,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE is_late_delivery = TRUE
        ) / NULLIF(
            COUNT(*) FILTER (
                WHERE is_late_delivery IS NOT NULL
            ), 0
        ), 2
    ) AS late_delivery_rate_pct

FROM monthly_orders

GROUP BY order_month
