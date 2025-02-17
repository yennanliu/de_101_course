-- E-commerce Analytics Model Tutorial
-- Demonstrates star schema design for e-commerce analytics

CREATE DATABASE IF NOT EXISTS e_commerce_demo;
USE e_commerce_demo;

-- 1. Dimension Tables
-- These contain descriptive attributes used for analysis

-- Time dimension for easy time-based analysis
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,  -- YYYYMMDD format
    full_date DATE NOT NULL,
    year INT,
    month INT,
    day INT,
    quarter INT,
    day_of_week INT,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    season VARCHAR(10)
);

-- Product dimension
CREATE TABLE dim_product (
    product_key INT PRIMARY KEY AUTO_INCREMENT,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(255),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    unit_price DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    current_status VARCHAR(20),
    first_available_date DATE,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP
);

-- Customer dimension
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(50) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(255),
    country VARCHAR(50),
    city VARCHAR(100),
    customer_segment VARCHAR(50),
    registration_date DATE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP
);

-- 2. Fact Tables
-- These contain the metrics and measurements

-- Sales fact table (grain: one row per product per order)
CREATE TABLE fact_sales (
    sales_key BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id VARCHAR(50) NOT NULL,
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    quantity INT,
    unit_price DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    sales_amount DECIMAL(10,2),
    profit_amount DECIMAL(10,2),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key)
);

-- Daily product metrics fact table (grain: one row per product per day)
CREATE TABLE fact_daily_product_metrics (
    metric_key BIGINT PRIMARY KEY AUTO_INCREMENT,
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    page_views INT,
    unique_visitors INT,
    add_to_cart_count INT,
    conversion_rate DECIMAL(5,2),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

-- 3. Example Analytics Queries

-- Sales by Category and Quarter
SELECT 
    p.category,
    YEAR(d.full_date) as year,
    QUARTER(d.full_date) as quarter,
    SUM(f.sales_amount) as total_sales,
    SUM(f.profit_amount) as total_profit
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category, YEAR(d.full_date), QUARTER(d.full_date)
ORDER BY year, quarter, total_sales DESC;

-- Customer Segment Analysis
SELECT 
    c.customer_segment,
    COUNT(DISTINCT f.customer_key) as customer_count,
    SUM(f.sales_amount) as total_sales,
    SUM(f.sales_amount) / COUNT(DISTINCT f.customer_key) as avg_customer_value
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.customer_segment
ORDER BY avg_customer_value DESC;

-- Product Performance Dashboard
SELECT 
    p.product_name,
    p.category,
    SUM(f.sales_amount) as total_sales,
    SUM(f.quantity) as units_sold,
    AVG(m.conversion_rate) as avg_conversion_rate,
    SUM(m.page_views) as total_page_views
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN fact_daily_product_metrics m ON p.product_key = m.product_key
GROUP BY p.product_name, p.category
ORDER BY total_sales DESC;

/*

Insert data to DB
*/

INSERT INTO dim_date (date_key, full_date, year, month, day, quarter, day_of_week, is_weekend, is_holiday, season) VALUES
(20240101, '2024-01-01', 2024, 1, 1, 1, 1, FALSE, TRUE, 'Winter'),
(20240102, '2024-01-02', 2024, 1, 2, 1, 2, FALSE, FALSE, 'Winter'),
(20240315, '2024-03-15', 2024, 3, 15, 1, 5, FALSE, FALSE, 'Spring'),
(20240704, '2024-07-04', 2024, 7, 4, 3, 4, TRUE, TRUE, 'Summer'),
(20241225, '2024-12-25', 2024, 12, 25, 4, 3, TRUE, TRUE, 'Winter');


INSERT INTO dim_product (product_id, product_name, category, subcategory, brand, unit_price, unit_cost, current_status, first_available_date) VALUES
('P001', 'Smartphone X', 'Electronics', 'Mobile Phones', 'TechBrand', 799.99, 500.00, 'Active', '2023-10-10'),
('P002', 'Laptop Pro', 'Electronics', 'Laptops', 'MegaTech', 1299.99, 900.00, 'Active', '2023-09-15'),
('P003', 'Running Shoes', 'Apparel', 'Shoes', 'Sporty', 99.99, 40.00, 'Active', '2023-06-20'),
('P004', 'Smartwatch', 'Electronics', 'Wearables', 'TechBrand', 199.99, 100.00, 'Discontinued', '2022-12-05'),
('P005', 'Bluetooth Speaker', 'Electronics', 'Audio', 'SoundKing', 49.99, 25.00, 'Active', '2024-01-05');



INSERT INTO dim_customer (customer_id, first_name, last_name, email, country, city, customer_segment, registration_date) VALUES
('C001', 'John', 'Doe', 'john.doe@example.com', 'USA', 'New York', 'Premium', '2021-03-15'),
('C002', 'Jane', 'Smith', 'jane.smith@example.com', 'Canada', 'Toronto', 'Regular', '2022-07-22'),
('C003', 'David', 'Johnson', 'david.johnson@example.com', 'UK', 'London', 'VIP', '2020-10-30'),
('C004', 'Emily', 'Brown', 'emily.brown@example.com', 'Germany', 'Berlin', 'New', '2023-05-10'),
('C005', 'Michael', 'White', 'michael.white@example.com', 'Australia', 'Sydney', 'Regular', '2022-01-25');


INSERT INTO fact_sales (order_id, date_key, product_key, customer_key, quantity, unit_price, unit_cost, discount_amount, sales_amount, profit_amount) VALUES
('O1001', 20240101, 1, 1, 1, 799.99, 500.00, 50.00, 749.99, 249.99),
('O1002', 20240102, 2, 2, 1, 1299.99, 900.00, 100.00, 1199.99, 299.99),
('O1003', 20240315, 3, 3, 2, 99.99, 40.00, 10.00, 189.98, 69.98),
('O1004', 20240704, 4, 4, 1, 199.99, 100.00, 20.00, 179.99, 79.99),
('O1005', 20241225, 5, 5, 3, 49.99, 25.00, 5.00, 134.97, 59.97);



INSERT INTO fact_daily_product_metrics (date_key, product_key, page_views, unique_visitors, add_to_cart_count, conversion_rate) VALUES
(20240101, 1, 5000, 3000, 200, 4.00),
(20240102, 2, 6000, 4000, 250, 4.20),
(20240315, 3, 2500, 1500, 100, 3.80),
(20240704, 4, 1500, 800, 50, 2.50),
(20241225, 5, 3500, 2000, 150, 4.30);

/*
STAR SCHEMA DESIGN TRADEOFFS:

1. Advantages:
   - Simple and intuitive schema
   - Optimized for OLAP queries
   - Reduced number of JOINs
   - Easy to understand and maintain
   - Efficient for aggregations

2. Disadvantages:
   - Data redundancy in dimension tables
   - Regular maintenance needed for slowly changing dimensions
   - More storage space required
   - Not suitable for transactional processing

3. Design Considerations:
   - Grain of fact tables is crucial
   - Balance between normalized and denormalized dimensions
   - Type of slowly changing dimension (SCD) to implement
   - Partitioning strategy for large fact tables

4. Performance Optimization:
   - Create appropriate indexes on foreign keys
   - Partition large fact tables by date
   - Materialize common aggregations
   - Regular statistics updates

5. Data Quality:
   - Implement constraints on dimension keys
   - Ensure referential integrity
   - Handle NULL values appropriately
   - Regular data quality checks
*/

-- 4. Indexing Strategy
CREATE INDEX idx_fact_sales_date ON fact_sales(date_key);
CREATE INDEX idx_fact_sales_product ON fact_sales(product_key);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_key);
CREATE INDEX idx_product_metrics_date ON fact_daily_product_metrics(date_key);

-- 5. Example of a Materialized Summary Table
CREATE TABLE summary_daily_sales (
    date_key INT,
    category VARCHAR(100),
    total_sales DECIMAL(15,2),
    total_profit DECIMAL(15,2),
    order_count INT,
    customer_count INT,
    COMMENT 'Pre-aggregated daily sales by category'
); 