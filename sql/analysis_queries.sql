-- Ecommerce Sales Analysis
-- Business questions and SQL queries

-- Q1: Total revenue generated
SELECT SUM(revenue) AS total_revenue FROM ecommerce_sales;

-- Q2: Total number of orders
SELECT COUNT(*) AS total_orders FROM ecommerce_sales;

-- Q3: The average order value
SELECT AVG(revenue) AS average_order_value FROM ecommerce_sales;

-- Q4: Revenue of each product category
SELECT product_category, SUM(revenue) AS total_revenue FROM ecommerce_sales
GROUP BY product_category
ORDER BY total_revenue DESC;

-- Q5: Revenue based on regions
SELECT region, SUM(revenue) AS region_revenue FROM ecommerce_sales
GROUP BY region
ORDER BY region_revenue DESC;

-- Q6: revenue based on payment method
SELECT payment_method, SUM(revenue) AS total_revenue FROM ecommerce_sales
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Q7: Which Category has the highest average customer rating?
SELECT product_category, ROUND(AVG(customer_rating),2) AS avg_customer_rating FROM ecommerce_sales
GROUP BY product_category
ORDER BY avg_customer_rating DESC;

-- Q8: Which product category has the highest average order value?
SELECT product_category, ROUND(AVG(revenue),2) AS average_order_value FROM ecommerce_sales
GROUP BY product_category
ORDER BY average_ordeß_value DESC;

-- 09: Which region has the highest average customer rating?
SELECT region, ROUND(AVG(customer_rating), 2) FROM ecommerce_sales
GROUP BY region
ORDER BY ROUND(AVG(customer_rating), 2);

-- Q10: Which product category has the highest number of orders?
SELECT product_category, COUNT(*) AS number_of_orders FROM ecommerce_sales
GROUP BY product_category
ORDER BY number_of_orders DESC;

-- Q11: Which payment method is used most frequently?
SELECT payment_method, COUNT(*) AS frequency FROM ecommerce_sales
GROUP BY payment_method
ORDER BY frequency DESC;

--Q12: Which month generated the highest total revenue?
SELECT EXTRACT(YEAR FROM order_date) AS year,
       EXTRACT(MONTH FROM order_date) AS month,
       SUM(revenue) AS monthly_revenue FROM ecommerce_sales
GROUP BY year, month
ORDER BY monthly_revenue;

--Q13: Which month had the highetst number of orders?
SELECT EXTRACT(YEAR FROM order_date) AS year,
       EXTRACT(MONTH FROM order_date) AS month,
       COUNT(*) AS num_of_orders_per_month
FROM ecommerce_sales
GROUP BY year, month
ORDER BY num_of_orders_per_month DESC;

--Q14: Which year and month had the highest average customer rating?
SELECT EXTRACT(YEAR FROM order_date) AS year,
       EXTRACT(MONTH FROM order_date) AS month,
       ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM ecommerce_sales
GROUP BY year, month
ORDER BY avg_customer_rating;

--Q15: Which product category has the highest average discount?
SELECT product_category,
       ROUND(AVG(discount), 2) AS avg_discount
FROM ecommerce_sales
GROUP BY product_category
ORDER BY avg_discount DESC;

--Q16: Which product category generates the highest revenue per unit sold?
SELECT product_category,
       ROUND(SUM(revenue)/ SUM(quantity), 2) AS revenue_per_unit
FROM ecommerce_sales
GROUP BY product_category
ORDER BY revenue_per_unit DESC;

--Q17: Which region has the highest average delivery time?
SELECT region, ROUND(AVG(delivery_days),2) AS avg_delivery FROM ecommerce_sales
GROUP BY region
ORDER BY avg_delivery DESC;

--Q18: oes faster delivery correlate with higher customer ratings?
SELECT
    ROUND(CAST(CORR(delivery_days, customer_rating) AS NUMERIC), 3) AS delivery_rating_corr
FROM ecommerce_sales;

--Q19: Which product category has the highest total quantity sold?
SELECT product_category, SUM(quantity) FROM ecommerce_sales
GROUP BY product_category
ORDER BY SUM(quantity) DESC;

--Q20: Which product category has the highest average unit price?
SELECT product_category, ROUND(AVG(unit_price), 2) FROM ecommerce_sales
GROUP BY product_category
ORDER BY ROUND(AVG(unit_price), 2) DESC;

--Q21: For each region, what is the revenue rank of each product category within that region?
SELECT
    region,
    product_category,
    SUM(revenue) AS total_revenue,
    RANK() OVER(PARTITION BY region ORDER BY SUM(revenue) DESC) AS revenue_rank
FROM ecommerce_sales
GROUP BY region, product_category
ORDER BY region, revenue_rank;

--Q22: For each region, which product category generated the highest revenue?
WITH rank_categories AS(
    SELECT
        region,
        product_category,
        SUM(revenue) AS total_revenue,
        RANK() OVER(PARTITION BY region ORDER BY SUM(revenue)) AS ranking
    FROM ecommerce_sales
    GROUP BY region, product_category
    ORDER BY region, ranking DESC)
SELECT region, product_category, total_revenue
FROM rank_categories
WHERE ranking = 1
ORDER BY region;

--Q23: For each region, what percentage of the region's total revenue comes from each product category?
WITH region_revenue AS(
    SELECT
        region,
        product_category,
        SUM(revenue) AS total_product_category_revenue,
        SUM(SUM(revenue)) OVER (PARTITION BY region) AS total_region_revenue
    FROM ecommerce_sales
    GROUP BY region, product_category
)
SELECT
    region,
    product_category,
    total_product_category_revenue,
    total_region_revenue,
    CAST(ROUND(((total_product_category_revenue/total_region_revenue) * 100), 2) AS text) || '%'  AS percentage
    FROM region_revenue
    --No need for this:
    --GROUP BY region, product_category, total_product_category_revenue, total_region_revenue
    --Bcs, there is no aggregate function in this SELECT
    ORDER BY percentage;

--Q24: For each year and month, what was the total revenue and how did it compare with the previous month?
WITH revenue_calculation AS(
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(MONTH FROM order_date) AS month,
        TO_CHAR(order_date, 'Month') AS month_name,
        SUM(revenue) AS monthly_revenue
    FROM ecommerce_sales
    GROUP BY year, month, month_name
    ORDER BY year, month
)
SELECT
    year,
    month,
    month_name,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY year, month) AS previous_month_revenue
FROM revenue_calculation
ORDER BY year, month;

--Q25: For each product category, calculate its total revenue and its percentage contribution to the overall revenue.
WITH revenue_calculaion AS(
    SELECT
        product_category,
        SUM(revenue) AS category_revenue
    FROM ecommerce_sales
    GROUP BY product_category
),
contribution_to_overall_revenue AS(
    SELECT
        product_category,
        category_revenue,
        SUM(category_revenue) OVER () AS total_revenue,
        CAST(ROUND(((category_revenue/ SUM(category_revenue) OVER ()) * 100), 2) AS TEXT) || '% 'AS contribution
    FROM revenue_calculaion
)
SELECT
    product_category,
    category_revenue,
    total_revenue,
    contribution
FROM contribution_to_overall_revenue;

--Q26: For each customer, calculate their total number of orders, total revenue, and average order value. Then rank customers by total revenue.
WITH customer_revenue AS(
    SELECT
    customer_id,
    COUNT(*) AS num_of_orders,
    SUM(revenue) AS customer_total_revenue,
    ROUND((SUM(revenue) / COUNT(*)), 2) AS avg_order_value_per_customer
    FROM ecommerce_sales
    GROUP BY customer_id
),
rank_customers AS(
    SELECT
        customer_id,
		num_of_orders,
		avg_order_value_per_customer,
        customer_total_revenue,
        RANK() OVER (ORDER BY customer_total_revenue) AS rank_customers_by_total_value
    FROM customer_revenue
)
SELECT
    customer_id,
    num_of_orders,
    customer_total_revenue,
    avg_order_value_per_customer,
    rank_customers_by_total_value
FROM rank_customers;

--Q27: Which customers have placed more orders than the average number of orders per customer?
WITH customer_orders AS(
    SELECT
        customer_id,
        COUNT(*) AS total_num_of_orders
    FROM ecommerce_sales
    GROUP BY customer_id
),
avg_orders AS(
    SELECT
        ROUND(AVG(total_num_of_orders), 2) AS avg_num_of_orders
    FROM customer_orders
)
SELECT
    customer_id,
    total_num_of_orders
FROM customer_orders
WHERE total_num_of_orders > (
        SELECT avg_num_of_orders
        FROM avg_orders
        )
ORDER BY customer_id;

--Q28: For each product category, identify the top 2 customers by total revenue within that category.
WITH rev_per_categ AS (
    SELECT   
        customer_id,
        product_category,
        SUM(revenue) AS customer_revenue_per_category
    FROM ecommerce_sales
    GROUP BY
        customer_id,
        product_category
),
ranking_customers AS(
    SELECT
        customer_id,
        product_category,
        customer_revenue_per_category,
        RANK() OVER (PARTITION BY product_category
                    ORDER BY customer_revenue_per_category DESC
                    ) AS revenue_ranking
    FROM rev_per_categ
)
SELECT
    customer_id,
    product_category,
    customer_revenue_per_category,
    revenue_ranking
FROM ranking_customers
WHERE revenue_ranking BETWEEN 1 AND 2
ORDER BY product_category, revenue_ranking;

--Q29: For each customer, compare their total revenue with the average total revenue of all customers, and show whether
--their revenue is above or below average.
WITH customer_total_revenue AS (
    SELECT
        customer_id,
        SUM(revenue) AS total_rev_customer
    FROM ecommerce_sales
    GROUP BY customer_id
),
customer_comparison AS (
    SELECT
        customer_id,
        total_rev_customer,
        --need OVER(), to not to destroy the original columns:
        AVG(total_rev_customer) OVER () AS avg_total_revenue
    FROM customer_total_revenue
)
SELECT
    customer_id,
    total_rev_customer,
    avg_total_revenue,
    CASE
        WHEN total_rev_customer > avg_total_revenue THEN 'ABOVE'
        WHEN total_rev_customer < avg_total_revenue THEN 'BELOW'
        ELSE 'EQUAL'
    END AS comparison
FROM customer_comparison
ORDER BY customer_id;

--Q30: For each month, calculate the total revenue and the month-over-month revenue growth percentage compared with
--the previous month.
 WITH monthly_revenue AS(
    SELECT
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(MONTH FROM order_date) AS month,
        SUM(revenue) AS revenue_per_month
    FROM ecommerce_sales
    GROUP BY
        EXTRACT(YEAR FROM order_date),
        EXTRACT(MONTH FROM order_date)
    ORDER BY
        EXTRACT(YEAR FROM order_date),
        EXTRACT(MONTH FROM order_date)
 ),
 previous_month AS(
    SELECT
        year,
        month,
        revenue_per_month,
        LAG(revenue_per_month) OVER (ORDER BY year,month)
         AS previous_month_revenue
    FROM monthly_revenue
 ),
 monthly_growth AS(
    SELECT
        year,
        month,
        revenue_per_month,
        (((revenue_per_month - previous_month_revenue)/ previous_month_revenue) * 100)
            AS monthly_revenue_growth
    FROM previous_month
 )
 SELECT
    year,
    month,
    revenue_per_month,
    ROUND(monthly_revenue_growth, 2) AS monthly_revenue_growth
FROM monthly_growth;

--Q31: For each product category, find the customer who generated the highest revenue and show that customer's revenue 
--along with the average customer revenue within that category.
WITH customer_rev_per_categ AS (
    SELECT   
        customer_id,
        product_category,
        SUM(revenue) AS customer_revenue_per_category
    FROM ecommerce_sales
    GROUP BY
        customer_id,
        product_category
),
highest_customer_revenue AS(
    SELECT
        customer_id,
        product_category,
        customer_revenue_per_category,
        MAX(customer_revenue_per_category) OVER (PARTITION BY product_category) 
                                        AS customer_with_highest_revenue_per_category
    FROM customer_rev_per_categ
),
average_customer_revenue_per_category AS(
    SELECT
        customer_id,
        product_category,
        customer_revenue_per_category,
        customer_with_highest_revenue_per_category,
        AVG(customer_revenue_per_category) OVER (PARTITION BY product_category) AS average_customer_revenue
    FROM highest_customer_revenue
)
SELECT
    customer_id,
    product_category,
    customer_with_highest_revenue_per_category,
    ROUND(average_customer_revenue, 2) AS average_customer_revenue
FROM average_customer_revenue_per_category
WHERE customer_revenue_per_category = customer_with_highest_revenue_per_category
ORDER BY product_category;

--Q32: For each customer, calculate their total revenue and rank them within their region from highest to lowest revenue. 
--Show the customer, region, total revenue, and their regional rank.
WITH total_customer_revenue AS(
    SELECT
        customer_id,
        region,
        SUM(revenue) AS total_revenue
    FROM ecommerce_sales
    GROUP BY customer_id, region 
),
rank_customers_in_region AS(
    SELECT
        customer_id,
        total_revenue,
        region,
        RANK() OVER (
                    PARTITION BY region
                    ORDER BY total_revenue DESC) AS revenue_ranking_per_region
    FROM total_customer_revenue
)
SELECT
    customer_id,
    region,
    total_revenue,
    revenue_ranking_per_region
FROM rank_customers_in_region
ORDER BY region, revenue_ranking_per_region;

--Q33: For each region, find the top 3 customers by total revenue, and show their revenue as well as the percentage of
--that region's total revenue that they contributed.
WITH customer_revenue AS(
    SELECT
        customer_id,
        region,
        SUM(revenue) AS customer_revenue_per_region
    FROM ecommerce_sales
    GROUP BY region, customer_id
),
ranking_customers AS(
    SELECT
        customer_id,
        region,
        customer_revenue_per_region,
        RANK() OVER (PARTITION BY region
                     ORDER BY customer_revenue_per_region DESC)
                     AS ranking_per_region
    FROM customer_revenue
),
contribution_in_region AS(
    SELECT
        customer_id,
        region,
        customer_revenue_per_region,
        ranking_per_region,
        SUM(customer_revenue_per_region) OVER (PARTITION BY region) AS regional_revenue,
        ROUND((customer_revenue_per_region / SUM(customer_revenue_per_region) OVER (PARTITION BY region)) * 100, 2) AS contribution
    FROM ranking_customers
)
SELECT
    customer_id,
    region,
    customer_revenue_per_region,
    regional_revenue,
    CAST (contribution AS TEXT) || '%'
FROM contribution_in_region
WHERE ranking_per_region BETWEEN 1 AND 3;

--Q34: For each product category, calculate its total revenue, the previous month's revenue for that category,
--and the month-over-month revenue growth percentage.
WITH time_extraction AS(
    SELECT
        order_date,
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(MONTH FROM order_date) AS month,
        product_category,
        revenue
    FROM ecommerce_sales
),
monthly_total_revenue_per_category AS(
    SELECT
        year,
        month,
        product_category,
        SUM(revenue) AS monthly_revenue_category
    FROM time_extraction
    GROUP BY year, month, product_category
),
previous_month_revenue AS (
    SELECT
        year,
        month,
        product_category,
        monthly_revenue_category,
        LAG(monthly_revenue_category) 
            OVER(PARTITION BY product_category
            ORDER BY year, month) AS previous_revenue
    FROM monthly_total_revenue_per_category 
),
monthly_growth_percentage AS (
    SELECT
        year,
        month,
        product_category,
        monthly_revenue_category,
        previous_revenue,
        ROUND(((monthly_revenue_category - previous_revenue) / previous_revenue) * 100, 2) AS growth
    FROM previous_month_revenue
)
SELECT
    year,
        month,
        product_category AS category,
        monthly_revenue_category AS revenue,
        previous_revenue AS previous_month,
        growth
    FROM monthly_growth_percentage;

    --Q35: For each customer, calculate their total revenue, their previous order's revenue, and the percentage change
    --in revenue compared with their previous order.
    WITH previous_month_revenue AS (
        SELECT
            customer_id,
            order_date,
            revenue,
            LAG(revenue) OVER (PARTITION BY customer_id 
                ORDER BY order_date) AS previous_revenue
        FROM ecommerce_sales                                   
    ),
    percentage_change AS (
        SELECT
            customer_id,
            order_date,
            revenue,
            previous_revenue,
            ROUND((((revenue- previous_revenue)/previous_revenue)* 100), 2) AS change
        FROM previous_month_revenue
    )
    SELECT
        customer_id,
        order_date,
        revenue,
        previous_revenue,
        CAST(change AS TEXT) || '%' AS change
    FROM percentage_change
    ORDER BY customer_id, order_date;

    --Q36: For each product category, find the month with the highest revenue and show the category, year, month,
    --and revenue for that month.
    WITH monthly_revenue AS (
        SELECT
            EXTRACT(YEAR FROM order_date) AS year,
            EXTRACT(MONTH FROM order_date) AS month,
            product_category,
            SUM(revenue) AS monthly_revenue
        FROM ecommerce_sales
        GROUP BY product_category, EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
    ),
    highest_monthly_revenue AS (
    SELECT
        product_category,
        year,
        month,
        monthly_revenue,
        MAX(monthly_revenue) OVER (
            PARTITION BY product_category
        ) AS highest_revenue
    FROM monthly_revenue
)
SELECT
    year,
    month,
    product_category,
    monthly_revenue
FROM highest_monthly_revenue
WHERE monthly_revenue = highest_revenue
ORDER BY product_category;