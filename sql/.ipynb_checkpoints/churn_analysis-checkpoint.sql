-- =========================================================
-- BANK CUSTOMER CHURN ANALYSIS
-- SQL Analysis
-- =========================================================

-- 1. Dataset Overview
-- Check the total number of customers

SELECT
    COUNT(*) AS total_customers
FROM customers;
-- 2. Overall Customer Churn
-- Calculate total customers, churned customers, and overall churn rate

SELECT
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(AVG(Exited) * 100, 2) AS churn_rate_pct
FROM customers;
-- 3. Customer Churn by Geography
-- Compare customer volume and churn rate across countries

SELECT
    Geography,
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(AVG(Exited) * 100, 2) AS churn_rate_pct
FROM customers
GROUP BY Geography
ORDER BY churn_rate_pct DESC;
-- 4. Customer Churn by Activity Status
-- Compare churn between active and inactive customers

SELECT
    CASE
        WHEN IsActiveMember = 1 THEN 'Active'
        ELSE 'Inactive'
    END AS activity_status,
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(AVG(Exited) * 100, 2) AS churn_rate_pct
FROM customers
GROUP BY IsActiveMember
ORDER BY churn_rate_pct DESC;
-- 5. Customer Churn by Age Group
-- Segment customers by age and compare churn rates

SELECT
    CASE
        WHEN Age BETWEEN 18 AND 29 THEN '18-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(AVG(Exited) * 100, 2) AS churn_rate_pct
FROM customers
GROUP BY age_group
ORDER BY
    CASE age_group
        WHEN '18-29' THEN 1
        WHEN '30-39' THEN 2
        WHEN '40-49' THEN 3
        WHEN '50-59' THEN 4
        WHEN '60-69' THEN 5
        WHEN '70+' THEN 6
    END;
-- 6. Customer Churn by Number of Products
-- Examine whether the number of products held is associated with churn

SELECT
    NumOfProducts AS number_of_products,
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(AVG(Exited) * 100, 2) AS churn_rate_pct
FROM customers
GROUP BY NumOfProducts
ORDER BY NumOfProducts;
-- 7. Higher-Churn Customer Segments
-- Combine geography, activity status, and age group
-- Only include segments with at least 100 customers

SELECT
    Geography,
    CASE
        WHEN IsActiveMember = 1 THEN 'Active'
        ELSE 'Inactive'
    END AS activity_status,
    CASE
        WHEN Age BETWEEN 18 AND 29 THEN '18-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(AVG(Exited) * 100, 2) AS churn_rate_pct
FROM customers
GROUP BY
    Geography,
    IsActiveMember,
    age_group
HAVING COUNT(*) >= 100
ORDER BY churn_rate_pct DESC;
-- 8. Rank Age Groups by Churn Rate Within Each Geography
-- Use a CTE and window function to rank customer segments

WITH age_churn AS (
    SELECT
        Geography,
        CASE
            WHEN Age BETWEEN 18 AND 29 THEN '18-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            ELSE '70+'
        END AS age_group,
        COUNT(*) AS total_customers,
        SUM(Exited) AS churned_customers,
        ROUND(AVG(Exited) * 100, 2) AS churn_rate_pct
    FROM customers
    GROUP BY Geography, age_group
),

ranked_segments AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY Geography
            ORDER BY churn_rate_pct DESC
        ) AS churn_rank
    FROM age_churn
)

SELECT *
FROM ranked_segments
ORDER BY Geography, churn_rank;