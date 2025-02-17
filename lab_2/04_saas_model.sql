-- SaaS Analytics Model Tutorial
-- Demonstrates modeling for multi-tenant SaaS applications with subscription tracking

USE analytics_tutorial;

-- 1. Tenant Management
CREATE TABLE tenants (
    tenant_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(255) NOT NULL,
    industry VARCHAR(100),
    subscription_plan VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'suspended', 'cancelled') DEFAULT 'active',
    billing_email VARCHAR(255),
    admin_contact_name VARCHAR(255),
    max_users INT,
    custom_domain VARCHAR(255),
    COMMENT 'Core tenant information for multi-tenant setup'
);

-- 2. Subscription Management
CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    tenant_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    billing_cycle ENUM('monthly', 'annual') DEFAULT 'monthly',
    status ENUM('active', 'past_due', 'cancelled', 'trial') DEFAULT 'trial',
    mrr DECIMAL(10,2),
    quantity INT DEFAULT 1,
    trial_end_date DATE,
    cancelled_at TIMESTAMP NULL,
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    COMMENT 'Subscription tracking for revenue analytics'
);

-- 3. Usage Metrics
CREATE TABLE usage_metrics (
    metric_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    tenant_id INT NOT NULL,
    metric_date DATE NOT NULL,
    metric_name VARCHAR(50) NOT NULL,
    metric_value DECIMAL(15,2),
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    COMMENT 'Daily usage metrics per tenant'
) PARTITION BY RANGE (TO_DAYS(metric_date)) (
    PARTITION p_history VALUES LESS THAN (TO_DAYS('2024-01-01')),
    PARTITION p_current VALUES LESS THAN MAXVALUE
);

-- 4. Feature Usage Tracking
CREATE TABLE feature_usage (
    feature_id INT PRIMARY KEY AUTO_INCREMENT,
    tenant_id INT NOT NULL,
    feature_name VARCHAR(100) NOT NULL,
    first_used_at TIMESTAMP,
    last_used_at TIMESTAMP,
    usage_count INT DEFAULT 0,
    is_enabled BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    COMMENT 'Feature adoption and usage tracking'
);

-- 5. User Activity
CREATE TABLE user_activity (
    activity_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    tenant_id INT NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    activity_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resource_type VARCHAR(50),
    resource_id VARCHAR(50),
    metadata JSON,
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    COMMENT 'User activity tracking across tenants'
);

-- Sample Data
INSERT INTO tenants (company_name, industry, subscription_plan, max_users) VALUES
('Acme Corp', 'Manufacturing', 'enterprise', 100),
('StartupXYZ', 'Technology', 'startup', 10),
('ConsultCo', 'Consulting', 'professional', 50);

-- Example Analytics Queries

-- 1. Monthly Recurring Revenue (MRR) Analysis
SELECT 
    DATE_FORMAT(start_date, '%Y-%m-01') as month,
    SUM(mrr) as total_mrr,
    COUNT(DISTINCT tenant_id) as paying_customers,
    SUM(mrr) / COUNT(DISTINCT tenant_id) as arpu
FROM subscriptions
WHERE status = 'active'
GROUP BY DATE_FORMAT(start_date, '%Y-%m-01')
ORDER BY month;

-- 2. Customer Health Score
WITH usage_scores AS (
    SELECT 
        tenant_id,
        AVG(metric_value) as avg_usage,
        STDDEV(metric_value) as usage_variability
    FROM usage_metrics
    WHERE metric_date >= CURRENT_DATE - INTERVAL 30 DAY
    GROUP BY tenant_id
)
SELECT 
    t.tenant_id,
    t.company_name,
    t.subscription_plan,
    u.avg_usage,
    CASE 
        WHEN u.avg_usage > 75 AND u.usage_variability < 10 THEN 'Healthy'
        WHEN u.avg_usage BETWEEN 25 AND 75 THEN 'Moderate'
        ELSE 'At Risk'
    END as health_status
FROM tenants t
JOIN usage_scores u ON t.tenant_id = u.tenant_id;

-- 3. Feature Adoption Analysis
SELECT 
    f.feature_name,
    COUNT(DISTINCT f.tenant_id) as adopting_tenants,
    COUNT(DISTINCT f.tenant_id) * 100.0 / (SELECT COUNT(*) FROM tenants) as adoption_rate,
    AVG(f.usage_count) as avg_usage_per_tenant
FROM feature_usage f
GROUP BY f.feature_name
ORDER BY adopting_tenants DESC;

-- 4. Cohort Retention Analysis
WITH cohorts AS (
    SELECT 
        tenant_id,
        DATE_FORMAT(created_at, '%Y-%m-01') as cohort_month,
        TIMESTAMPDIFF(MONTH, 
            DATE_FORMAT(created_at, '%Y-%m-01'),
            DATE_FORMAT(CURRENT_DATE, '%Y-%m-01')
        ) as months_since_signup
    FROM tenants
)
SELECT 
    cohort_month,
    months_since_signup,
    COUNT(DISTINCT tenant_id) as active_tenants,
    COUNT(DISTINCT tenant_id) * 100.0 / 
        FIRST_VALUE(COUNT(DISTINCT tenant_id)) OVER (
            PARTITION BY cohort_month 
            ORDER BY months_since_signup
        ) as retention_rate
FROM cohorts
GROUP BY cohort_month, months_since_signup
ORDER BY cohort_month, months_since_signup;

/*
SAAS ANALYTICS MODEL TRADEOFFS:

1. Multi-tenant Data Storage:
   + Separate tenant_id enables clear data segregation
   + Easy to implement row-level security
   - Additional join complexity in queries
   - Need careful index design for tenant-specific queries

2. Subscription Management:
   + Flexible subscription status tracking
   + Support for different billing cycles
   - Complex subscription state management
   - Need careful handling of trial periods

3. Usage Tracking:
   + Granular feature usage data
   + Enables detailed customer health monitoring
   - High storage requirements
   - Potential performance impact from tracking

4. Performance Considerations:
   + Partitioning by date improves query performance
   + Tenant-specific indexes
   - Multi-tenant queries need optimization
   - Balance between granularity and performance

5. Analytics Complexity:
   + Rich data for customer behavior analysis
   + Flexible metric tracking
   - Complex cohort and retention queries
   - Need for materialized views for performance
*/

-- Performance Optimization
CREATE INDEX idx_tenant_subscription ON subscriptions(tenant_id, status);
CREATE INDEX idx_usage_tenant_date ON usage_metrics(tenant_id, metric_date);
CREATE INDEX idx_feature_tenant ON feature_usage(tenant_id, feature_name);

-- Materialized View for Daily Tenant Metrics
CREATE TABLE mv_daily_tenant_metrics (
    tenant_id INT,
    metric_date DATE,
    active_users INT,
    feature_usage_count INT,
    api_calls INT,
    storage_used DECIMAL(10,2),
    last_updated TIMESTAMP,
    PRIMARY KEY (tenant_id, metric_date),
    COMMENT 'Pre-aggregated daily metrics per tenant'
);

-- Tenant Health Score Calculation Procedure
DELIMITER //
CREATE PROCEDURE calculate_tenant_health_scores()
BEGIN
    INSERT INTO tenant_health_scores (tenant_id, health_score, calculated_at)
    SELECT 
        t.tenant_id,
        (
            COALESCE(usage_score, 0) * 0.4 +
            COALESCE(engagement_score, 0) * 0.3 +
            COALESCE(support_score, 0) * 0.3
        ) as health_score,
        NOW() as calculated_at
    FROM tenants t
    LEFT JOIN (
        -- Usage Score
        SELECT tenant_id, 
               AVG(metric_value)/MAX(metric_value) OVER () * 100 as usage_score
        FROM usage_metrics
        WHERE metric_date >= CURRENT_DATE - INTERVAL 30 DAY
        GROUP BY tenant_id
    ) u ON t.tenant_id = u.tenant_id
    LEFT JOIN (
        -- Engagement Score
        SELECT tenant_id,
               COUNT(*) * 100.0 / MAX(COUNT(*)) OVER () as engagement_score
        FROM user_activity
        WHERE activity_timestamp >= CURRENT_DATE - INTERVAL 30 DAY
        GROUP BY tenant_id
    ) e ON t.tenant_id = e.tenant_id
    LEFT JOIN (
        -- Support Score (inverse of support tickets)
        SELECT tenant_id,
               (1 - COUNT(*)/MAX(COUNT(*)) OVER ()) * 100 as support_score
        FROM support_tickets
        WHERE created_at >= CURRENT_DATE - INTERVAL 30 DAY
        GROUP BY tenant_id
    ) s ON t.tenant_id = s.tenant_id;
END //
DELIMITER ; 