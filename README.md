# Retail Analytics Case Study: Optimizing Sales, Inventory, and Customer Retention

## 📌 Project Overview
In the rapidly evolving retail sector, leveraging data analytics has become a cornerstone for achieving competitive advantages, improving customer satisfaction, and optimizing operational efficiency. This case study focuses on a retail company experiencing stagnant growth and declining customer engagement metrics over past quarters. 

Using **MySQL 8.0+**, this project executes an end-to-end data pipeline—encompassing database schema creation, data cleaning, exploratory data analysis (EDA), and advanced customer value modeling (RFM)—to deliver actionable insights for cross-functional business teams.

---

## 📊 Business Problems Addressed
1. **Product Performance Variability:** Identifying high- and low-performing products to optimize stock levels and warehouse holding costs.
2. **Customer Segmentation:** Classifying the customer base based on purchasing volume to enable targeted marketing.
3. **Customer Behavior Analysis:** Evaluating purchasing patterns, recency, and repeat-purchase loyalty indicators to mitigate churn risks.

---

## 🛠️ Tech Stack & SQL Concepts Used
* **Database Management System:** MySQL 8.0+
* **Advanced SQL Techniques:** Common Table Expressions (CTEs), Window Functions (`NTILE`, `OVER`), Data Aggregations (`SUM`, `COUNT DISTINCT`, `AVG`), Conditional Logic (`CASE WHEN`), Date Formatting (`DATE_FORMAT`, `DATEDIFF`), Table Joins (`LEFT JOIN`, `INNER JOIN`), and Referential Integrity constraints.

---

## 🗄️ Database Architecture & Schema
The project structures and joins three distinct primary relational datasets:
* **`customer_profiles`**: 1,000 records containing demographic variables (Age, Gender, Location, Join Date).
* **`product_inventory`**: 200 records detailing catalog metadata (Product Name, Category, Stock Level, Price).
* **`sales_transactions`**: 5,002 historical entries mapping transaction behaviors (Transaction ID, Customer ID, Product ID, Quantity Purchased, Transaction Date, Price).

---

## 📊 Executive Summary & Project Outcomes

Through programmatic auditing of the data ecosystem, this analysis uncovered structural operational bottlenecks and quantified key high-value growth segments:

### 📦 1. Inventory Stock Health & Product Performance (Objective 2)
* **The Problem:** Revenue concentration and product velocity mismatches leading to major warehouse capital allocation inefficiencies.
* **The Metrics:**
  * **65.0% of inventory items (130 products)** are classified as **Overstock**, tracking well above safe historical consumption thresholds and trapping cash flow.
  * **34.5% of products (69 items)** are successfully maintained at a **Healthy** stock-to-sales velocity.
  * **0.5% (1 product)** was flagged as **Out of Stock**, causing immediate missed revenue opportunities.
* **Business Deliverable:** Generated a live inventory matrix mapping running product revenues and supply-chain safety flags.
* **🔗 Data File:** [View Product Stock Health Report](./data_outputs/product_inventory_stock_health.csv)

### 👥 2. Purchase Volume Segmentation (Objective 3)
* **The Problem:** Lack of structural segmentation hiding clear definition around user purchasing distribution.
* **The Metrics:**
  * **55.9% (559 customers)** form the fundamental core of the business as **Mid-Volume Tiers** (11–30 units purchased).
  * **42.3% (423 customers)** compose the **Low-Volume Tier** (1–10 units purchased).
  * **0.7% (7 customers)** represent an elite, disproportionately high-yield **High-Value Tier** (purchasing >30 units total).
  * **1.1% (11 customers)** are registered with **No Orders**, indicating a gap in onboarding conversion.
* **Business Deliverable:** Extracted targeted audience sheets mapped directly to structural purchasing thresholds.
* **🔗 Data File:** [View Customer Volume Segmentation](./data_outputs/customer_volume_segmentation.csv)

### 🎯 3. 3D RFM Framework & Churn Tracking (Objective 4)
* **The Problem:** Unquantified customer lifecycle stages and hidden churn velocity risks.
* **The Metrics:**
  * **50.8% of the buyer base (502 customers)** are currently **Active** having bought within the trailing 30 days.
  * **37.3% (369 customers)** are slipping into the **At Risk** window (31–90 days since last purchase), signaling a vital point for immediate automated re-engagement workflows.
  * Advanced **RFM (Recency, Frequency, Monetary)** behavioral clustering mapped the entire customer base into clear actionable tiers: **28.1% Loyal Customers**, **24.2% Potential Loyalists**, **21.5% At-Risk Users**, **18.4% Champions**, and **7.8% Lost Users**.
* **Business Deliverable:** Provided the retention marketing team with pre-scored RFM tracking cohorts to launch precise re-engagement campaigns.
* **🔗 Data Files:** [View Recency Churn Analysis](./data_outputs/customer_recency_churn_analysis.csv) | [View Ultimate RFM Matrix](./data_outputs/ultimate_customer_rfm_matrix.csv)

---

## 📁 Repository Directory Structure
```text
📁 Retail-Analytics
 ├── 📁 sql_scripts
 │    └── Retail_Analystics_Project.sql       # Structured SQL file containing setup, cleaning, and objectives
 └── 📁 data_outputs
      ├── customer_volume_segmentation.csv   # Row-by-row customer volume classifications
      ├── product-inventory_stock_health.csv # Catalog stock health and sales velocity rankings
      ├── customer_recency_churn_analysis.csv# Lifecycle tracking segments
      └── ultimate_customer_rfm_matrix.csv   # Combined demographic and 3D RFM loyalty matrix
