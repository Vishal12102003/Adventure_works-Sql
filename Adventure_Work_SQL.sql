create database Project;

show databases;

CREATE TABLE DimCustomer (
    CustomerKey INT,
    GeographyKey INT,
    CustomerAlternateKey VARCHAR(50),
    Title VARCHAR(10),
    FirstName VARCHAR(50),
    MiddleName VARCHAR(50),
    LastName VARCHAR(50)
);

drop  table DimCustomer;


drop table union_factinternetsales;

use project;

select * from dimdate;

select * from dimcustomer;

select * from union_sales;

select * from dimproduct;

-- 1 productname in sales sheet.

select sales.productkey,
dimproduct.englishproductname
from dimproduct
join  sales
on dimproduct.productkey = sales.productkey;

-- 2)

SELECT 
    c.CustomerKey,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,
    SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountpct)) AS TotalSales
FROM Sales s
JOIN dimcustomer c ON s.CustomerKey = c.CustomerKey
GROUP BY c.CustomerKey, CustomerFullName
ORDER BY TotalSales;


-- (3) Date Queries

SELECT 
    OrderDateKey,
    STR_TO_DATE(OrderDateKey, '%Y%m%d') AS OrderDate
FROM Sales;

-- 3a Year

SELECT 
    OrderDateKey,
    STR_TO_DATE(OrderDateKey, '%Y%m%d') AS OrderDate,
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS OrderYear
FROM sales;


-- b) MonthNumber

SELECT 
    OrderDateKey,
    STR_TO_DATE(OrderDateKey, '%Y%m%d') AS OrderDate,
    month(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MonthNumber
FROM sales;


-- c) Monthh Full name

SELECT 
    OrderDateKey,
    STR_TO_DATE(OrderDateKey, '%Y%m%d') AS OrderDate,
    monthname(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MonthFullName
FROM sales;


--    D.Year Month

SELECT 
    OrderDateKey,
    STR_TO_DATE(OrderDateKey, '%Y%m%d') AS OrderDate,
    DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%Y-%b') AS YearMonth
FROM Sales;

-- Quarter, Weekdaynumber, weekdayname

SELECT 
    OrderDateKey,
    STR_TO_DATE(OrderDateKey, '%Y%m%d') AS OrderDate,
      YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS OrderYear,
        month(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MonthNumber,
    monthname(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MonthFullName,
    concat("Q",quarter(STR_TO_DATE(OrderDateKey, '%Y%m%d')))as Quarter,
     weekday(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS WeekDayNumber,
       dayname(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS WeekDayName,
       STR_TO_DATE(OrderDateKey, '%Y%m%d') AS OrderDate,
    DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%Y-%b') AS YearMonth
FROM sales;


-- Financial Month

SELECT 
    orderdatekey,
    CASE 
        WHEN MONTH(orderdatekey) >= 4 THEN MONTH(orderdatekey) - 3
        ELSE MONTH(orderdatekey) + 9
    END AS financial_month
FROM sales;

-- Financial Quarter

SELECT 
    orderdatekey,
    CASE 
        WHEN MONTH(orderdatekey) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(orderdatekey) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(orderdatekey) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END AS financial_quarter
from Sales;

select * from union_sales;

-- 4 Sales Amount

SELECT 
    SalesOrderNumber,
    ProductKey,
    UnitPrice,
    OrderQuantity,
    UnitpriceDiscountpct,
    (UnitpriceDiscountpct * OrderQuantity) AS GrossSales,
        (UnitPrice * OrderQuantity * UnitpriceDiscountpct) AS DiscountAmount,
    (UnitPrice * OrderQuantity) - (UnitPrice * OrderQuantity * UnitpriceDiscountpct) AS SalesAmount
FROM Sales;


-- 5 product cost

SELECT 
    SalesOrderNumber,
    ProductKey,
    OrderQuantity,
    (ProductStandardcost/OrderQuantity * OrderQuantity) AS ProductionCost
FROM Sales;


-- 6 profit

SELECT 
    SalesOrderNumber,
    ProductKey,
    UnitPrice,
    OrderQuantity,
    ProductStandardcost,
    (UnitPrice * OrderQuantity) - (UnitPrice * OrderQuantity * UnitpriceDiscountpct) - (ProductStandardcost/OrderQuantity * OrderQuantity) AS Profit
FROM Sales;

-- 7) Sales according to Month and year

SELECT 
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS OrderYear,
    MONTHNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS OrderMonth,
    SUM(UnitPrice * OrderQuantity * (1 - UnitpriceDiscountpct)) AS TotalSales
FROM Sales
GROUP BY OrderYear, OrderMonth
ORDER BY OrderYear, MONTHname(STR_TO_DATE(OrderDateKey, '%Y%m%d'));


#this is more optimized than the above
SELECT 
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS OrderYear,
    MONTHNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS OrderMonth,
    SUM(UnitPrice * OrderQuantity * (1 - UnitpriceDiscountpct)) AS TotalSales
FROM Sales
GROUP BY 
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')),
    MONTHname(STR_TO_DATE(OrderDateKey, '%Y%m%d'))
ORDER BY 
    OrderYear, 
    MONTHname(STR_TO_DATE(OrderDateKey, '%Y%m%d'));

SET sql_mode = '';

-- 8) Sales year wise

SELECT 
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS OrderYear,
    SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountpct)) AS TotalSales
FROM Sales
GROUP BY OrderYear
ORDER BY OrderYear;

-- 9) Sales for Year-Month

SELECT 
DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%Y-%m') AS YearMonth,
SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountpct)) AS TotalSales
FROM Sales
GROUP BY YearMonth
ORDER BY YearMonth;

-- 10) Sales Quarter wise
SELECT 
CONCAT('Q', QUARTER(STR_TO_DATE(OrderDateKey, '%Y%m%d'))) AS Quarter,
SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountpct)) AS TotalSales
FROM Sales
GROUP BY Quarter
ORDER BY Quarter;

-- 11)  YearMonth wise Salesamount and Productioncost 

SELECT 
DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%Y-%m') AS YearMonth,
SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountpct)) AS TotalSales,
SUM(ProductStandardcost * OrderQuantity) AS TotalProductionCost
FROM Sales
GROUP BY YearMonth
ORDER BY YearMonth;

-- 12) A) Top 10 selling products)

SELECT 
p.ProductKey, 
p.EnglishProductName, 
SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountpct)) AS TotalSales
FROM Sales s
JOIN dimproduct p ON s.ProductKey = p.ProductKey
GROUP BY p.ProductKey, p.EnglishProductName
ORDER BY TotalSales DESC
LIMIT 10;


select * from dimcustomer;

-- B) Top 10 Customers by sales

SELECT 
    c.CustomerKey,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,
    SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountpct)) AS TotalSales
FROM Sales s
JOIN dimcustomer c ON s.CustomerKey = c.CustomerKey
GROUP BY c.CustomerKey, CustomerFullName
ORDER BY TotalSales DESC
LIMIT 10;

-- C) Sales by region and the total product quantity sold.

SELECT 
    st.SalesTerritoryRegion AS Region,
    dp.EnglishProductName AS Product,
    SUM(fis.SalesAmount) AS TotalSalesAmount,
    SUM(fis.OrderQuantity) AS TotalQuantitySold
FROM 
    dimsalesterritory st
JOIN 
    sales fis ON st.SalesTerritoryKey = fis.SalesTerritoryKey
JOIN 
    dimproduct dp ON fis.ProductKey = dp.ProductKey
GROUP BY 
    st.SalesTerritoryRegion, dp.EnglishProductName
ORDER BY 
    Region, TotalSalesAmount DESC;


select * from dimsalesterritory;



