-- =========================================
-- LOAD CSV FILES INTO BRONZE
-- =========================================

COPY bronze.branches
FROM 'C:/Users/rajuk/etl-projects/banking_dw/datasets/branches.csv'
DELIMITER ','
CSV HEADER;

COPY bronze.customers
FROM 'C:/Users/rajuk/etl-projects/banking_dw/datasets/customers.csv'
DELIMITER ','
CSV HEADER;

COPY bronze.accounts
FROM 'C:/Users/rajuk/etl-projects/banking_dw/datasets/accounts.csv'
DELIMITER ','
CSV HEADER;

COPY bronze.transactions
FROM 'C:/Users/rajuk/etl-projects/banking_dw/datasets/transactions.csv'
DELIMITER ','
CSV HEADER;


-- =========================================
-- VERIFY RECORD COUNTS
-- =========================================

SELECT 'branches' AS table_name, COUNT(*) AS record_count
FROM bronze.branches

UNION ALL

SELECT 'customers', COUNT(*)
FROM bronze.customers

UNION ALL

SELECT 'accounts', COUNT(*)
FROM bronze.accounts

UNION ALL

SELECT 'transactions', COUNT(*)
FROM bronze.transactions;