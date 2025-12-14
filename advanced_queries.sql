/*
====================================================================
 SQL PORTFOLIO: ADVANCED BUSINESS ANALYTICS
 Author: [Your Name]
 Description: A showcase of complex SQL patterns used to solve 
 realistic data problems in Finance, HR, and Sales.
====================================================================
*/

/*
--------------------------------------------------------------------
1. MONTHLY REVENUE GROWTH (Financial Analysis)
   Business Goal: Compare this month's revenue to last month's to track growth.
   Concepts: Window Functions (LAG), Date Extraction, CTEs
--------------------------------------------------------------------
*/
WITH MonthlySales AS (
    SELECT 
        EXTRACT(MONTH FROM sale_date) AS month,
        SUM(total_amount) AS revenue
    FROM Sales
    GROUP BY month
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    -- Calculate percentage growth
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) / 
        LAG(revenue) OVER (ORDER BY month) * 100, 2
    ) AS growth_percentage
FROM MonthlySales;


/*
--------------------------------------------------------------------
2. TOP PERFORMING PRODUCTS (Sales Strategy)
   Business Goal: Identify top 5 products by total profit margin.
   Concepts: Multi-table JOIN, Aggregation, Arithmetic Logic
--------------------------------------------------------------------
*/
SELECT 
    c.category_name,
    p.product_name,
    SUM((p.selling_price - p.cost_price) * s.quantity_sold) AS total_profit
FROM
    Sales AS s
    INNER JOIN Products AS p ON s.product_id = p.product_id
    INNER JOIN Categories AS c ON p.category_id = c.category_id
GROUP BY 
    c.category_name, p.product_name
ORDER BY 
    total_profit DESC
LIMIT 5;


/*
--------------------------------------------------------------------
3. CUMULATIVE SPENDING PER CUSTOMER (User Behavior)
   Business Goal: See a running total of how much a customer has spent over time.
   Concepts: Window Functions (SUM OVER), PARTITION BY
--------------------------------------------------------------------
*/
SELECT
    customer_id,
    trans_date,
    amount,
    SUM(amount) OVER(
        PARTITION BY customer_id
        ORDER BY trans_date
    ) AS running_total
FROM
    Transactions;


/*
--------------------------------------------------------------------
4. EMPLOYEE-MANAGER HIERARCHY (HR Operations)
   Business Goal: Map every employee to their direct manager in a single list.
   Concepts: SELF JOIN (Joining a table to itself)
--------------------------------------------------------------------
*/
SELECT
    e.name AS employee_name,
    m.name AS manager_name
FROM
    Employees AS e
    LEFT JOIN Employees AS m ON e.manager_id = m.id
ORDER BY 
    m.name;


/*
--------------------------------------------------------------------
5. REMOVING DUPLICATE DATA (Data Cleaning)
   Business Goal: Identify and remove duplicate email entries, keeping the oldest.
   Concepts: ROW_NUMBER(), CTEs
--------------------------------------------------------------------
*/
WITH RankedEmails AS (
    SELECT
        id,
        email,
        ROW_NUMBER() OVER(
            PARTITION BY email
            ORDER BY id ASC
        ) AS rn
    FROM
        Person
)
-- In a real scenario, this would be a DELETE statement using the CTE
SELECT * FROM RankedEmails 
WHERE rn > 1;