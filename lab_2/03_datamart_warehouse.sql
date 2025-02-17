/*
DATA WAREHOUSE VS DATA MART CONCEPTS:

1. Data Warehouse:
   - Enterprise-wide data repository
   - Contains detailed historical data
   - Serves multiple business functions
   - Usually contains raw and transformed data
   - Larger in scope and size

2. Data Mart:
   - Subset of data warehouse
   - Department or function specific
   - More focused and smaller in scope
   - Usually contains aggregated/summarized data
   - Optimized for specific business needs
*/


# Step 1) Storing raw data in an AWS S3 bucket

-- Assume we are using AWS Glue or AWS Athena for querying raw S3 data
CREATE EXTERNAL TABLE raw_events (
    event_id STRING,
    event_timestamp STRING,
    user_id STRING,
    event_type STRING,
    session_id STRING,
    properties STRING
)
STORED AS PARQUET
LOCATION 's3://my-data-lake/raw/events/'
TBLPROPERTIES ("parquet.compression"="SNAPPY");


# Step 2) Data Warehouse (Processing & Structuring the Data)

CREATE TABLE dw_events (
    event_id BIGINT PRIMARY KEY,
    event_timestamp TIMESTAMP NOT NULL,
    user_id VARCHAR(50),
    session_id VARCHAR(100),
    event_type VARCHAR(50),
    properties JSON,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



INSERT INTO dw_events (event_id, event_timestamp, user_id, session_id, event_type, properties)
SELECT 
    CAST(event_id AS BIGINT),
    CAST(event_timestamp AS TIMESTAMP),
    user_id,
    session_id,
    event_type,
    CAST(properties AS JSON)
FROM raw_events;


# Step 3) Data Mart (Optimized for Business Intelligence)

CREATE TABLE dm_session_metrics (
    session_id VARCHAR(100) PRIMARY KEY,
    user_id VARCHAR(50),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    duration_seconds INT,
    event_count INT,
    unique_event_types INT
);


INSERT INTO dm_session_metrics (session_id, user_id, start_time, end_time, duration_seconds, event_count, unique_event_types)
SELECT 
    session_id,
    user_id,
    MIN(event_timestamp) AS start_time,
    MAX(event_timestamp) AS end_time,
    TIMESTAMPDIFF(SECOND, MIN(event_timestamp), MAX(event_timestamp)) AS duration_seconds,
    COUNT(*) AS event_count,
    COUNT(DISTINCT event_type) AS unique_event_types
FROM dw_events
GROUP BY session_id, user_id;

