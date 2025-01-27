SELECT * from walmartsales;

-- Query 1: Identifying the Top Branch by Sales Growth Rate

-- Step 1: Convert Date to Year-Month format and calculate monthly sales
WITH monthly_sales AS (
    SELECT 
        Branch,
        DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m') AS Month, -- Convert Date format if necessary
        SUM(Total) AS MonthlySales
    FROM walmartsales
    GROUP BY Branch, Month
)

-- Step 2: Calculate growth rate using LAG to find the previous month's sales
SELECT 
    Branch,
    Month,
    MonthlySales,
    ROUND(
        (MonthlySales - LAG(MonthlySales) OVER(PARTITION BY Branch ORDER BY Month)) /
        LAG(MonthlySales) OVER(PARTITION BY Branch ORDER BY Month),
        4
    ) AS GrowthRate
FROM monthly_sales
ORDER BY Branch, Month;

-- Query 2: Finding the Most Profitable Product Line for Each Branch
DESCRIBE walmartsales;

SELECT 
    Branch,
    `Product Line`,  -- Correctly quoted column name
    SUM(`gross income` - `cogs`) AS Profit  -- Correctly quoted column name
FROM walmartsales
GROUP BY Branch, `Product Line`  -- Correctly quoted column name
ORDER BY Branch, Profit DESC;

-- To Find the Maximum Profit Per Branch:

WITH ProfitData AS (
    SELECT 
        Branch,
        `Product Line`,  -- Correctly quoted column name
        SUM(`gross income` - `cogs`) AS Profit  -- Correctly quoted column name
    FROM walmartsales
    GROUP BY Branch, `Product Line`  -- Correctly quoted column name
)
SELECT 
    Branch,
    `Product Line`,  -- Correctly quoted column name
    Profit
FROM ProfitData
WHERE (Branch, Profit) IN (
    SELECT 
        Branch,
        MAX(Profit)
    FROM ProfitData
    GROUP BY Branch
);

-- Query  3: Analyzing Customer Segmentation Based on Spending

WITH customer_spending AS (
    SELECT 
        `Customer ID`,  -- Correctly quoted column name
        SUM(Total) AS TotalSpending
    FROM walmartsales
    GROUP BY `Customer ID`  -- Correctly quoted column name
)
SELECT 
    `Customer ID`,  -- Correctly quoted column name
    TotalSpending,
    CASE 
        WHEN TotalSpending >= 1000 THEN 'High'  -- Replace 1000 with your actual high threshold
        WHEN TotalSpending >= 500 THEN 'Medium'  -- Replace 500 with your actual medium threshold
        ELSE 'Low'
    END AS SpendingSegment
FROM customer_spending;

-- Query  4: Detecting Anomalies in Sales Transactions

WITH product_stats AS (
    SELECT 
        `Product Line`,  -- Ensure to use backticks if there's a space in the column name
        AVG(Total) AS AvgSales,
        STDDEV(Total) AS StdDevSales
    FROM walmartsales  -- Using the correct dataset
    GROUP BY `Product Line`  -- Ensure to use backticks if there's a space in the column name
)
SELECT 
    ws.*,  -- Select all columns from walmartsales
    ps.AvgSales,
    ps.StdDevSales
FROM walmartsales ws
JOIN product_stats ps ON ws.`Product Line` = ps.`Product Line`  -- Ensure to use backticks if there's a space in the column name
WHERE ABS(ws.Total - ps.AvgSales) > 2 * ps.StdDevSales;  -- Identify outliers

-- Query 5: Most Popular Payment Method by City
SELECT 
    City,
    Payment,
    COUNT(*) AS PaymentCount
FROM walmartsales
GROUP BY City, Payment
ORDER BY City, PaymentCount DESC;


-- Query 6: Monthly Sales Distribution by Gender

SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS Month,
    Gender,
    SUM(Total) AS MonthlySales
FROM walmartsales
GROUP BY Month, Gender;


-- Query 7: Best Product Line by Customer Type

SELECT 
    'Customer type',
    'Product line',
    COUNT(*) AS ProductLineCount
FROM walmartsales
GROUP BY 'Customer type', 'Product line'
ORDER BY 'Customer type', ProductLineCount DESC;


-- Query 8: Identifying Repeat Customers

SELECT 
    a.`Customer ID`,  
    a.`Date` AS PurchaseDate, 
    b.`Date` AS NextPurchaseDate,
    DATEDIFF(STR_TO_DATE(b.`Date`, '%d-%m-%Y'), STR_TO_DATE(a.`Date`, '%d-%m-%Y')) AS DaysDifference
FROM walmartsales a 
JOIN walmartsales b 
    ON a.`Customer ID` = b.`Customer ID` 
    AND STR_TO_DATE(a.`Date`, '%d-%m-%Y') < STR_TO_DATE(b.`Date`, '%d-%m-%Y')
WHERE 
    STR_TO_DATE(a.`Date`, '%d-%m-%Y') BETWEEN '2019-01-01' AND '2019-01-31' AND
    STR_TO_DATE(b.`Date`, '%d-%m-%Y') BETWEEN '2019-01-01' AND '2019-01-31' AND
    DATEDIFF(STR_TO_DATE(b.`Date`, '%d-%m-%Y'), STR_TO_DATE(a.`Date`, '%d-%m-%Y')) <= 30;

-- Query  9: Finding Top 5 Customers by Sales Volume

SELECT 
    `Customer ID` AS CustomerID,  -- Adjust column name to match your format
    SUM(Total) AS TotalSales
FROM walmartsales
GROUP BY `Customer ID`
ORDER BY TotalSales DESC
LIMIT 5;

-- Query 10 Analyzing Sales Trends by Day of the Week

SELECT 
    DAYNAME(STR_TO_DATE(`Date`, '%d-%m-%Y')) AS DayOfWeek,  -- Adjusted for dd-mm-yyyy format
    SUM(Total) AS Sales
FROM walmartsales
GROUP BY DayOfWeek
ORDER BY Sales DESC;








