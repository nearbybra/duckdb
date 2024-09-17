{{
  config(
    materialized = "table"
  )
}}

WITH raw_data AS (
  SELECT * FROM read_csv_auto('data/nyc_taxi_data_massive.csv')
)

SELECT
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  passenger_count,
  trip_distance,
  fare_amount,
  total_amount,
  payment_type
FROM raw_data