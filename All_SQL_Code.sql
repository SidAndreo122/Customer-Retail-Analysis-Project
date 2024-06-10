-- Data Preparation-------------------------------------------------------------------------------

-- Q1: Query used to find the total number of rows in each table --

SELECT
  ( SELECT COUNT(*) FROM `case-study-1-420419.customer_info.Customer_id`) as Count_of_Customerid,
  ( SELECT COUNT(*) FROM `case-study-1-420419.customer_info.Customer_Orders`) as Count_of_Orders,
  ( SELECT COUNT(*) FROM `case-study-1-420419.customer_info.products`) as Count_of_products

-- OR --

--SELECT
--COUNT(*) FROM `case-study-1-420419.customer_info.Customer_id` as Count_of_customerid
--UNION ALL
--SELECT 
--COUNT(*) FROM `case-study-1-420419.customer_info.Customer_Orders` as Count_of_orders
--UNION ALL
--SELECT 
--COUNT(*) FROM `case-study-1-420419.customer_info.products` as Count_of_products

--------------------------------------------------------------------------------------------

-- Q2: Query used to find the total number of customers that have returned their order --
SELECT
COUNT(*) AS Returns
FROM `case-study-1-420419.customer_info.Customer_Orders`
WHERE total_amt < 0 and Qty < 0

-------------------------------------------------------------------------------------------

-- Q3: Query used to find the time range for the transaction table--

SELECT
MIN(tran_date) as Start_tran_date,
MAX(tran_date) as End_tran_date,
DATE_DIFF(MAX(tran_date),MIN(tran_date), DAY) AS diff_days,
DATE_DIFF(MAX(tran_date),MIN(tran_date), MONTH) AS diff_months,
DATE_DIFF(MAX(tran_date), MIN(tran_date), YEAR) AS diff_years,

FROM
`case-study-1-420419.customer_info.Customer_Orders`

--------------------------------------------------------------------------------------------

-- Q4:Query used to find where the product category "DIY" belongs to in the products table--

SELECT
prod_cat AS cat_DIY

FROM
`case-study-1-420419.customer_info.products`

WHERE
prod_subcat = 'DIY'

-------------------------------------------------------------------------------------------

-- Data Analysis --------------------------------------------------------------------------

-- Q5: Do customers prefer online shopping, in-person shopping, or shopping on the phone? --

SELECT
DISTINCT Store_type,
COUNT(Store_type) AS Count_store_type
FROM
`case-study-1-420419.customer_info.Customer_Orders`
GROUP BY
Store_type

-------------------------------------------------------------------------------------------

-- Q6: How many male and female customers are there? --

SELECT
Gender,
COUNT(Gender) as number_of_customers
FROM
`case-study-1-420419.customer_info.Customer_id`
GROUP BY
Gender

-------------------------------------------------------------------------------------------

-- Q7: Which city has the most customers and how many? --
WITH customer_city
AS 
  (SELECT DISTINCT city_code,
  COUNT(customer_Id) as num_of_customers,
  RANK() over (ORDER BY COUNT(customer_Id) desc) as rank_no
  FROM `case-study-1-420419.customer_info.Customer_id`
  GROUP BY city_code)
SELECT 
city_code,
num_of_customers
FROM 
customer_city
WHERE
rank_no = 1

-------------------------------------------------------------------------------------------

-- Q8: How many sub-cats are there under the Book cat? --
SELECT
COUNT(prod_subcat) as subcat_count,
FROM
`case-study-1-420419.customer_info.products`
WHERE
prod_cat = 'Books'

-------------------------------------------------------------------------------------------

-- Q9: What is the most someone has bought in terms of quantity? --
SELECT
MAX(Qty) as max_qty
FROM
`case-study-1-420419.customer_info.Customer_Orders`

-------------------------------------------------------------------------------------------

-- Q10: What is the total revenue from the Electronics and Books categories? --
SELECT 
T1.prod_cat AS categories,
SUM(CAST(total_amt AS numeric)) AS Total_Rev
FROM
`case-study-1-420419.customer_info.products` AS T1
INNER JOIN
`case-study-1-420419.customer_info.Customer_Orders`AS T2 
ON T1.prod_cat_code = T2.prod_cat_code 
AND T1.prod_sub_cat_code = T2.prod_subcat_code
WHERE T1.prod_cat IN ('Books', 'Electronics')
GROUP BY T1.prod_cat

-------------------------------------------------------------------------------------------

-- Q11: How many customers have more than 10 purchases (excluding returns)? --
WITH trans_table
AS 
  (SELECT cust_id,COUNT(transaction_id) as num_of_trans
  FROM
  `case-study-1-420419.customer_info.Customer_Orders`
  WHERE total_amt > 0
  GROUP BY cust_id)
SELECT *
FROM
trans_table
WHERE
trans_table.num_of_trans > 10

-------------------------------------------------------------------------------------------

-- Q12: What is the total revenue of the Electronics AND Clothing categories from only the Flagship Stores? --
SELECT 
T1.prod_cat AS categories,
SUM(CAST(total_amt AS numeric)) AS Total_Rev
FROM
`case-study-1-420419.customer_info.products` AS T1
INNER JOIN
`case-study-1-420419.customer_info.Customer_Orders`AS T2 
ON T1.prod_cat_code = T2.prod_cat_code 
AND T1.prod_sub_cat_code = T2.prod_subcat_code
WHERE T1.prod_cat IN ('Clothing', 'Electronics') AND 
T2.Store_type= 'Flagship store'
GROUP BY T1.prod_cat

-------------------------------------------------------------------------------------------

-- Q13: What is the total revenue from male customers in the electronics category? --

SELECT
T3.prod_subcat,
ROUND(SUM(CAST(T1.total_amt AS FLOAT64)), 2) AS total_revenue,
FROM
`case-study-1-420419.customer_info.Customer_Orders` as T1

INNER JOIN
`case-study-1-420419.customer_info.Customer_id` as T2
ON
T1.cust_id = T2.customer_Id
INNER JOIN
`case-study-1-420419.customer_info.products` as T3
ON
T1.prod_cat_code = T3.prod_cat_code AND 
T1.prod_subcat_code = T3.prod_sub_cat_code
WHERE Gender = 'M' AND T3.prod_cat = 'Electronics'
GROUP BY T3.prod_subcat
ORDER BY ROUND(SUM(CAST(T1.total_amt AS FLOAT64)), 2) DESC

-------------------------------------------------------------------------------------------

-- Q14: What is the percentage of sales and returns by prod_subcat (display the top 5)? --
SELECT
T2.prod_subcat AS Subcategory,
ROUND(SUM(CAST( CASE WHEN T1.Qty > 0 THEN T1.Qty ELSE 0 END AS FLOAT64)),2) AS Sales,
ROUND(SUM(CAST( CASE WHEN T1.Qty < 0 THEN T1.Qty ELSE 0 END AS FLOAT64)),2) AS _Returns,
ROUND(SUM(CAST( CASE WHEN T1.Qty > 0 THEN T1.Qty ELSE 0 END AS FLOAT64)),2) - ROUND(SUM(CAST( CASE WHEN T1.Qty < 0 THEN T1.Qty ELSE 0 END AS FLOAT64)),2) AS total_qty,
((ROUND(SUM(CAST( CASE WHEN T1.Qty < 0 THEN T1.Qty ELSE 0 END AS FLOAT64)),2)/ROUND(SUM(CAST( CASE WHEN T1.Qty > 0 THEN T1.Qty ELSE 0 END AS FLOAT64)),2) - ROUND(SUM(CAST( CASE WHEN T1.Qty < 0 THEN T1.Qty ELSE 0 END AS FLOAT64)),2))) / 100  AS Percent_Returns,
((ROUND(SUM(CAST( CASE WHEN T1.Qty > 0 THEN T1.Qty ELSE 0 END AS FLOAT64)),2)/ROUND(SUM(CAST( CASE WHEN T1.Qty > 0 THEN T1.Qty ELSE 0 END AS FLOAT64)),2) - ROUND(SUM(CAST( CASE WHEN T1.Qty < 0 THEN T1.Qty ELSE 0 END AS FLOAT64)),2))) / 100 AS Percent_Sales 
FROM
  `case-study-1-420419.customer_info.Customer_Orders` As T1
INNER JOIN
  `case-study-1-420419.customer_info.products` As T2
ON
  T1.prod_subcat_code = T2.prod_sub_cat_code
GROUP BY
T2.prod_subcat
ORDER BY
Percent_Sales DESC
LIMIT 5;

-------------------------------------------------------------------------------------------

-- Q15: What is the net total revenue for customers aged between 25-35 years old in the last 30 days of transactions? --
#LegacySQL -- changes to regular sql syntax
SELECT 
T2.prod_cat,
SUM(CAST(total_amt AS FLOAT64)) AS max_return_value
FROM
`case-study-1-420419.customer_info.Customer_Orders` AS T1
INNER JOIN 
`case-study-1-420419.customer_info.products` AS T2
ON 
T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code = T2.prod_sub_cat_code 
WHERE
CAST(total_amt AS FLOAT64) < 0 AND T1.tran_date >= DATE_ADD(CAST('2004-02-24' AS DATE), INTERVAL -90 DAY)
GROUP BY
T2.prod_cat
ORDER BY
SUM(CAST(total_amt AS FLOAT64))

-------------------------------------------------------------------------------------------

-- Q16: Which store_type sells the most products (by sales amount and by quantity sold)? --
SELECT
Store_type,
MAX(total_amt) as max_total_amount,
MAX(Qty) as max_quantity
FROM
`case-study-1-420419.customer_info.Customer_Orders`
GROUP BY
Store_type
ORDER BY
MAX(total_amt) DESC, MAX(Qty) DESC

-------------------------------------------------------------------------------------------

-- Q17: What are the categories for which average revenue is more than overall average? --
WITH cat_avg_table AS
  (SELECT 
  prod_cat_code,
  AVG(total_amt) as avg_revenue_by_category
  FROM 
  `case-study-1-420419.customer_info.Customer_Orders`
  GROUP BY
  prod_cat_code
  )
-- for some reason another with statement does not work here --
SELECT *
FROM 
cat_avg_table
WHERE avg_revenue_by_category > (SELECT AVG(total_amt) FROM `case-study-1-420419.customer_info.Customer_Orders`)

-------------------------------------------------------------------------------------------

-- Finally Q18: What is the average and the total revenue by each subcategory for the categories that are the top 5 categories in terms of quantity sold? --

WITH top_cate_by_qty AS
  (SELECT
  prod_cat_code,
  prod_subcat_code,
  SUM(qty) as total_qty
  FROM
  `case-study-1-420419.customer_info.Customer_Orders`
  GROUP BY
  prod_cat_code,
  prod_subcat_code
  ORDER BY
  total_qty DESC
  LIMIT 5)
SELECT
WITH1.prod_subcat_code,
T1.prod_cat_code,
SUM(T1.total_amt) as Total_revenue,
AVG(T1.total_amt) AS Average_revenue
FROM
`case-study-1-420419.customer_info.Customer_Orders` AS T1
RIGHT JOIN
top_cate_by_qty AS WITH1
ON
T1.prod_cat_code = WITH1.prod_cat_code
GROUP BY
WITH1.prod_subcat_code,
T1.prod_cat_code

-- END OF SQL QUERIES -----------------------------------------------------------------
