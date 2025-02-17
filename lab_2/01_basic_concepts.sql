-- Database Modeling Tutorial: Basic Concepts
-- This script covers fundamental concepts of database modeling for analytics

-- 1. Creating a Database
CREATE DATABASE IF NOT EXISTS analytics_tutorial;
USE analytics_tutorial;

-- 2. Basic Table Creation with Different Data Types
-- Example: Customer Profile Table
-- Demonstrates various data types and their use cases
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    registration_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loyalty_points DECIMAL(10,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE
);

-- 3. Foreign Key Relationships
-- Example: Orders linked to Customers
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 4. Creating Indexes for Better Query Performance
-- Note: Indexes improve read performance but impact write performance
CREATE INDEX idx_customer_email ON customers(email);
CREATE INDEX idx_order_date ON orders(order_date);

-- 5. Sample Data Insertion

-- Use the database
USE analytics_tutorial;

-- Insert sample data into customers table
INSERT INTO customers (email, first_name, last_name, date_of_birth, loyalty_points, is_active) VALUES
('john.doe@example.com', 'John', 'Doe', '1990-01-15', 120.50, TRUE),
('jane.smith@example.com', 'Jane', 'Smith', '1985-03-20', 250.75, TRUE),
('mike.johnson@example.com', 'Mike', 'Johnson', '1978-07-10', 80.00, TRUE),
('emily.brown@example.com', 'Emily', 'Brown', '1995-11-30', 300.00, TRUE),
('david.white@example.com', 'David', 'White', '2000-07-18', 50.25, FALSE);

-- Insert sample data into orders table
INSERT INTO orders (customer_id, total_amount, status) VALUES
(1, 99.99, 'COMPLETED'),
(1, 150.50, 'PENDING'),
(2, 75.25, 'COMPLETED'),
(3, 200.00, 'CANCELLED'),
(4, 320.50, 'SHIPPED'),
(5, 180.00, 'PENDING');


-- 6. Example Analytics Queries

-- Basic customer analysis
SELECT 
    c.first_name,
    c.last_name,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Time-based analysis
SELECT 
    DATE(order_date) as order_day,
    COUNT(*) as daily_orders,
    SUM(total_amount) as daily_revenue
FROM orders
GROUP BY DATE(order_date)
ORDER BY order_day;

/* 
TRADEOFFS AND CONSIDERATIONS:

1. Normalization vs Denormalization
   - Normalized tables (as shown above) ensure data consistency
   - But require JOINs for analysis, which can be slower
   - Consider denormalization for heavy read workloads

2. Index Strategy
   - Indexes speed up queries but slow down writes
   - Only create indexes that support your common queries
   - Monitor index usage and remove unused ones

3. Data Types
   - Use appropriate data types for columns
   - VARCHAR vs CHAR: VARCHAR for variable length, CHAR for fixed
   - INT vs BIGINT: Consider future growth
   - TIMESTAMP vs DATETIME: TIMESTAMP is more storage efficient

4. Primary Keys
   - AUTO_INCREMENT is simple but may not scale well in sharded environments
   - Consider UUID for distributed systems
   - Composite keys can be useful but complicate queries

5. Constraints
   - Foreign keys ensure data integrity
   - But can slow down write operations
   - May need to be reconsidered in high-volume write scenarios
*/

-- Example of a denormalized table for comparison
CREATE TABLE denormalized_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_email VARCHAR(255),
    customer_name VARCHAR(100),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status VARCHAR(20)
);

-- This denormalized approach:
-- (+) Faster reads - no JOINs needed
-- (-) Data redundancy
-- (-) More storage space required
-- (-) Risk of data inconsistency
-- Best used when read performance is critical and data consistency can be managed at the application level

-- Insert sample data into denormalized_orders table
INSERT INTO denormalized_orders (customer_email, customer_name, order_date, total_amount, status) VALUES
('john.doe@example.com', 'John Doe', NOW(), 99.99, 'COMPLETED'),
('john.doe@example.com', 'John Doe', NOW(), 150.50, 'PENDING'),
('jane.smith@example.com', 'Jane Smith', NOW(), 75.25, 'COMPLETED'),
('mike.johnson@example.com', 'Mike Johnson', NOW(), 200.00, 'CANCELLED'),
('emily.brown@example.com', 'Emily Brown', NOW(), 320.50, 'SHIPPED'),
('david.white@example.com', 'David White', NOW(), 180.00, 'PENDING');


