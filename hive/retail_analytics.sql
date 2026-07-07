-- Create database for the project
CREATE DATABASE IF NOT EXISTS retail_hive;
USE retail_hive;

-- Raw table to load CSV from local machine
DROP TABLE IF EXISTS online_retail_raw;

CREATE TABLE online_retail_raw (
  InvoiceNo STRING,
  StockCode STRING,
  Description STRING,
  Quantity INT,
  InvoiceDate STRING,
  UnitPrice DOUBLE,
  CustomerID STRING,
  Country STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Load CSV file from local path into Hive
LOAD DATA LOCAL INPATH '/root/online_retail.csv'
INTO TABLE online_retail_raw;

-- Clean table: remove invalid rows and compute Sales + timestamp
DROP TABLE IF EXISTS online_retail_cleaned;

CREATE TABLE online_retail_cleaned AS
SELECT *,
       Quantity * UnitPrice AS Sales,
       unix_timestamp(InvoiceDate, 'MM/dd/yyyy HH:mm') AS InvoiceTimestampUnix
FROM online_retail_raw
WHERE Quantity > 0
  AND UnitPrice > 0
  AND InvoiceDate IS NOT NULL;

-- Add time-based features (year, month, day, hour, weekday)
DROP TABLE IF EXISTS online_retail_times;

CREATE TABLE online_retail_times AS
SELECT
  InvoiceNo,
  StockCode,
  Description,
  Quantity,
  UnitPrice,
  Sales,
  CustomerID,
  Country,
  from_unixtime(InvoiceTimestampUnix) AS InvoiceTimestamp,
  year(from_unixtime(InvoiceTimestampUnix)) AS Year,
  month(from_unixtime(InvoiceTimestampUnix)) AS Month,
  day(from_unixtime(InvoiceTimestampUnix)) AS Day,
  hour(from_unixtime(InvoiceTimestampUnix)) AS Hour,
  weekofyear(from_unixtime(InvoiceTimestampUnix)) AS WeekOfYear,
  pmod(datediff(from_unixtime(InvoiceTimestampUnix), "1970-01-04"), 7) + 1 AS DayOfWeek
FROM online_retail_cleaned
WHERE InvoiceTimestampUnix IS NOT NULL;

-- Category-wise sales computation
DROP TABLE IF EXISTS category_sales;

CREATE TABLE category_sales AS
SELECT Description AS Category,
       SUM(Sales) AS TotalSales,
       SUM(Quantity) AS TotalQuantity
FROM online_retail_times
GROUP BY Description
ORDER BY TotalSales DESC;

-- Country-wise sales and store performance
DROP TABLE IF EXISTS store_performance;

CREATE TABLE store_performance AS
SELECT Country,
       COUNT(DISTINCT InvoiceNo) AS NumOrders,
       SUM(Sales) AS TotalSales,
       AVG(Sales) AS AvgOrderValue
FROM online_retail_times
GROUP BY Country
ORDER BY TotalSales DESC;

-- Daily sales trend
DROP TABLE IF EXISTS daily_sales;

CREATE TABLE daily_sales AS
SELECT Year, Month, Day,
       SUM(Sales) AS TotalSales,
       SUM(Quantity) AS TotalUnits
FROM online_retail_times
GROUP BY Year, Month, Day
ORDER BY Year, Month, Day;

-- Monthly sales trend
DROP TABLE IF EXISTS monthly_sales;

CREATE TABLE monthly_sales AS
SELECT Year, Month,
       SUM(Sales) AS TotalSales,
       SUM(Quantity) AS TotalUnits
FROM online_retail_times
GROUP BY Year, Month
ORDER BY Year, Month;

-- Top selling products
DROP TABLE IF EXISTS top_products;

CREATE TABLE top_products AS
SELECT StockCode, Description,
       SUM(Quantity) AS TotalUnitsSold,
       SUM(Sales) AS TotalSales
FROM online_retail_times
GROUP BY StockCode, Description
ORDER BY TotalSales DESC;

-- Price vs Sales analysis table
DROP TABLE IF EXISTS price_sales;

CREATE TABLE price_sales AS
SELECT StockCode, Description,
       AVG(UnitPrice) AS AvgPrice,
       SUM(Sales) AS TotalSales,
       SUM(Quantity) AS TotalUnits
FROM online_retail_times
GROUP BY StockCode, Description;

-- Low-moving inventory items
DROP TABLE IF EXISTS low_moving_products;

CREATE TABLE low_moving_products AS
SELECT StockCode, Description,
       SUM(Quantity) AS TotalUnits
FROM online_retail_times
GROUP BY StockCode, Description
HAVING SUM(Quantity) < 50
ORDER BY TotalUnits ASC;

-- Basket size analysis (items per invoice)
DROP TABLE IF EXISTS basket_stats;

CREATE TABLE basket_stats AS
SELECT InvoiceNo,
       COUNT(DISTINCT StockCode) AS DistinctItems,
       SUM(Quantity) AS TotalUnits,
       SUM(Sales) AS OrderValue
FROM online_retail_times
GROUP BY InvoiceNo;

-- Profit estimation assuming 40% margin
DROP TABLE IF EXISTS margin_analysis;

CREATE TABLE margin_analysis AS
SELECT StockCode, Description,
       SUM(Sales) AS TotalSales,
       SUM(Sales) * 0.40 AS Profit
FROM online_retail_times
GROUP BY StockCode, Description
ORDER BY Profit DESC;

-- Brand performance from first 15 letters of description
DROP TABLE IF EXISTS brand_performance;

CREATE TABLE brand_performance AS
SELECT substr(upper(Description), 1, 15) AS Brand,
       SUM(Sales) AS BrandSales,
       SUM(Quantity) AS BrandUnits
FROM online_retail_times
GROUP BY substr(upper(Description), 1, 15)
ORDER BY BrandSales DESC;

-- Seasonal sales classification
DROP TABLE IF EXISTS seasonal_sales;

CREATE TABLE seasonal_sales AS
SELECT Year, Month,
  CASE WHEN Month IN (11,12) THEN 'Festival'
       WHEN Month IN (6,7,8) THEN 'Summer'
       ELSE 'Regular' END AS Season,
  SUM(Sales) AS TotalSales
FROM online_retail_times
GROUP BY Year, Month
ORDER BY Year, Month;

-- Weekly sales pattern (day of week + hour)
DROP TABLE IF EXISTS weekly_pattern;

CREATE TABLE weekly_pattern AS
SELECT DayOfWeek, Hour,
       AVG(Sales) AS AvgSales,
       SUM(Quantity) AS TotalUnits
FROM online_retail_times
GROUP BY DayOfWeek, Hour
ORDER BY DayOfWeek, Hour;

-- Correlation data for R
DROP TABLE IF EXISTS corr_ready;

CREATE TABLE corr_ready AS
SELECT Sales, Quantity, UnitPrice
FROM online_retail_times;

-- Export all results to HDFS for R analysis
INSERT OVERWRITE DIRECTORY '/project/exports/category_sales'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM category_sales;

INSERT OVERWRITE DIRECTORY '/project/exports/store_performance'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM store_performance;

INSERT OVERWRITE DIRECTORY '/project/exports/daily_sales'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM daily_sales;

INSERT OVERWRITE DIRECTORY '/project/exports/monthly_sales'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM monthly_sales;

INSERT OVERWRITE DIRECTORY '/project/exports/top_products'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM top_products;

INSERT OVERWRITE DIRECTORY '/project/exports/price_sales'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM price_sales;

INSERT OVERWRITE DIRECTORY '/project/exports/low_moving_products'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM low_moving_products;

INSERT OVERWRITE DIRECTORY '/project/exports/basket_stats'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM basket_stats;

INSERT OVERWRITE DIRECTORY '/project/exports/margin_analysis'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM margin_analysis;

INSERT OVERWRITE DIRECTORY '/project/exports/brand_performance'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM brand_performance;

INSERT OVERWRITE DIRECTORY '/project/exports/seasonal_sales'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM seasonal_sales;

INSERT OVERWRITE DIRECTORY '/project/exports/weekly_pattern'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM weekly_pattern;

INSERT OVERWRITE DIRECTORY '/project/exports/corr_ready'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM corr_ready;
