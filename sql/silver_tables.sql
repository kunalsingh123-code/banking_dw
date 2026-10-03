-- =========================================
-- SILVER LAYER
-- CLEANED / STANDARDIZED TABLES
-- =========================================

DROP TABLE IF EXISTS silver.transactions;
DROP TABLE IF EXISTS silver.accounts;
DROP TABLE IF EXISTS silver.customers;
DROP TABLE IF EXISTS silver.branches;


-- =========================================
-- SILVER BRANCHES
-- =========================================

CREATE TABLE silver.branches (
    branch_key      BIGSERIAL PRIMARY KEY,
    branch_id       VARCHAR(20) NOT NULL,
    branch_name     VARCHAR(100),
    city            VARCHAR(100),
    state           VARCHAR(100),
    branch_type     VARCHAR(50),

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file     VARCHAR(255),
    is_current      BOOLEAN DEFAULT TRUE,

    CONSTRAINT uq_silver_branch
        UNIQUE (branch_id)
);


-- =========================================
-- SILVER CUSTOMERS
-- =========================================

CREATE TABLE silver.customers (
    customer_key     BIGSERIAL PRIMARY KEY,
    customer_id      VARCHAR(20) NOT NULL,
    customer_name    VARCHAR(150),
    email            VARCHAR(150),
    phone            VARCHAR(50),
    city             VARCHAR(100),
    state            VARCHAR(100),
    date_of_birth    DATE,
    customer_type    VARCHAR(50),

    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file      VARCHAR(255),
    is_current       BOOLEAN DEFAULT TRUE,

    CONSTRAINT uq_silver_customer
        UNIQUE (customer_id)
);


-- =========================================
-- SILVER ACCOUNTS
-- =========================================

CREATE TABLE silver.accounts (
    account_key       BIGSERIAL PRIMARY KEY,
    account_id        VARCHAR(20) NOT NULL,
    customer_id       VARCHAR(20),
    branch_id         VARCHAR(20),
    account_type      VARCHAR(50),
    account_balance   NUMERIC(15,2),
    account_status    VARCHAR(30),
    opened_date       DATE,

    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file       VARCHAR(255),
    is_current        BOOLEAN DEFAULT TRUE,

    CONSTRAINT uq_silver_account
        UNIQUE (account_id)
);


-- =========================================
-- SILVER TRANSACTIONS
-- =========================================

CREATE TABLE silver.transactions (
    transaction_key      BIGSERIAL PRIMARY KEY,
    transaction_id       VARCHAR(20) NOT NULL,
    account_id           VARCHAR(20),
    transaction_date     DATE,
    transaction_type     VARCHAR(50),
    amount               NUMERIC(15,2),
    transaction_status   VARCHAR(30),
    merchant_name        VARCHAR(150),
    city                 VARCHAR(100),

    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file          VARCHAR(255),
    is_current           BOOLEAN DEFAULT TRUE,

    CONSTRAINT uq_silver_transaction
        UNIQUE (transaction_id)
);


-- =========================================
-- VERIFY
-- =========================================

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'silver'
ORDER BY table_name;