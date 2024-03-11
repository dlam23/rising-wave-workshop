CREATE MATERIALIZED VIEW trip_stats AS
SELECT taxi_zone.Zone as pickup_zone,
taxi_zone_1.Zone as dropoff_zone,
AVG(tpep_dropoff_datetime-tpep_pickup_datetime) AS avg_trip_time, 
MAX(tpep_dropoff_datetime-tpep_pickup_datetime) AS max_trip_time,
MIN(tpep_dropoff_datetime-tpep_pickup_datetime) AS min_trip_time 
FROM trip_data
JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
JOIN taxi_zone as taxi_zone_1 ON trip_data.DOLocationID = taxi_zone_1.location_id
GROUP BY 1, 2;

WITH highest_avg_trip_time AS (
    SELECT MAX(avg_trip_time) AS max_avg_trip_time
    FROM trip_stats
)
SELECT pickup_zone,
dropoff_zone
FROM trip_stats
WHERE avg_trip_time = (SELECT * FROM highest_avg_trip_time)

CREATE MATERIALIZED VIEW trip_stats_2 AS
SELECT taxi_zone.Zone as pickup_zone,
taxi_zone_1.Zone as dropoff_zone,
COUNT(*) as trip_count,
AVG(tpep_dropoff_datetime-tpep_pickup_datetime) AS avg_trip_time, 
MAX(tpep_dropoff_datetime-tpep_pickup_datetime) AS max_trip_time,
MIN(tpep_dropoff_datetime-tpep_pickup_datetime) AS min_trip_time 
FROM trip_data
JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
JOIN taxi_zone as taxi_zone_1 ON trip_data.DOLocationID = taxi_zone_1.location_id
GROUP BY 1, 2;

WITH highest_avg_trip_time AS (
    SELECT MAX(avg_trip_time) AS max_avg_trip_time
    FROM trip_stats
)
SELECT pickup_zone,
dropoff_zone,
trip_count
FROM trip_stats_2
WHERE avg_trip_time = (SELECT * FROM highest_avg_trip_time);

CREATE MATERIALIZED VIEW latest_pickup_time AS
    SELECT
        max(tpep_pickup_datetime) AS latest_pickup_time
    FROM
        trip_data;

SELECT taxi_zone.Zone,
COUNT(*) AS trips
FROM trip_data
JOIN latest_pickup_time
ON trip_data.tpep_pickup_datetime > latest_pickup_time.latest_pickup_time - interval '17 hours'
JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
GROUP BY 1
ORDER BY trips DESC;
