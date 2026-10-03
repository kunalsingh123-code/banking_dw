-- =========================================
-- GOLD LAYER
-- DIMENSIONAL DATA WAREHOUSE
-- =========================================

DROP TABLE IF EXISTS gold.fact_transaction;
DROP TABLE IF EXISTS gold.dim_date;
DROP TABLE IF EXISTS gold.dim_account;
DROP TABLE IF EXISTS gold.dim_customer;
DROP TABLE IF EXISTS gold.dim_branch;


-- =========================================
-- DIMENSION: BRANCH
-- =========================================

CREATE TABLE gold.dim_branch (
    branch_key      BIGSERIAL PRIMARY KEY,
    branch_id       VARCHAR(20) NOT NULL,
    branch_name     VARCHAR(100),
    city            VARCHAR(100),
    state           VARCHAR(100),
    branch_type     VARCHAR(50)
);


-- =========================================
-- DIMENSION: CUSTOMER
-- =========================================

CREATE TABLE gold.dim_customer (
    customer_key     BIGSERIAL PRIMARY KEY,
    customer_id      VARCHAR(20) NOT NULL,
    customer_name    VARCHAR(150),
    email            VARCHAR(150),
    phone            VARCHAR(50),
    city             VARCHAR(100),
    state            VARCHAR(100),
    date_of_birth    DATE,
    customer_type    VARCHAR(50)
);


-- =========================================
-- DIMENSION: ACCOUNT
-- =========================================

CREATE TABLE gold.dim_account (
    account_key       BIGSERIAL PRIMARY KEY,
    account_id        VARCHAR(20) NOT NULL,
    customer_key      BIGINT,
    branch_key        BIGINT,
    account_type      VARCHAR(50),
    account_balance   NUMERIC(15,2),
    account_status    VARCHAR(30),
    opened_date       DATE,

    CONSTRAINT fk_account_customer
        FOREIGN KEY (customer_key)
        REFERENCES gold.dim_customer(customer_key),

    CONSTRAINT fk_account_branch
        FOREIGN KEY (branch_key)
        REFERENCES gold.dim_branch(branch_key)
);


-- =========================================
-- DIMENSION: DATE
-- =========================================

CREATE TABLE gold.dim_date (
    date_key        INTEGER PRIMARY KEY,
    full_date       DATE NOT NULL,
    year            INTEGER,
    quarter         INTEGER,
    month           INTEGER,
    month_name      VARCHAR(20),
    day             INTEGER,
    day_name        VARCHAR(20),
    week_number     INTEGER,
    is_weekend      BOOLEAN
);


-- =========================================
-- FACT: TRANSACTION
-- =========================================

CREATE TABLE gold.fact_transaction (
    transaction_key      BIGSERIAL PRIMARY KEY,

    transaction_id       VARCHAR(20) NOT NULL,

    date_key             INTEGER,
    account_key          BIGINT,
    customer_key         BIGINT,
    branch_key           BIGINT,

    transaction_type     VARCHAR(50),
    transaction_status   VARCHAR(30),

    amount               NUMERIC(15,2),

    merchant_name        VARCHAR(150),
    city                 VARCHAR(100),

    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_key)
        REFERENCES gold.dim_date(date_key),

    CONSTRAINT fk_fact_account
        FOREIGN KEY (account_key)
        REFERENCES gold.dim_account(account_key),

    CONSTRAINT fk_fact_customer
        FOREIGN KEY (customer_key)
        REFERENCES gold.dim_customer(customer_key),

    CONSTRAINT fk_fact_branch
        FOREIGN KEY (branch_key)
        REFERENCES gold.dim_branch(branch_key)
);


-- =========================================
-- POPULATE DIM BRANCH
-- =========================================

INSERT INTO gold.dim_branch (
    branch_id,
    branch_name,
    city,
    state,
    branch_type
)
SELECT
    branch_id,
    branch_name,
    city,
    state,
    branch_type
FROM silver.branches;


-- =========================================
-- POPULATE DIM CUSTOMER
-- =========================================

INSERT INTO gold.dim_customer (
    customer_id,
    customer_name,
    email,
    phone,
    city,
    state,
    date_of_birth,
    customer_type
)
SELECT
    customer_id,
    customer_name,
    email,
    phone,
    city,
    state,
    date_of_birth,
    customer_type
FROM silver.customers;


-- =========================================
-- POPULATE DIM ACCOUNT
-- =========================================

INSERT INTO gold.dim_account (
    account_id,
    customer_key,
    branch_key,
    account_type,
    account_balance,
    account_status,
    opened_date
)
SELECT
    a.account_id,

    c.customer_key,

    b.branch_key,

    a.account_type,
    a.account_balance,
    a.account_status,
    a.opened_date

FROM silver.accounts a

LEFT JOIN gold.dim_customer c
    ON a.customer_id = c.customer_id

LEFT JOIN gold.dim_branch b
    ON a.branch_id = b.branch_id;


-- =========================================
-- POPULATE DATE DIMENSION
-- =========================================

INSERT INTO gold.dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day,
    day_name,
    week_number,
    is_weekend
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_key,

    d AS full_date,

    EXTRACT(YEAR FROM d)::INTEGER,

    EXTRACT(QUARTER FROM d)::INTEGER,

    EXTRACT(MONTH FROM d)::INTEGER,

    TO_CHAR(d, 'Month'),

    EXTRACT(DAY FROM d)::INTEGER,

    TO_CHAR(d, 'Day'),

    EXTRACT(WEEK FROM d)::INTEGER,

    EXTRACT(ISODOW FROM d) IN (6,7)

FROM generate_series(
    (SELECT MIN(transaction_date)
     FROM silver.transactions),

    (SELECT MAX(transaction_date)
     FROM silver.transactions),

    INTERVAL '1 day'
) AS d;


-- =========================================
-- POPULATE FACT TRANSACTION
-- =========================================

INSERT INTO gold.fact_transaction (
    transaction_id,
    date_key,
    account_key,
    customer_key,
    branch_key,
    transaction_type,
    transaction_status,
    amount,
    merchant_name,
    city
)
SELECT

    t.transaction_id,

    d.date_key,

    a.account_key,

    a.customer_key,

    a.branch_key,

    t.transaction_type,

    t.transaction_status,

    t.amount,

    t.merchant_name,

    t.city

FROM silver.transactions t

LEFT JOIN gold.dim_date d
    ON t.transaction_date = d.full_date

LEFT JOIN gold.dim_account a
    ON t.account_id = a.account_id;


-- =========================================
-- VERIFY GOLD
-- =========================================

SELECT 'dim_branch' AS table_name, COUNT(*) AS records
FROM gold.dim_branch

UNION ALL

SELECT 'dim_customer', COUNT(*)
FROM gold.dim_customer

UNION ALL

SELECT 'dim_account', COUNT(*)
FROM gold.dim_account

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM gold.dim_date

UNION ALL

SELECT 'fact_transaction', COUNT(*)
FROM gold.fact_transaction;