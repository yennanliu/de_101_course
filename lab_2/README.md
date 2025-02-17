# Database Modeling Tutorial for Analytics

This tutorial demonstrates various approaches to database modeling for analytics purposes using MySQL. We'll explore different scenarios and their corresponding modeling solutions.

## Table of Contents

1. [Basic Concepts](01_basic_concepts.sql)
   - Tables, Columns, and Data Types
   - Primary Keys and Foreign Keys
   - Normalization Basics (1NF, 2NF, 3NF)
   - Indexes and Their Impact

2. [E-commerce Analytics Model](02_ecommerce_model.sql)
   - Star Schema Approach
   - Fact and Dimension Tables
   - Handling Historical Data
      - Slowly Changing Dimension, SCD)
      - Change Data Capture (CDC)
   - Performance Considerations   

3. [Event Tracking Model](03_event_tracking.sql)
   - Time-series Data Modeling
   - Event Attribution
   - Handling High-Volume Data
   - Partitioning Strategies

4. [SaaS Analytics Model](04_saas_model.sql)
   - Multi-tenant Architecture
   - Subscription Tracking
   - User Behavior Analysis
   - Resource Usage Monitoring

## Prerequisites
- MySQL 8.0 or higher
- Basic SQL knowledge
- Understanding of database concepts


## Book/Ref
- https://github.com/yennanliu/knowledge_base_repo/tree/master/book/data_engeering
- https://github.com/yennanliu/knowledge_base_repo/tree/master/book/data_modeling