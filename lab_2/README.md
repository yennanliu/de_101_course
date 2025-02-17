# Database Modeling Tutorial for Analytics

This tutorial demonstrates various approaches to database modeling for analytics purposes using MySQL. We'll explore different scenarios and their corresponding modeling solutions.

## Table of Contents

1. [Basic Concepts](/lab_2/doc/01_basic_concepts.md)
   - Tables, Columns, and Data Types
   - Primary Keys and Foreign Keys
   - Normalization Basics (1NF, 2NF, 3NF)
   - Indexes and Their Impact

2. [E-commerce Analytics Model](/lab_2/doc/02-ecommerce.md)
   - Star Schema Approach
   - Fact and Dimension Tables
   - Handling Historical Data
      - Slowly Changing Dimension, SCD)
      - Change Data Capture (CDC)
   - Performance Considerations   

3. [Event Tracking Model](/lab_2/doc/03_datamart_warehouse_tutorial.md)
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

- Install MySQL 8.0 or higher

## Book/Ref
- https://github.com/yennanliu/knowledge_base_repo/tree/master/book/data_engeering
- https://github.com/yennanliu/knowledge_base_repo/tree/master/book/data_modeling