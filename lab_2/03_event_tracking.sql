-- Event Tracking Model Tutorial
-- Demonstrates modeling for high-volume event data and time-series analytics

USE analytics_tutorial;

-- 1. Core Event Table with Partitioning
-- Note: Partitioning by date for efficient data management
CREATE TABLE events (
    event_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    event_timestamp TIMESTAMP NOT NULL,
    event_date DATE GENERATED ALWAYS AS (DATE(event_timestamp)) STORED,
    event_type VARCHAR(50) NOT NULL,
    user_id VARCHAR(50),
    session_id VARCHAR(100),
    device_type VARCHAR(50),
    platform VARCHAR(50),
    ip_address VARCHAR(45),
    user_agent TEXT,
    properties JSON,
    COMMENT 'Main event tracking table with JSON properties'
) PARTITION BY RANGE (TO_DAYS(event_date)) (
    PARTITION p_oldest VALUES LESS THAN (TO_DAYS('2024-01-01')),
    PARTITION p_2024_q1 VALUES LESS THAN (TO_DAYS('2024-04-01')),
    PARTITION p_2024_q2 VALUES LESS THAN (TO_DAYS('2024-07-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 2. Session Context Table
-- Stores aggregated session information
CREATE TABLE session_context (
    session_id VARCHAR(100) PRIMARY KEY,
    user_id VARCHAR(50),
    start_timestamp TIMESTAMP NOT NULL,
    end_timestamp TIMESTAMP,
    duration_seconds INT,
    page_views INT DEFAULT 0,
    events_count INT DEFAULT 0,
    entry_page VARCHAR(255),
    exit_page VARCHAR(255),
    is_bounce BOOLEAN,
    device_type VARCHAR(50),
    platform VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(100),
    COMMENT 'Session-level aggregation for user behavior analysis'
);

-- 3. Event Type Definition Table
-- Maintains metadata about different event types
CREATE TABLE event_types (
    event_type VARCHAR(50) PRIMARY KEY,
    category VARCHAR(50),
    description TEXT,
    is_conversion BOOLEAN DEFAULT FALSE,
    properties_schema JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    COMMENT 'Event type definitions and metadata'
);

-- 4. Real-time Metrics Table
-- Stores rolling window aggregations
CREATE TABLE realtime_metrics (
    metric_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    metric_timestamp TIMESTAMP NOT NULL,
    window_minutes INT NOT NULL,
    event_type VARCHAR(50),
    event_count INT,
    unique_users INT,
    unique_sessions INT,
    COMMENT 'Rolling window metrics for real-time analytics'
);

-- Insert sample data into event_types
INSERT INTO event_types (event_type, category, description, is_conversion, properties_schema) VALUES
('page_view', 'engagement', 'User viewed a page', FALSE, 
 '{"required": ["page_url", "referrer"], "properties": {"page_url": "string", "referrer": "string"}}'),
('button_click', 'interaction', 'User clicked a button', FALSE,
 '{"required": ["button_id", "button_text"], "properties": {"button_id": "string", "button_text": "string"}}'),
('form_submit', 'conversion', 'User submitted a form', TRUE,
 '{"required": ["form_id", "form_name"], "properties": {"form_id": "string", "form_name": "string", "fields": "array"}}');

-- Insert sample data into session_context
INSERT INTO session_context (session_id, user_id, start_timestamp, end_timestamp, duration_seconds, page_views, events_count, entry_page, exit_page, is_bounce, device_type, platform, country, city) VALUES
('sess_001', 'user_001', '2024-01-01 12:00:00', '2024-01-01 12:30:00', 1800, 5, 10, '/home', '/checkout', FALSE, 'desktop', 'Windows', 'USA', 'New York'),
('sess_002', 'user_002', '2024-01-02 14:00:00', NULL, NULL, 2, 3, '/home', NULL, TRUE, 'mobile', 'iOS', 'Canada', 'Toronto');

-- Insert sample data into events
INSERT INTO events (event_timestamp, event_type, user_id, session_id, device_type, platform, ip_address, user_agent, properties) VALUES
('2024-01-01 12:05:00', 'page_view', 'user_001', 'sess_001', 'desktop', 'Windows', '192.168.1.1', 'Mozilla/5.0', '{"page_url": "/home", "referrer": "direct"}'),
('2024-01-01 12:10:00', 'button_click', 'user_001', 'sess_001', 'desktop', 'Windows', '192.168.1.1', 'Mozilla/5.0', '{"button_id": "signup", "button_text": "Sign Up"}'),
('2024-01-02 14:05:00', 'page_view', 'user_002', 'sess_002', 'mobile', 'iOS', '192.168.1.2', 'Safari', '{"page_url": "/home", "referrer": "google.com"}');

-- Insert sample data into realtime_metrics
INSERT INTO realtime_metrics (metric_timestamp, window_minutes, event_type, event_count, unique_users, unique_sessions) VALUES
(NOW(), 15, 'page_view', 50, 40, 35),
(NOW(), 15, 'button_click', 20, 18, 16);

-- Insert sample data into event_paths
INSERT INTO event_paths (user_id, session_id, event_sequence, event_count, start_timestamp, end_timestamp) VALUES
('user_001', 'sess_001', 'page_view > button_click > form_submit', 3, '2024-01-01 12:00:00', '2024-01-01 12:30:00');


-- Example Queries for Event Analysis

-- 1. Event Funnel Analysis
WITH funnel_steps AS (
    SELECT 
        user_id,
        event_type,
        event_timestamp,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_timestamp) as step_number
    FROM events
    WHERE event_type IN ('page_view', 'button_click', 'form_submit')
    AND event_date >= CURRENT_DATE - INTERVAL 7 DAY
)
SELECT 
    event_type,
    COUNT(*) as step_count,
    COUNT(*) * 100.0 / FIRST_VALUE(COUNT(*)) OVER (ORDER BY MIN(step_number)) as conversion_rate
FROM funnel_steps
GROUP BY event_type
ORDER BY MIN(step_number);

-- 2. Session Analysis
SELECT 
    HOUR(start_timestamp) as hour_of_day,
    COUNT(*) as session_count,
    AVG(duration_seconds) as avg_duration,
    SUM(CASE WHEN is_bounce THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as bounce_rate
FROM session_context
WHERE DATE(start_timestamp) = CURRENT_DATE - INTERVAL 1 DAY
GROUP BY HOUR(start_timestamp)
ORDER BY hour_of_day;

-- 3. Real-time Event Monitoring
SELECT 
    event_type,
    COUNT(*) as event_count,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT session_id) as unique_sessions
FROM events
WHERE event_timestamp >= NOW() - INTERVAL 15 MINUTE
GROUP BY event_type;

/*
EVENT TRACKING MODEL TRADEOFFS:

1. Data Volume Management:
   + Partitioning by date enables efficient data retention and queries
   + JSON properties provide flexibility for varying event attributes
   - Requires careful management of partition maintenance
   - JSON queries can be slower than structured columns

2. Real-time vs Batch Processing:
   + Rolling window aggregations enable real-time analytics
   + Pre-aggregated sessions reduce query complexity
   - Maintaining real-time aggregations adds system complexity
   - Session timeout handling requires careful implementation

3. Schema Evolution:
   + JSON properties allow adding new attributes without schema changes
   + Event type definitions provide documentation and validation
   - Schema validation for JSON can be complex
   - Querying nested JSON properties may be less efficient

4. Storage Considerations:
   + Partitioning helps with data lifecycle management
   + Compressed JSON storage can be space-efficient
   - High-volume events require significant storage
   - Backup and recovery complexity increases with data volume

5. Query Performance:
   + Indexed timestamp and user_id enable fast lookups
   + Pre-aggregated sessions improve common queries
   - Complex event sequence analysis can be slow
   - JSON property queries may not use indexes effectively
*/

-- Performance Optimization Indexes
CREATE INDEX idx_events_timestamp ON events(event_timestamp);
CREATE INDEX idx_events_user ON events(user_id);
CREATE INDEX idx_events_session ON events(session_id);
CREATE INDEX idx_events_type_time ON events(event_type, event_timestamp);

-- Example of a Materialized Path for Event Sequences
CREATE TABLE event_paths (
    path_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(50),
    session_id VARCHAR(100),
    event_sequence TEXT,
    event_count INT,
    start_timestamp TIMESTAMP,
    end_timestamp TIMESTAMP,
    COMMENT 'Pre-computed event sequences for path analysis'
);

-- Cleanup Procedure for Old Data
DELIMITER //
CREATE PROCEDURE cleanup_old_events()
BEGIN
    -- Delete events older than 90 days
    DELETE FROM events 
    WHERE event_date < CURRENT_DATE - INTERVAL 90 DAY;
    
    -- Archive sessions older than 90 days
    INSERT INTO archived_sessions
    SELECT * FROM session_context
    WHERE start_timestamp < CURRENT_DATE - INTERVAL 90 DAY;
    
    -- Delete archived sessions from main table
    DELETE FROM session_context
    WHERE start_timestamp < CURRENT_DATE - INTERVAL 90 DAY;
END //
DELIMITER ; 