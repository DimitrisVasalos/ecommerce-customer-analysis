# E-commerce Data & Customer Segmentation Project

# Project Overview
This project is an end-to-end data analysis of a simulated e-commerce platform (`TheLook` dataset via Google BigQuery). The goal was to extract actionable business insights regarding product performance, financial losses from order cancellations/returns, and customer value through behavioral segmentation.

---

# Key Business Questions Answered
1. **Product Performance:** Which product categories generate the highest revenue?
2. **Financial Losses:** Where is the business losing money due to cancelled or returned items?
3. **Customer Segmentation:** Who are our most valuable customers, and where do we face high churn risks?

---

# Tech Stack & Skills Demonstrated
* **Database & Query Language:** Google BigQuery, Standard SQL
* **Advanced SQL Techniques:** CTEs (Common Table Expressions), Conditional Aggregation (`CASE WHEN`), Window/Grouping Functions.
* **Analytical Frameworks:** RFM (Recency, Frequency, Monetary) Customer Segmentation.

---

# Key Findings & Insights
* **Revenue Drivers:** A small fraction of product categories drive the majority of total store revenue.
* **Operational Losses:** Cancellations and returns heavily impact specific categories, highlighting supply chain or quality control bottlenecks.
* **RFM Customer Segmentation:** 
  * Identified core **Big Spenders** (high-value customers driving significant revenue).
  * Detected a high number of **Lost Cheap Customers** (churned users who made single low-value purchases in the past), pointing to a clear target area for re-engagement campaigns.

---

# Code Structure
You can find the complete, documented SQL script in this repository:
* `ecommerce_analysis.sql`: Contains the full queries for category revenue, loss analysis, and the RFM model.

