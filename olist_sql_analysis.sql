-- Cohort & Retention Analysis

WITH cohort AS (
    SELECT
        customer_id,
        MIN(order_purchase_timestamp::TIMESTAMP) AS first_order_date
    FROM olist_orders_dataset
    GROUP BY customer_id
),

retention AS (
    SELECT
        DATE_TRUNC('month', c.first_order_date::TIMESTAMP)::DATE AS cohort_month,
        DATE_PART('year', AGE(o.order_purchase_timestamp::TIMESTAMP, c.first_order_date)) * 12 +
        DATE_PART('month', AGE(o.order_purchase_timestamp::TIMESTAMP, c.first_order_date)) AS month_num,
        COUNT(DISTINCT c.customer_id) AS customer_num
    FROM cohort c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    GROUP BY cohort_month, month_num
)

SELECT
    cohort_month,
    month_num,
    customer_num,
    ROUND(100.0 * customer_num / FIRST_VALUE(customer_num)
        OVER (PARTITION BY cohort_month ORDER BY month_num), 1) AS retention_rate
FROM retention
ORDER BY cohort_month, month_num


-- Funnel Analysis

WITH funnel_analysis AS (
    SELECT
        order_status,
        order_num,
        CASE order_status
            WHEN 'created'    THEN 1
            WHEN 'approved'   THEN 2
            WHEN 'invoiced'   THEN 3
            WHEN 'processing' THEN 4
            WHEN 'shipped'    THEN 5
            WHEN 'delivered'  THEN 6
        END AS funnel_step
    FROM (
        SELECT
            order_status,
            COUNT(*) AS order_num
        FROM olist_orders_dataset
        GROUP BY order_status
    ) t
),

funnel_with_prev AS (
    SELECT *,
        LAG(order_num) OVER (ORDER BY funnel_step) AS prev_step
    FROM funnel_analysis
)

SELECT *,
    ROUND(100.0 * order_num / prev_step, 1) AS conversion_rate
FROM funnel_with_prev
WHERE funnel_step IS NOT NULL
ORDER BY funnel_step


-- RFM Analysis

WITH rfm_base AS (
    SELECT
        ood.customer_id,
        CURRENT_DATE - MAX(ood.order_purchase_timestamp::TIMESTAMP)::DATE AS recency,
        COUNT(DISTINCT ood.order_id) AS frequency,
        SUM(ooid.price) AS monetary
    FROM olist_orders_dataset ood
    JOIN olist_order_items_dataset ooid ON ooid.order_id = ood.order_id
    GROUP BY ood.customer_id
),

rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency)    AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary)     AS monetary_score
    FROM rfm_base
)

SELECT *,
    CASE
        WHEN recency_score = 5  AND frequency_score = 5  THEN 'Champions'
        WHEN recency_score >= 4 AND frequency_score >= 3 THEN 'Loyal'
        WHEN recency_score = 5  AND frequency_score <= 2 THEN 'New Customer'
        WHEN recency_score <= 2 AND frequency_score >= 4 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost'
        ELSE 'Potential'
    END AS segment
FROM rfm_scores







