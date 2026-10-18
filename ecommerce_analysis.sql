-- PROJECT: E-commerce Customer & Product Performance Analysis
-- DATASET: BigQuery Public Data (TheLook E-commerce)
-- AUTHOR: DIMITRIS VASALOS
-- DESCRIPTION: End-to-end SQL analysis covering product category revenues, 
--              cancellation/return losses, and RFM Customer Segmentation.

------------------------------------------------------------
-- PART 1: Product Categories Revenue & Percentage of Total
------------------------------------------------------------

WITH category_revenue AS (
  SELECT product_category AS cat  ,
  ROUND (SUM(CASE WHEN (o.status='Complete' OR o.status='Shipped') THEN o.sale_price END) , 2) AS cat_revenue ,
  FROM `bigquery-public-data.thelook_ecommerce.order_items`  AS o
  LEFT JOIN bigquery-public-data.thelook_ecommerce.inventory_items AS p ON p.product_id=o.product_id
  GROUP BY cat
  ORDER BY ROUND (SUM(CASE WHEN (o.status='Complete' OR o.status='Shipped') THEN o.sale_price END)) DESC )
SELECT   cat, 
  cat_revenue ,
  ROUND((cat_revenue *100.0 ) / ( SELECT SUM(cat_revenue) FROM category_revenue ), 2) AS percentage_of_total_revenue
FROM category_revenue
ORDER BY percentage_of_total_revenue DESC ;

--------------------------------------------------------------------------------
-- PART 2: Revenue Losses (Cancelled & Returned Orders)
--------------------------------------------------------------------------------

WITH canceled_returned_categories AS(
    SELECT 
    p.product_id ,
    p.product_category AS cat,
    o.status,
    o.sale_price
    FROM bigquery-public-data.thelook_ecommerce.order_items AS o
     LEFT JOIN bigquery-public-data.thelook_ecommerce.inventory_items AS p ON p.product_id=o.product_id
     WHERE status='Returned' OR status='Cancelled')
SELECT status ,
 cat ,  
 ROUND (sum(sale_price) , 2) AS lost_income ,

FROM canceled_returned_categories
GROUP BY status , cat
ORDER BY lost_income DESC ;

--------------------------------------------------------------------------------
-- PART 3: RFM Customer Segmentation
-------------------------------------------------------------------------------

WITH rfm_raw AS(
    SELECT user_id , 
      ROUND(SUM(sale_price), 2) as revenue_per_customer ,
      COUNT( DISTINCT order_id) AS frequency ,
      MAX(created_at) AS last_purchase,
      DATE_DIFF(DATE('2026-10-19'), DATE( MAX(created_at)), DAY) AS recency_days
    FROM bigquery-public-data.thelook_ecommerce.order_items
    WHERE status='Shipped' OR status='Complete'
    GROUP BY user_id
    ORDER BY recency_days )


 , rfm_scores AS (
    SELECT
    user_id ,
    revenue_per_customer ,
    frequency,
    recency_days ,

    CASE
    WHEN recency_days <=30 THEN 5
    WHEN recency_days <=60 THEN 4
    WHEN recency_days <=90 THEN 3
    WHEN recency_days <=120 THEN 2
    ELSE 1
    END AS recency_score,
    
    CASE
    WHEN revenue_per_customer >=500 THEN 5
    WHEN revenue_per_customer >=300 THEN 4
    WHEN revenue_per_customer >=150 THEN 3
    WHEN revenue_per_customer >=75  THEN 2
    ELSE 1
    END AS revenue_score ,

    CASE 
    WHEN frequency >= 9 THEN 5
    WHEN frequency >= 7 THEN 4
    WHEN frequency >= 5 THEN 3
    WHEN frequency >= 3 THEN 2
    ELSE 1 
    END AS frequency_score
    FROM rfm_raw
 ) , rfm_cat AS(
  SELECT 
    user_id,
    revenue_per_customer ,
    frequency,
    recency_days ,
    
    CASE
      WHEN recency_score >= 4 AND frequency_score >= 4 AND revenue_score >= 4 THEN 'VIP - Champions'
    WHEN revenue_score >= 4 AND frequency_score <= 3 THEN 'Big Spenders'
    WHEN recency_score >= 3 AND frequency_score >= 3 AND revenue_score >= 3 THEN 'Loyal Customers'
    WHEN recency_score >= 3 AND frequency_score >= 3 AND revenue_score <= 2 THEN 'Low Value Frequent Buyers'
    WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
    WHEN recency_score <= 2 AND frequency_score >= 3 AND revenue_score >= 4 THEN 'At Risk - High Value'
    WHEN recency_score <= 2 AND frequency_score >= 3 AND revenue_score < 4 THEN 'At Risk - Standard'
  WHEN recency_score = 1 AND frequency_score = 1 AND revenue_score = 1 THEN 'Lost Cheap Customers'
    ELSE 'Standard' 
  END AS user_category
  FROM rfm_scores)
 SELECT user_category ,
        COUNT(user_id) AS customers,
        ROUND(SUM(revenue_per_customer), 2) AS revenue_per_category,
FROM rfm_cat
 GROUP BY user_category

