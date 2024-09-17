{{
  config(
    materialized = "table"
  )
}}

WITH payment_data AS (
    SELECT
        payment_type,
        SUM(total_amount) AS total_revenue,
        COUNT(*) AS total_trips,
        AVG(total_amount) AS avg_fare
    FROM {{ ref('nyc_taxi_tb') }}
    GROUP BY payment_type
)

SELECT
    payment_type,
    total_revenue,
    total_trips,
    avg_fare
FROM payment_data
ORDER BY total_revenue DESC