/* 
Building a OLAP for a Game Company

Scenario:
A game company collects data from multiple departments:
   •  Product: Tracks game performance, in-game events, and player behavior.
   •  Marketing: Tracks ad campaigns, user acquisition, and engagement.
   •  Sales: Tracks game purchases, in-game transactions, and revenue.

The goal is to process data through a Data Lake → Data Warehouse → Data Mart pipeline for game analytics, marketing performance, and financial reporting.
*/


/* 
1) Data Lake (Raw Data Storage)

The data lake stores raw logs from various sources, such as game servers, ad platforms, and e-commerce systems.

- Data Sources:
   •  Product: Game event logs (JSON format)
   •  Marketing: Ad impressions and click data (CSV)
   •  Sales: Purchase transactions (Parquet format)
*/
-- Game Events (Product Data)
CREATE EXTERNAL TABLE raw_game_events (
    event_id STRING,
    event_timestamp STRING,
    player_id STRING,
    game_id STRING,
    event_type STRING,
    metadata STRING  -- JSON-encoded additional data
)
STORED AS JSON
LOCATION 's3://game-data-lake/raw/product/game_events/';

-- Ad Campaigns (Marketing Data)
CREATE EXTERNAL TABLE raw_ad_campaigns (
    ad_id STRING,
    campaign_id STRING,
    impression_time STRING,
    click_time STRING,
    user_id STRING,
    platform STRING
)
STORED AS CSV
LOCATION 's3://game-data-lake/raw/marketing/ad_campaigns/';

-- Transactions (Sales Data)
CREATE EXTERNAL TABLE raw_transactions (
    transaction_id STRING,
    user_id STRING,
    game_id STRING,
    purchase_time STRING,
    amount DECIMAL(10,2),
    currency STRING,
    payment_method STRING
)
STORED AS PARQUET
LOCATION 's3://game-data-lake/raw/sales/transactions/';



/* 
2) Data Warehouse (Structured Data for Analytics)

Once raw data is stored, it is cleaned, 
structured, and optimized for analytics.
*/
CREATE TABLE dw_game_events (
    event_id BIGINT PRIMARY KEY,
    event_timestamp TIMESTAMP,
    player_id VARCHAR(50),
    game_id VARCHAR(50),
    event_type VARCHAR(100),
    metadata JSONB,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE dw_ad_campaigns (
    ad_id VARCHAR(100) PRIMARY KEY,
    campaign_id VARCHAR(100),
    impression_time TIMESTAMP,
    click_time TIMESTAMP NULL,
    user_id VARCHAR(50),
    platform VARCHAR(50)
);


CREATE TABLE dw_transactions (
    transaction_id VARCHAR(100) PRIMARY KEY,
    user_id VARCHAR(50),
    game_id VARCHAR(50),
    purchase_time TIMESTAMP,
    amount DECIMAL(10,2),
    currency VARCHAR(10),
    payment_method VARCHAR(50)
);


# ingest from data lake
INSERT INTO dw_game_events (event_id, event_timestamp, player_id, game_id, event_type, metadata)
SELECT 
    CAST(event_id AS BIGINT),
    CAST(event_timestamp AS TIMESTAMP),
    player_id,
    game_id,
    event_type,
    CAST(metadata AS JSONB)
FROM raw_game_events;


INSERT INTO dw_ad_campaigns (ad_id, campaign_id, impression_time, click_time, user_id, platform)
SELECT 
    ad_id, campaign_id, 
    CAST(impression_time AS TIMESTAMP), 
    CAST(click_time AS TIMESTAMP),
    user_id, platform
FROM raw_ad_campaigns;


INSERT INTO dw_transactions (transaction_id, user_id, game_id, purchase_time, amount, currency, payment_method)
SELECT 
    transaction_id, user_id, game_id, 
    CAST(purchase_time AS TIMESTAMP), 
    amount, currency, payment_method
FROM raw_transactions;


/* 
3) Data Mart (Optimized for Specific Business Units)

Data marts are optimized for queries from Product, 
Marketing, and Sales teams.
*/

CREATE TABLE dm_player_sessions (
    player_id VARCHAR(50),
    game_id VARCHAR(50),
    session_start TIMESTAMP,
    session_end TIMESTAMP,
    session_duration_seconds INT,
    total_events INT,
    unique_event_types INT
);

INSERT INTO dm_player_sessions (player_id, game_id, session_start, session_end, session_duration_seconds, total_events, unique_event_types)
SELECT 
    player_id, game_id,
    MIN(event_timestamp) AS session_start,
    MAX(event_timestamp) AS session_end,
    EXTRACT(EPOCH FROM (MAX(event_timestamp) - MIN(event_timestamp))) AS session_duration_seconds,
    COUNT(*) AS total_events,
    COUNT(DISTINCT event_type) AS unique_event_types
FROM dw_game_events
GROUP BY player_id, game_id;

CREATE TABLE dm_campaign_performance (
    campaign_id VARCHAR(100),
    platform VARCHAR(50),
    impressions INT,
    clicks INT,
    click_through_rate FLOAT
);


INSERT INTO dm_campaign_performance (campaign_id, platform, impressions, clicks, click_through_rate)
SELECT 
    campaign_id, platform,
    COUNT(*) AS impressions,
    COUNT(click_time) AS clicks,
    COUNT(click_time) * 1.0 / COUNT(*) AS click_through_rate
FROM dw_ad_campaigns
GROUP BY campaign_id, platform;

CREATE TABLE dm_revenue_summary (
    game_id VARCHAR(50),
    total_sales DECIMAL(12,2),
    total_transactions INT,
    avg_transaction DECIMAL(10,2)
);

INSERT INTO dm_revenue_summary (game_id, total_sales, total_transactions, avg_transaction)
SELECT 
    game_id,
    SUM(amount) AS total_sales,
    COUNT(transaction_id) AS total_transactions,
    AVG(amount) AS avg_transaction
FROM dw_transactions
GROUP BY game_id;
