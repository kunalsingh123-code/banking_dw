-- =========================================
-- BRONZE LAYER
-- RAW SOURCE TABLES
-- =========================================

DROP TABLE IF EXISTS bronze.transactions;
DROP TABLE IF EXISTS bronze.accounts;
DROP TABLE IF EXISTS bronze.customers;
DROP TABLE IF EXISTS bronze.branches;


-- =========================================
-- BRANCHES
-- =========================================

CREATE TABLE bronze.branches (
    branch_id       VARCHAR(20),
    branch_name     VARCHAR(100),
    city            VARCHAR(100),
    state           VARCHAR(100),
    branch_type     VARCHAR(50)
);


-- =========================================
-- CUSTOMERS
-- =========================================

CREATE TABLE bronze.customers (
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(150),
    email           VARCHAR(150),
    phone           VARCHAR(50),
    city            VARCHAR(100),
    state           VARCHAR(100),
    date_of_birth   DATE,
    customer_type   VARCHAR(50)
);


-- =========================================
-- ACCOUNTS
-- =========================================

CREATE TABLE bronze.accounts (
    account_id       VARCHAR(20),
    customer_id      VARCHAR(20),
    branch_id        VARCHAR(20),
    account_type     VARCHAR(50),
    account_balance  NUMERIC(15,2),
    account_status   VARCHAR(30),
    opened_date      DATE
);


-- =========================================
-- TRANSACTIONS
-- =========================================

CREATE TABLE bronze.transactions (
    transaction_id      VARCHAR(20),
    account_id          VARCHAR(20),
    transaction_date    DATE,
    transaction_type    VARCHAR(50),
    amount              NUMERIC(15,2),
    transaction_status  VARCHAR(30),
    merchant_name       VARCHAR(150),
    city                VARCHAR(100)
);


-- =========================================
-- VERIFY TABLES
-- =========================================

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'bronze'
ORDER BY table_name;