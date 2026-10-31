
CREATE DATABASE IF NOT EXISTS evermart_analytics
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE evermart_analytics;

SELECT DATABASE() AS current_database;



USE evermart_analytics;

-- 1. CUSTOMERS TABLE
CREATE TABLE IF NOT EXISTS customers (
    CustomerID VARCHAR(20) NOT NULL,
    CustomerName VARCHAR(150),
    Region VARCHAR(100),
    SignupDate DATE,
    PRIMARY KEY (CustomerID)
);

-- 2. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS products (
    ProductID VARCHAR(20) NOT NULL,
    ProductName VARCHAR(200),
    Category VARCHAR(100),
    Price DECIMAL(12,2),
    PRIMARY KEY (ProductID)
);

-- 3. TRANSACTIONS TABLE
CREATE TABLE IF NOT EXISTS transactions (
    TransactionID VARCHAR(20) NOT NULL,
    CustomerID VARCHAR(20) NOT NULL,
    ProductID VARCHAR(20) NOT NULL,
    TransactionDate DATE,
    Quantity INT,
    TotalValue DECIMAL(12,2),
    Price DECIMAL(12,2),

    PRIMARY KEY (TransactionID),

    CONSTRAINT fk_transaction_customer
        FOREIGN KEY (CustomerID)
        REFERENCES customers(CustomerID),

    CONSTRAINT fk_transaction_product
        FOREIGN KEY (ProductID)
        REFERENCES products(ProductID)
);



USE evermart_analytics;

SHOW TABLES;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'evermart_analytics'
ORDER BY TABLE_NAME, ORDINAL_POSITION;


USE evermart_analytics;

SELECT 'Customers' AS TableName,
       COUNT(*) AS TotalRecords
FROM customers

UNION ALL

SELECT 'Products',
       COUNT(*)
FROM products

UNION ALL

SELECT 'Transactions',
       COUNT(*)
FROM transactions;


USE evermart_analytics;

RENAME TABLE
    cleaned_customer TO customers;
    cleaned_products TO products,
    cleaned_Transaction TO transactions;


USE evermart_analytics;

SHOW TABLES;



SELECT 'Customers' AS TableName,
       COUNT(*) AS TotalRecords
FROM cleaned_customer

UNION ALL

SELECT 'Products' AS TableName,
       COUNT(*) AS TotalRecords
FROM cleaned_products

UNION ALL

SELECT 'Transactions' AS TableName,
       COUNT(*) AS TotalRecords
FROM cleaned_transcation;


SELECT *
FROM cleaned_customer
LIMIT 10;


SELECT CustomerID, COUNT(*) AS DuplicateCount
FROM cleaned_customer
GROUP BY CustomerID
HAVING COUNT(*) > 1;

SHOW COLUMNS FROM cleaned_customer;


USE evermart_analytics;

ALTER TABLE cleaned_customer
RENAME COLUMN `ï»¿CustomerID` TO CustomerID;



USE evermart_analytics;

SELECT
    CustomerID,
    CustomerName,
    Region,
    SignupDate
FROM cleaned_customer
WHERE CustomerID IS NULL
   OR TRIM(CustomerID) = ''
   OR CustomerID = 'CustomerID'
   OR CustomerID NOT REGEXP '^C[0-9]{4}$';
   
   
USE evermart_analytics;


USE evermart_analytics;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM cleaned_customer
WHERE CustomerName = 'CustomerName'
  AND Region = 'Region'
  AND SignupDate = 'SignupDate'
  AND CustomerID LIKE '%CustomerID';

SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) AS TotalCustomers
FROM cleaned_customer;


USE evermart_analytics;

SELECT 'Customers' AS TableName,
       COUNT(*) AS TotalRecords
FROM cleaned_customer

UNION ALL

SELECT 'Products',
       COUNT(*)
FROM cleaned_products

UNION ALL

SELECT 'Transactions',
       COUNT(*)
FROM cleaned_transaction;


SHOW TABLES;


USE evermart_analytics;

SELECT 'Customers' AS TableName,
       COUNT(*) AS TotalRecords
FROM cleaned_customer

UNION ALL

SELECT 'Products',
       COUNT(*)
FROM cleaned_products

UNION ALL

SELECT 'Transactions',
       COUNT(*)
FROM cleaned_transcation;


USE evermart_analytics;

SELECT
    'Customers' AS TableName,
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT CustomerID) AS UniqueIDs,
    COUNT(*) - COUNT(DISTINCT CustomerID) AS DuplicateOrNullIDs
FROM cleaned_customer

UNION ALL

SELECT
    'Products',
    COUNT(*),
    COUNT(DISTINCT ProductID),
    COUNT(*) - COUNT(DISTINCT ProductID)
FROM cleaned_products

UNION ALL

SELECT
    'Transactions',
    COUNT(*),
    COUNT(DISTINCT TransactionID),
    COUNT(*) - COUNT(DISTINCT TransactionID)
FROM cleaned_transcation;


USE evermart_analytics;

SELECT
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'evermart_analytics'
  AND TABLE_NAME IN (
      'cleaned_customer',
      'cleaned_products',
      'cleaned_transcation'
  )
ORDER BY TABLE_NAME, ORDINAL_POSITION;


USE evermart_analytics;

SET @old_column = (
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'evermart_analytics'
      AND TABLE_NAME = 'cleaned_products'
      AND ORDINAL_POSITION = 1
);

SET @sql = CONCAT(
    'ALTER TABLE `cleaned_products` RENAME COLUMN `',
    REPLACE(@old_column, '`', '``'),
    '` TO `ProductID`'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SHOW COLUMNS FROM cleaned_products;

SHOW COLUMNS FROM cleaned_transcation;


USE evermart_analytics;

SET @old_column = (
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'evermart_analytics'
      AND TABLE_NAME = 'cleaned_transcation'
      AND ORDINAL_POSITION = 1
);

SET @sql = CONCAT(
    'ALTER TABLE `cleaned_transcation` RENAME COLUMN `',
    REPLACE(@old_column, '`', '``'),
    '` TO `TransactionID`'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SHOW COLUMNS FROM cleaned_transcation;


USE evermart_analytics;

SELECT
    'Customers' AS TableName,
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT CustomerID) AS UniqueIDs,
    COUNT(*) - COUNT(DISTINCT CustomerID) AS DuplicateOrNullIDs
FROM cleaned_customer

UNION ALL

SELECT
    'Products',
    COUNT(*),
    COUNT(DISTINCT ProductID),
    COUNT(*) - COUNT(DISTINCT ProductID)
FROM cleaned_products

UNION ALL

SELECT
    'Transactions',
    COUNT(*),
    COUNT(DISTINCT TransactionID),
    COUNT(*) - COUNT(DISTINCT TransactionID)
FROM cleaned_transcation;


USE evermart_analytics;

SELECT
    'Customers' AS TableName,
    SUM(
        CASE WHEN CustomerName IS NULL
                  OR TRIM(CustomerName) = ''
             THEN 1 ELSE 0 END
    ) AS MissingNames,
    SUM(
        CASE WHEN Region IS NULL
                  OR TRIM(Region) = ''
             THEN 1 ELSE 0 END
    ) AS MissingOtherFields
FROM cleaned_customer

UNION ALL

SELECT
    'Products',
    SUM(
        CASE WHEN ProductName IS NULL
                  OR TRIM(ProductName) = ''
             THEN 1 ELSE 0 END
    ),
    SUM(
        CASE WHEN Category IS NULL
                  OR TRIM(Category) = ''
                  OR Price IS NULL
             THEN 1 ELSE 0 END
    )
FROM cleaned_products

UNION ALL

SELECT
    'Transactions',
    SUM(
        CASE WHEN CustomerID IS NULL
                  OR TRIM(CustomerID) = ''
                  OR ProductID IS NULL
                  OR TRIM(ProductID) = ''
             THEN 1 ELSE 0 END
    ),
    SUM(
        CASE WHEN TransactionDate IS NULL
                  OR TRIM(TransactionDate) = ''
                  OR Quantity IS NULL
                  OR TotalValue IS NULL
                  OR Price IS NULL
             THEN 1 ELSE 0 END
    )
FROM cleaned_transcation;


USE evermart_analytics;

SELECT
    'Invalid Customer References' AS CheckName,
    COUNT(*) AS InvalidRecords
FROM cleaned_transcation t
LEFT JOIN cleaned_customer c
    ON TRIM(t.CustomerID) = TRIM(c.CustomerID)
WHERE c.CustomerID IS NULL

UNION ALL

SELECT
    'Invalid Product References',
    COUNT(*)
FROM cleaned_transcation t
LEFT JOIN cleaned_products p
    ON TRIM(t.ProductID) = TRIM(p.ProductID)
WHERE p.ProductID IS NULL;

SELECT
    COUNT(*) AS TotalTransactions,
    SUM(
        CASE
            WHEN ABS(
                TotalValue - (Quantity * Price)
            ) > 0.01
            THEN 1
            ELSE 0
        END
    ) AS IncorrectTotals,
    SUM(
        CASE
            WHEN Quantity <= 0
              OR Price < 0
              OR TotalValue < 0
            THEN 1
            ELSE 0
        END
    ) AS InvalidAmounts
FROM cleaned_transcation;


USE evermart_analytics;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    COLUMN_KEY,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'evermart_analytics'
  AND TABLE_NAME IN (
      'customers',
      'products',
      'transactions'
  )
ORDER BY TABLE_NAME, ORDINAL_POSITION;


USE evermart_analytics;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'evermart_analytics'
  AND TABLE_NAME = 'transactions'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY COLUMN_NAME;

USE evermart_analytics;


USE evermart_analytics;

SELECT 'cleaned_customer' AS TableName,
       COUNT(*) AS TotalRecords
FROM cleaned_customer

UNION ALL

SELECT 'cleaned_products',
       COUNT(*)
FROM cleaned_products

UNION ALL

SELECT 'cleaned_transcation',
       COUNT(*)
FROM cleaned_transcation

UNION ALL

SELECT 'customers',
       COUNT(*)
FROM customers

UNION ALL

SELECT 'products',
       COUNT(*)
FROM products

UNION ALL

SELECT 'transactions',
       COUNT(*)
FROM transactions;


USE evermart_analytics;

SELECT
    'Customer SignupDate' AS DateColumn,
    SignupDate AS SampleDate
FROM cleaned_customer
LIMIT 5;


SELECT
    'TransactionDate' AS DateColumn,
    TransactionDate AS SampleDate
FROM cleaned_transcation
LIMIT 5;


USE evermart_analytics;

SELECT
    'SignupDate' AS DateColumn,
    COUNT(*) AS TotalRecords,
    SUM(
        CASE
            WHEN SignupDate IS NULL
              OR TRIM(SignupDate) = ''
              OR STR_TO_DATE(
                  TRIM(SignupDate), '%d-%m-%Y'
              ) IS NULL
            THEN 1 ELSE 0
        END
    ) AS InvalidDates
FROM cleaned_customer

UNION ALL

SELECT
    'TransactionDate',
    COUNT(*),
    SUM(
        CASE
            WHEN TransactionDate IS NULL
              OR TRIM(TransactionDate) = ''
              OR STR_TO_DATE(
                  TRIM(TransactionDate), '%d-%m-%Y'
              ) IS NULL
            THEN 1 ELSE 0
        END
    )
FROM cleaned_transcation;


USE evermart_analytics;

START TRANSACTION;

INSERT INTO customers (
    CustomerID,
    CustomerName,
    Region,
    SignupDate
)
SELECT
    TRIM(CustomerID),
    TRIM(CustomerName),
    TRIM(Region),
    STR_TO_DATE(TRIM(SignupDate), '%d-%m-%Y')
FROM cleaned_customer;

SELECT COUNT(*) AS TotalCustomers
FROM customers;


COMMIT;

USE evermart_analytics;

START TRANSACTION;

INSERT INTO products (
    ProductID,
    ProductName,
    Category,
    Price
)
SELECT
    TRIM(ProductID),
    TRIM(ProductName),
    TRIM(Category),
    Price
FROM cleaned_products;

SELECT COUNT(*) AS TotalProducts
FROM products;


USE evermart_analytics;

START TRANSACTION;

INSERT INTO transactions (
    TransactionID,
    CustomerID,
    ProductID,
    TransactionDate,
    Quantity,
    TotalValue,
    Price
)
SELECT
    TRIM(TransactionID),
    TRIM(CustomerID),
    TRIM(ProductID),
    STR_TO_DATE(
        TRIM(TransactionDate), '%d-%m-%Y'
    ),
    Quantity,
    TotalValue,
    Price
FROM cleaned_transcation;

SELECT COUNT(*) AS TotalTransactions
FROM transactions;

USE evermart_analytics;

SELECT
    COUNT(*) AS TotalOrders,
    ROUND(SUM(TotalValue), 2) AS TotalRevenue,
    SUM(Quantity) AS TotalUnitsSold,
    ROUND(AVG(TotalValue), 2) AS AverageOrderValue,
    ROUND(MAX(TotalValue), 2) AS HighestOrderValue,
    ROUND(MIN(TotalValue), 2) AS LowestOrderValue
FROM transactions;



USE evermart_analytics;

SELECT
    p.Category,
    COUNT(t.TransactionID) AS TotalOrders,
    SUM(t.Quantity) AS UnitsSold,
    ROUND(SUM(t.TotalValue), 2) AS TotalRevenue,
    ROUND(AVG(t.TotalValue), 2) AS AverageOrderValue
FROM transactions AS t
INNER JOIN products AS p
    ON t.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY TotalRevenue DESC;


USE evermart_analytics;

SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    COUNT(t.TransactionID) AS TotalOrders,
    SUM(t.Quantity) AS UnitsSold,
    ROUND(SUM(t.TotalValue), 2) AS TotalRevenue
FROM transactions AS t
INNER JOIN products AS p
    ON t.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category
ORDER BY TotalRevenue DESC
LIMIT 10;


USE evermart_analytics;

SELECT
    c.Region,
    COUNT(t.TransactionID) AS TotalOrders,
    SUM(t.Quantity) AS UnitsSold,
    ROUND(SUM(t.TotalValue), 2) AS TotalRevenue,
    ROUND(AVG(t.TotalValue), 2) AS AverageOrderValue,
    COUNT(DISTINCT t.CustomerID) AS ActiveCustomers
FROM transactions AS t
INNER JOIN customers AS c
    ON t.CustomerID = c.CustomerID
INNER JOIN products AS p
    ON t.ProductID = p.ProductID
GROUP BY c.Region
ORDER BY TotalRevenue DESC;


USE evermart_analytics;

SELECT
    YEAR(TransactionDate) AS SalesYear,
    MONTH(TransactionDate) AS SalesMonth,
    DATE_FORMAT(TransactionDate, '%Y-%m') AS YearMonth,
    COUNT(TransactionID) AS TotalOrders,
    SUM(Quantity) AS UnitsSold,
    ROUND(SUM(TotalValue), 2) AS TotalRevenue,
    ROUND(AVG(TotalValue), 2) AS AverageOrderValue
FROM transactions
WHERE TransactionDate IS NOT NULL
GROUP BY
    YEAR(TransactionDate),
    MONTH(TransactionDate),
    DATE_FORMAT(TransactionDate, '%Y-%m')
ORDER BY
    SalesYear ASC,
    SalesMonth ASC;

SELECT
    c.CustomerID,
    c.CustomerName,
    c.Region,
    COUNT(t.TransactionID) AS TotalOrders,
    ROUND(SUM(t.TotalValue), 2) AS TotalSpent,
    ROUND(AVG(t.TotalValue), 2) AS AverageOrderValue
FROM customers AS c
INNER JOIN transactions AS t
    ON c.CustomerID = t.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerName,
    c.Region
HAVING COUNT(t.TransactionID) >= 2
ORDER BY TotalSpent DESC
LIMIT 10;


USE evermart_analytics;

SELECT
    c.CustomerID,
    c.CustomerName,
    c.Region,
    COUNT(t.TransactionID) AS TotalOrders,
    ROUND(SUM(t.TotalValue), 2) AS TotalSpent
FROM customers AS c
INNER JOIN transactions AS t
    ON c.CustomerID = t.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerName,
    c.Region
HAVING SUM(t.TotalValue) > (
    SELECT AVG(CustomerTotal)
    FROM (
        SELECT
            CustomerID,
            SUM(TotalValue) AS CustomerTotal
        FROM transactions
        GROUP BY CustomerID
    ) AS CustomerSpending
)
ORDER BY TotalSpent DESC;


USE evermart_analytics;

SELECT COUNT(*) AS AboveAverageCustomers
FROM (
    SELECT
        CustomerID,
        SUM(TotalValue) AS TotalSpent
    FROM transactions
    GROUP BY CustomerID
    HAVING SUM(TotalValue) > (
        SELECT AVG(CustomerTotal)
        FROM (
            SELECT
                CustomerID,
                SUM(TotalValue) AS CustomerTotal
            FROM transactions
            GROUP BY CustomerID
        ) AS CustomerSpending
    )
) AS AboveAverageResult;


SELECT
    CustomerSegment,
    COUNT(*) AS TotalCustomers,
    ROUND(SUM(TotalSpent), 2) AS SegmentRevenue,
    ROUND(AVG(TotalSpent), 2) AS AverageCustomerSpending
FROM (
    SELECT
        CustomerID,
        SUM(TotalValue) AS TotalSpent,
        CASE
            WHEN SUM(TotalValue) >= 6000 THEN 'High Value'
            WHEN SUM(TotalValue) >= 3000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS CustomerSegment
    FROM transactions
    GROUP BY CustomerID
) AS CustomerAnalysis
GROUP BY CustomerSegment
ORDER BY SegmentRevenue DESC;


SELECT
    p.Category,
    COUNT(t.TransactionID) AS TotalOrders,
    SUM(t.Quantity) AS UnitsSold,
    ROUND(SUM(t.TotalValue), 2) AS TotalRevenue
FROM transactions AS t
INNER JOIN products AS p
    ON t.ProductID = p.ProductID
WHERE t.TransactionDate BETWEEN '2024-07-01'
                            AND '2024-09-30'
  AND p.Category IN ('Electronics', 'Clothing')
GROUP BY p.Category
ORDER BY TotalRevenue DESC;
