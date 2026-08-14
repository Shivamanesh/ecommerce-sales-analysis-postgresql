# E-commerce Sales Analysis with PostgreSQL

## Project Overview

This project analyzes an e-commerce sales dataset using PostgreSQL.

The goal is to explore sales performance, customer behavior, product category performance, regional performance, and revenue trends using SQL.

## Dataset

The dataset contains 5,000 e-commerce transactions with information including:

- Order date
- Customer ID
- Product category
- Region
- Quantity
- Unit price
- Discount
- Payment method
- Delivery days
- Customer rating
- Revenue

## Tools

- PostgreSQL
- pgAdmin
- SQL
- VS Code

## Business Questions

The analysis answers business questions related to:

- Which product categories generate the most revenue?
- How does revenue change over time?
- How does monthly revenue compare with the previous month?
- Which customers generate the highest revenue?
- Which customers generate the most revenue within each region?
- How much does each customer contribute to regional revenue?
- Which customers are above or below the average revenue level?
- How does revenue vary across product categories and regions?
- How does customer revenue change over time?

## SQL Skills Demonstrated

- `SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`
- Aggregate functions such as `SUM()`, `AVG()`, and `COUNT()`
- CTEs (`WITH`)
- Subqueries
- Window functions
- `RANK()` and `ROW_NUMBER()`
- `PARTITION BY`
- `LAG()` and `LEAD()`
- Conditional logic with `CASE`
- Monthly and yearly revenue analysis
- Period-over-period comparisons
- Revenue growth analysis
- Customer and product category analysis
- Regional revenue analysis

## Analysis

The project contains SQL queries covering:

- Revenue performance
- Customer spending
- Product category performance
- Regional performance
- Monthly revenue trends
- Customer rankings
- Revenue contribution
- Month-over-month growth
- Customer revenue changes over time

## Project Structure

```text
ecommerce-sales-analysis-postgresql/
│
├── README.md
│
└── sql/
    ├── analysis_queries.sql
    ├── create_table.sql
    └── ecommerce_sales_analytics_5000.csv