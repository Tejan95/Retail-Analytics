-- ==============================================================================
-- CASE STUDY: RETAIL ANALYTICS SOLUTIONS
-- Author: Tejan Chaudhari
-- Tools Used: MySQL 8.0+
-- ==============================================================================

-- ── STEP 1: DATABASE & TABLE SETUP ────────────────────────────────────────────
CREATE DATABASE IF NOT EXISTS retail_analytics;
USE retail_analytics;

-- Create customer_profiles table
CREATE TABLE customer_profiles (
	CustomerID	INT 			NOT NULL PRIMARY KEY,
	Age			INT,
	Gender		VARCHAR(10),
	Location	VARCHAR(50),
    JoinDate	date
    );

-- Create product_inventory table
CREATE TABLE product_inventory (
	ProductID	INT 			NOT NULL PRIMARY KEY,
    ProductName	VARCHAR(200),
    Category	VARCHAR(100),
    StockLevel	INT,
    Price		DECIMAL(10, 2)
    );

-- Create sales_transactions table
CREATE TABLE sales_transactions (
	TransactionID	INT			NOT NULL PRIMARY KEY,
    CustomerID		INT			NOT NULL,
    ProductID		INT			NOT NULL,
    QuantityPurchased	INT		NOT NULL,
    TransactionDate		DATE	NOT NULL,
    Price			DECIMAL(10, 2)	NOT NULL,
    FOREIGN KEY	(CustomerID) REFERENCES	customer_profiles(CustomerID),
    FOREIGN KEY (ProductID)	REFERENCES	product_inventory(ProductID)
    );
    
-- ── STEP 2: DATA CLEANING & EDA  ─────────────────────────────────

-- NULL check: sales_transactions
SELECT
	SUM(CASE WHEN TransactionID		IS NULL THEN 1 ELSE 0 END) AS
null_TransactionID,
	SUM(CASE WHEN CustomerID		IS NULL THEN 1 ELSE 0 END) AS
null_CustomerID,
	SUM(CASE WHEN ProductID			IS NULL THEN 1 ELSE 0 END) AS
null_ProductID,
	SUM(CASE WHEN QuantityPurchased			IS NULL THEN 1 ELSE 0 END) AS
null_Quantity,
	SUM(CASE WHEN TransactionDate			IS NULL THEN 1 ELSE 0 END) AS
null_Date,
	SUM(CASE WHEN Price			IS NULL THEN 1 ELSE 0 END) AS
null_Price
FROM sales_transactions;

-- NULL check: customer_profiles
SELECT
	SUM(CASE WHEN CustomerID		IS NULL THEN 1 ELSE 0 END) AS
null_CustomerID,
	SUM(CASE WHEN Age			IS NULL THEN 1 ELSE 0 END) AS
null_Age,
	SUM(CASE WHEN Gender			IS NULL THEN 1 ELSE 0 END) AS
null_Gender,
	SUM(CASE WHEN Location			IS NULL THEN 1 ELSE 0 END) AS
null_Location,
	SUM(CASE WHEN JoinDate			IS NULL THEN 1 ELSE 0 END) AS
null_JoinDate
FROM customer_profiles;

-- NULL check: product_inventory
SELECT
	SUM(CASE WHEN ProductID		IS NULL THEN 1 ELSE 0 END) AS
null_ProductID,
	SUM(CASE WHEN ProductName			IS NULL THEN 1 ELSE 0 END) AS
null_ProductName,
	SUM(CASE WHEN Category			IS NULL THEN 1 ELSE 0 END) AS
null_Category,
	SUM(CASE WHEN StockLevel			IS NULL THEN 1 ELSE 0 END) AS
null_StockLevel,
	SUM(CASE WHEN Price			IS NULL THEN 1 ELSE 0 END) AS
null_Price
FROM product_inventory;

SET SQL_SAFE_UPDATES = 0;

UPDATE customer_profiles
SET Location = 'Unknown'
WHERE Location IS NULL;

-- Duplicate TransactionIDs
SELECT TransactionID, COUNT(*) AS occurrence_count
FROM sales_transactions
GROUP BY TransactionID
HAVING COUNT(*) > 1;

-- Duplicate CustomerIDs
SELECT CustomerID, COUNT(*) AS occurrence_count
FROM customer_profiles
GROUP BY CustomerID
HAVING COUNT(*) > 1;

-- Duplicate ProductIDs
SELECT ProductID, COUNT(*) AS occurrence_count
FROM product_inventory
GROUP BY ProductID
HAVING COUNT(*) > 1;

-- Check for Invalid/Illogical Values
-- Negative or zero QuantityPurchased
SELECT * FROM sales_transactions WHERE QuantityPurchased <=0;

-- Negative or zero price
SELECT * FROM sales_transactions WHERE Price <= 0;
SELECT * FROM product_inventory WHERE Price <= 0;

-- Unrealistic Age (< 5 or > 100)
SELECT * FROM customer_profiles WHERE Age < 5 OR Age > 110;

-- Future TransactionDates
SELECT * FROM sales_transactions WHERE TransactionDate > CURDATE();

-- Transactions before the customer's JoinDate
SELECT
	st.TransactionID,
    st.CustomerID,
    st.TransactionDate,
    cp.JoinDate
FROM sales_transactions st
JOIN customer_profiles cp ON st.CustomerID = cp.CustomerID
WHERE st.TransactionDate < cp.JoinDate;

-- Fix Invalid age
UPDATE customer_profiles
SET Age = null
WHERE Age > 110 OR Age < 5;

-- Sales records with no matching customer
SELECT st.TransactionID, st.CustomerID
FROM sales_transactions st
LEFT JOIN customer_profiles cp ON st.CustomerID = cp.CustomerID
WHERE cp.CustomerID IS NULL;

-- Sales records with no matching product
SELECT st.TransactionID, st.ProductID
FROM sales_transactions st
LEFT JOIN product_inventory pi ON st.ProductID = pi.ProductID
WHERE pi.ProductID IS NULL;

-- Inspect distinct Gender values
SELECT Gender, COUNT(*) AS count
FROM customer_profiles
GROUP BY Gender
ORDER BY count DESC;

-- Inspect distinct Category values
SELECT Category, COUNT(*) AS count
FROM product_inventory
GROUP BY Category
ORDER BY count DESC;

-- Inspect distinct Location values
SELECT Location, COUNT(*) AS count
FROM customer_profiles
GROUP BY Location
ORDER BY count DESC;

-- Row counts for all tables
SELECT 'sales_transaction' AS table_name, COUNT(*) AS total_rows FROM
sales_transactions
UNION ALL
SELECT 'customer_profiles', COUNT(*) FROM
customer_profiles
UNION ALL
SELECT 'product_inventory', COUNT(*) FROM
product_inventory;

-- Sales date range
SELECT
	MIN(TransactionDate) AS earliest_sale,
    MAX(TransactionDate) AS latest_sale,
    DATEDIFF(MAX(TransactionDate),
			 MIN(TransactionDate)) AS total_days_span
FROM sales_transactions;

-- Overall revenue and average order value
SELECT
	COUNT(*) AS total_transactions,
    ROUND(SUM(QuantityPurchased * Price), 2) AS total_revenue,
    ROUND(AVG(QuantityPurchased * Price), 2) AS avg_order_value,
    SUM(QuantityPurchased) AS total_units_sold
FROM sales_transactions;

-- Monthly revenue trend
SELECT
	DATE_FORMAT(TransactionDate, '%Y-%m') AS month,
    COUNT(*) AS num_transactions,
    SUM(QuantityPurchased) AS units_sold,
    ROUND(SUM(QuantityPurchased * Price), 2) AS monthly_revenue
FROM sales_transactions
GROUP BY DATE_FORMAT(TransactionDate, '%Y-%m')
ORDER BY month;

-- Customer distribution
SELECT
	Gender,
    COUNT(*) AS num_customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*)
			FROM customer_profiles), 1) AS pct
FROM customer_profiles
GROUP BY Gender
ORDER BY num_customers DESC;

-- Location distribution
SELECT
	Location,
    COUNT(*)	AS num_customers
FROM customer_profiles
GROUP BY Location
ORDER BY num_customers DESC;

-- Age bracket distribution
SELECT
	CASE 
		WHEN Age < 25					THEN 'Under 25'
        WHEN Age BETWEEN 25 AND 34		THEN '25-34'
        WHEN Age BETWEEN 35 AND 44		THEN '35-44'
        WHEN Age BETWEEN 45 AND 54		THEN '45-54'
        ELSE '55+'
	END			AS age_bracket,
    COUNT(*) 	AS num_customers
FROM customer_profiles
GROUP BY age_bracket
ORDER BY MIN(Age);

-- Product inventory overview
SELECT
	Category,
    COUNT(*)	AS num_products,
    ROUND(AVG(Price), 2) AS avg_price,
    MIN(Price) AS min_price,
    MAX(Price) AS max_price,
    SUM(StockLevel) AS total_stock
FROM product_inventory
GROUP BY Category
ORDER BY num_products DESC;

-- ── STEP 3: PRODUCT PERFORMANCE ANALYSIS ────────────────────────

-- Total revenue and units sold per product
SELECT
	pi.ProductID,
    pi.ProductName,
    pi.Category,
    pi.Price AS listed_price,
    COALESCE(SUM(st.QuantityPurchased), 0) AS total_units_sold,
    COALESCE(ROUND(SUM(st.QuantityPurchased * st.Price), 2), 0) AS total_revenue,
    COUNT(st.TransactionID) AS num_transactions
FROM product_inventory pi
LEFT JOIN sales_transactions st ON pi.ProductID = st.ProductID
GROUP BY pi.ProductID, pi.ProductName, pi.Category, pi.Price
ORDER BY total_revenue DESC;

-- High Perfomers vs Low Performers (Revenue Quintiles)
SELECT
	ProductID,
    ProductName,
    Category,
    total_units_sold,
    total_revenue,
    revenue_quintile,
    CASE revenue_quintile
		WHEN 5 THEN 'High Performer'
        WHEN 4 THEN 'Good'
        WHEN 3 THEN 'Mid'
        WHEN 2 THEN 'Low'
        WHEN 1 THEN 'Low Performer'
	END AS performance_label
FROM (
	SELECT
		pi.ProductID,
        pi.ProductName,
        pi.Category,
        COALESCE(SUM(st.QuantityPurchased), 0) AS total_units_sold,
        COALESCE(ROUND(SUM(st.QuantityPurchased * st.Price), 2), 0) AS total_revenue,
        NTILE(5) OVER (
				ORDER BY COALESCE(SUM(st.QuantityPurchased * st.Price), 0) 
                ) AS revenue_quintile
	FROM product_inventory pi
    LEFT JOIN sales_transactions st ON pi.ProductID = st.ProductID
    GROUP BY pi.ProductID, pi.ProductName, pi.Category
) ranked
ORDER BY total_revenue DESC;

-- Top 10 products by revenue
SELECT
	pi.ProductID,
    pi.ProductName,
    pi.Category,
    SUM(st.QuantityPurchased) AS total_units_sold,
    ROUND(SUM(st.QuantityPurchased * st.Price), 2) AS total_revenue
FROM product_inventory pi
JOIN sales_transactions st ON pi.ProductID = st.ProductID
GROUP BY pi.ProductID, pi.ProductName, pi.Category
ORDER BY total_revenue DESC
LIMIT 10;

-- Bottom 10 products by revenue
SELECT
	pi.ProductID,
    pi.ProductName,
    pi.Category,
    SUM(st.QuantityPurchased) AS total_units_sold,
    ROUND(SUM(st.QuantityPurchased * st.Price), 2) AS total_revenue
FROM product_inventory pi
JOIN sales_transactions st ON pi.ProductID = st.ProductID
GROUP BY pi.ProductID, pi.ProductName, pi.Category
ORDER BY total_revenue ASC
LIMIT 10;

-- Category level performance
SELECT
	pi.Category,
    COUNT(DISTINCT pi.ProductID) AS num_products,
    SUM(st.QuantityPurchased) AS total_units_sold,
    ROUND(SUM(st.QuantityPurchased * st.Price), 2) AS total_revenue,
    ROUND(SUM(st.QuantityPurchased * st.Price)
		/ COUNT(DISTINCT pi.ProductID), 2) AS revenue_per_product
FROM product_inventory pi
JOIN sales_transactions st ON pi.ProductID = st.ProductID
GROUP BY pi.Category
ORDER BY total_revenue DESC;

-- Stock health - Overstock vs Low Stock vs Out of Stock
SELECT
	pi.ProductID,
    pi.ProductName,
    pi.Category,
    pi.StockLevel,
    COALESCE(SUM(st.QuantityPurchased), 0) AS total_units_sold,
    CASE
		WHEN COALESCE(SUM(st.QuantityPurchased), 0) = 0
			THEN 'Dead Stock'
		WHEN pi.StockLevel = 0
			THEN 'Out of Stock'
		WHEN pi.StockLevel < COALESCE(SUM(st.QuantityPurchased), 0) * 0.10
			THEN 'Low Stock Risk'
		WHEN pi.StockLevel > COALESCE(SUM(st.QuantityPurchased), 0) * 3
			THEN 'Overstock'
		ELSE 'Healthy'
	END AS stock_status
FROM product_inventory pi
LEFT JOIN sales_transactions st ON pi.ProductID = st.ProductID
GROUP BY pi.ProductID, pi.ProductName, pi.Category, pi.StockLevel
ORDER BY stock_status, total_units_sold DESC;

-- ── STEP 4: CUSTOMER SEGMENTATION ───────────────────────────────

-- Total Quantity Purchsed per Customer
SELECT
	CustomerID,
    SUM(QuantityPurchased) AS total_qty_purchased
FROM sales_transactions
GROUP BY CustomerID
ORDER BY total_qty_purchased DESC;

-- Four-Tier segmentation logic
WITH customer_totals AS (
	SELECT
		CustomerID,
		SUM(QuantityPurchased) AS total_qty_purchased
	FROM sales_transactions
	GROUP BY CustomerID
)
SELECT
	cp.CustomerID,
    cp.Age,
    cp.Gender,
    cp.Location,
    cp.JoinDate,
    COALESCE(ct.total_qty_purchased, 0) AS total_qty_purchased,
    CASE
		WHEN COALESCE(ct.total_qty_purchased, 0) = 0 THEN 'No Orders'
        WHEN COALESCE(ct.total_qty_purchased, 0) <= 10 THEN 'Low'
        WHEN COALESCE(ct.total_qty_purchased, 0) <= 30 THEN 'Mid'
        ELSE 'High Value'
	END AS customer_segment
FROM customer_profiles cp
LEFT JOIN customer_totals ct ON cp.CustomerID = ct.CustomerID
ORDER BY total_qty_purchased DESC;

-- Segment distribution summary
WITH customer_totals AS (
	SELECT
		CustomerID,
		SUM(QuantityPurchased) AS total_qty_purchased
	FROM sales_transactions
	GROUP BY CustomerID
),
segmented AS (
SELECT
	cp.CustomerID,
    CASE
		WHEN COALESCE(ct.total_qty_purchased, 0) = 0 THEN 'No Orders'
        WHEN COALESCE(ct.total_qty_purchased, 0) <= 10 THEN 'Low'
        WHEN COALESCE(ct.total_qty_purchased, 0) <= 30 THEN 'Mid'
        ELSE 'High Value'
	END AS customer_segment
FROM customer_profiles cp
LEFT JOIN customer_totals ct ON cp.CustomerID = ct.CustomerID
)
SELECT
	customer_segment,
    COUNT(*) AS num_customers,
    ROUND(COUNT(*) * 100.0 / 1000, 1) AS pct_of_total
FROM segmented
GROUP BY customer_segment
ORDER BY
	CASE customer_segment
		WHEN 'High Value' THEN 1
        WHEN 'Mid'	THEN 2
        WHEN 'Low' THEN 3
        ELSE 4
	END;
    
-- Revenue contribution by segment
WITH customer_totals AS (
	SELECT
		CustomerID,
        SUM(QuantityPurchased) AS total_qty_purchased
	FROM sales_transactions
    GROUP BY CustomerID
),
segmented AS (
	SELECT
		cp.CustomerID,
        CASE
			WHEN COALESCE(ct.total_qty_purchased, 0) = 0 THEN 'No Orders'
			WHEN COALESCE(ct.total_qty_purchased, 0) <= 10 THEN 'Low'
			WHEN COALESCE(ct.total_qty_purchased, 0) <= 30 THEN 'Mid'
			ELSE 'High Value'
		END AS customer_segment
	FROM customer_profiles cp
    LEFT JOIN customer_totals ct ON cp.CustomerID = ct.CustomerID
)
SELECT
	s.customer_segment,
    COUNT(DISTINCT s.CustomerID) AS num_customers,
    ROUND(SUM(st.QuantityPurchased * st.Price), 2) AS total_revenue,
    ROUND(SUM(st.QuantityPurchased * st.Price)
		/ COUNT(DISTINCT s.CustomerID), 2) AS avg_revenue_per_customer
FROM segmented s
JOIN sales_transactions st ON s.CustomerID = st.CustomerID
GROUP BY s.customer_segment 
ORDER BY total_revenue DESC;

-- Segment breakdown by Gender & Location
WITH customer_totals AS (
	SELECT
		CustomerID,
        SUM(QuantityPurchased) AS total_qty_purchased
	FROM sales_transactions
    GROUP BY CustomerID
),
segmented AS (
	SELECT
		cp.CustomerID,
        cp.Gender,
        cp.Location,
		CASE
			WHEN COALESCE(ct.total_qty_purchased, 0) = 0 THEN 'No Orders'
			WHEN COALESCE(ct.total_qty_purchased, 0) <= 10 THEN 'Low'
			WHEN COALESCE(ct.total_qty_purchased, 0) <= 30 THEN 'Mid'
			ELSE 'High Value'
		END AS customer_segment
	FROM customer_profiles cp
    LEFT JOIN customer_totals ct ON cp.CustomerID = ct.CustomerID
)
SELECT
	Gender,
    SUM(CASE WHEN customer_segment = 'High Value' THEN 1 ELSE 0 END) AS High_Value,
    SUM(CASE WHEN customer_segment = 'Mid' THEN 1 ELSE 0 END) AS Mid,
    SUM(CASE WHEN customer_segment = 'Low' THEN 1 ELSE 0 END) AS Low,
    SUM(CASE WHEN customer_segment = 'No Orders' THEN 1 ELSE 0 END) AS No_Orders,
    COUNT(*) AS total
FROM segmented
GROUP BY Gender;

-- ── STEP 5: CUSTOMER BEHAVIOUR ANALYSIS ─────────────────────────

-- Repeat Purchases vs One-Time Buyers
SELECT
	purchase_frequency_group,
    COUNT(*) AS num_customers,
    ROUND(COUNT(*) * 100.0 /
		(SELECT COUNT(DISTINCT CustomerID)
        FROM sales_transactions), 1) AS pct_of_buyers
FROM (
	SELECT
		CustomerID,
        COUNT(DISTINCT TransactionID) AS num_transactions,
        CASE
			WHEN COUNT(DISTINCT TransactionID) = 1 THEN 'One-Time Buyers'
            WHEN COUNT(DISTINCT TransactionID) BETWEEN 2 AND 5 THEN 'Occasional Buyer (2-5)'
            WHEN COUNT(DISTINCT TransactionID) > 5 THEN 'Frequent Buyer (6+)'
		END AS purchase_frequency_group
	FROM sales_transactions
    GROUP BY CustomerID
) freg_groups
GROUP BY purchase_frequency_group
ORDER BY num_customers DESC;

-- Average Order Value (AOV) per Customer
SELECT
	CustomerID,
    COUNT(DISTINCT TransactionID) AS num_orders,
    SUM(QuantityPurchased) AS total_units_bought,
    ROUND(SUM(QuantityPurchased * Price), 2) AS total_spend,
    ROUND(SUM(QuantityPurchased * Price)
		/ COUNT(DISTINCT TransactionID), 2) AS avg_order_value
FROM sales_transactions
GROUP BY CustomerID
ORDER BY total_spend DESC
LIMIT 20;

-- Customer Recency - Days since last purchase
SELECT 
	CustomerID,
    MAX(TransactionDate) AS last_purchase_date,
    DATEDIFF('2023-07-28', MAX(TransactionDate)) AS days_since_last_purchase,
	CASE
		WHEN DATEDIFF('2023-07-28', MAX(TransactionDate)) <= 30 THEN 'Active'
        WHEN DATEDIFF('2023-07-28', MAX(TransactionDate)) <= 90 THEN 'At Risk'
        WHEN DATEDIFF('2023-07-28', MAX(TransactionDate)) <= 180 THEN 'Lapsed'
        ELSE 'Churned'
	END AS recency_status
FROM sales_transactions
GROUP BY CustomerID
ORDER BY days_since_last_purchase DESC;

-- Recency status distribution summary
SELECT
	recency_status,
    COUNT(*) AS num_customers,
    ROUND(COUNT(*) * 100.0 /
		(SELECT COUNT(DISTINCT CustomerID)
        FROM sales_transactions), 1) AS pct
FROM (
	SELECT
		CustomerID,
        CASE
			WHEN DATEDIFF('2023-07-28', MAX(TransactionDate)) <= 30 THEN 'Active'
			WHEN DATEDIFF('2023-07-28', MAX(TransactionDate)) <= 90 THEN 'At Risk'
			WHEN DATEDIFF('2023-07-28', MAX(TransactionDate)) <= 180 THEN 'Lapsed'
			ELSE 'Churned'
		END AS recency_status
	FROM sales_transactions
	GROUP BY CustomerID
) recency_data
GROUP BY recency_status
ORDER BY
	CASE recency_status
		WHEN 'Active' THEN 1
        WHEN 'At Risk' THEN 2
        WHEN 'Lapsed' THEN 3
        ELSE 4
	END;
    
-- Full RFM Analysis - Recency, Frequency, Monetary

WITH rfm_base AS (
	SELECT
		CustomerID,
        DATEDIFF('2023-07-28',
				MAX(TransactionDate)) AS recency_days,
		COUNT(DISTINCT TransactionID) AS frequency,
        ROUND(SUM(QuantityPurchased * Price), 2) AS monetary
	FROM sales_transactions
    GROUP BY CustomerID
),
rfm_scored AS (
	SELECT
		CustomerID,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
	FROM rfm_base
)
SELECT
	CustomerID,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS total_rfm_score,
    CASE
		WHEN (r_score + f_score + m_score) >= 13
			THEN 'Champions'
		WHEN (r_score + f_score + m_score) >= 10
			THEN 'Loyal Customers'
		WHEN (r_score + f_score + m_score) >= 7
			THEN 'Potential Loyalists'
		WHEN (r_score + f_score + m_score) >= 4
			THEN 'At Risk'
		ELSE 'Lost'
	END AS rfm_segment
FROM rfm_scored
ORDER BY total_rfm_score DESC;

-- RFM Segment Distribution
WITH rfm_base AS (
	SELECT
		CustomerID,
        DATEDIFF('2023-07-28',
				MAX(TransactionDate)) AS recency_days,
		COUNT(DISTINCT TransactionID) AS frequency,
        ROUND(SUM(QuantityPurchased * Price), 2) AS monetary
	FROM sales_transactions
    GROUP BY CustomerID
),
rfm_scored AS (
	SELECT
		CustomerID,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
	FROM rfm_base
),
rfm_labelled AS (
	SELECT
		CustomerID,
        (r_score + f_score + m_score) AS total_rfm_score,
        CASE
		WHEN (r_score + f_score + m_score) >= 13
			THEN 'Champions'
		WHEN (r_score + f_score + m_score) >= 10
			THEN 'Loyal Customers'
		WHEN (r_score + f_score + m_score) >= 7
			THEN 'Potential Loyalists'
		WHEN (r_score + f_score + m_score) >= 4
			THEN 'At Risk'
		ELSE 'Lost'
	END AS rfm_segment
FROM rfm_scored
)
SELECT
	rfm_segment,
    COUNT(*) AS num_customers,
    ROUND(COUNT(*) * 100.0 /
		 (SELECT COUNT(*) FROM rfm_labelled), 1) AS pct
FROM rfm_labelled
GROUP BY rfm_segment
ORDER BY 
    CASE
		WHEN 'Champions' THEN 1
		WHEN 'Loyal Customers' THEN 2
		WHEN 'Potential Loyalists' THEN 3
		WHEN 'At Risk' THEN 4
		ELSE 5
	END;

-- Combined Segment + RFM View
WITH customer_totals AS (
	SELECT
		CustomerID,
        SUM(QuantityPurchased) AS total_qty
	FROM sales_transactions
    GROUP BY CustomerID
),
rfm_base AS (
	SELECT 
		CustomerID,
        DATEDIFF('2023-07-28', MAX(TransactionDate)) AS recency_days,
        COUNT(DISTINCT TransactionID) AS frequency,
        ROUND(SUM(QuantityPurchased * Price), 2) AS monetary
	FROM sales_transactions 
    GROUP BY CustomerID
),
rfm_scored AS (
	SELECT
		CustomerID,
		NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
	FROM rfm_base
)
SELECT 
	cp.CustomerID,
    cp.Age,
    cp.Gender,
    cp.Location,
    COALESCE(ct.total_qty, 0) AS total_qty_purchased,
    CASE
		WHEN COALESCE(ct.total_qty, 0) = 0 THEN 'No Orders'
        WHEN COALESCE(ct.total_qty, 0) <= 10 THEN 'Low'
        WHEN COALESCE(ct.total_qty, 0) <= 30 THEN 'Mid'
        ELSE 'High Value'
	END AS customer_segment,
    CASE
		WHEN(rs.r_score + rs.f_score + rs.m_score) >= 13 THEN 'Champions'
        WHEN(rs.r_score + rs.f_score + rs.m_score) >= 10 THEN 'Loyal Customers'
        WHEN(rs.r_score + rs.f_score + rs.m_score) >= 7 THEN 'Potential Loyalists'
        WHEN(rs.r_score + rs.f_score + rs.m_score) >= 4 THEN 'At Risk'
        ELSE 'Lost'
	END AS rfm_segment
FROM customer_profiles cp
LEFT JOIN customer_totals ct
ON cp.CustomerID = ct.CustomerID
LEFT JOIN rfm_scored rs
ON cp.CustomerID = rs.CustomerID
ORDER BY total_qty_purchased DESC;