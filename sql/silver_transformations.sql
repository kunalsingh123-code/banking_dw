-- =========================================
-- BRONZE → SILVER TRANSFORMATION
-- =========================================


-- =========================================
-- 1. BRANCHES
-- =========================================

INSERT INTO silver.branches (
    branch_id,
    branch_name,
    city,
    state,
    branch_type,
    source_file
)
SELECT
    TRIM(branch_id),

    INITCAP(
        TRIM(branch_name)
    ),

    INITCAP(
        TRIM(city)
    ),

    INITCAP(
        TRIM(state)
    ),

    LOWER(
        TRIM(branch_type)
    ),

    'branches.csv'

FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY branch_id
               ORDER BY branch_id
           ) AS rn
    FROM bronze.branches
) b

WHERE rn = 1
  AND NULLIF(TRIM(branch_id), '') IS NOT NULL;


-- =========================================
-- 2. CUSTOMERS
-- =========================================

INSERT INTO silver.customers (
    customer_id,
    customer_name,
    email,
    phone,
    city,
    state,
    date_of_birth,
    customer_type,
    source_file
)
SELECT
    TRIM(customer_id),

    INITCAP(
        TRIM(customer_name)
    ),

    LOWER(
        NULLIF(TRIM(email), '')
    ),

    NULLIF(
        TRIM(phone),
        ''
    ),

    INITCAP(
        NULLIF(TRIM(city), '')
    ),

    INITCAP(
        NULLIF(TRIM(state), '')
    ),

    date_of_birth,

    LOWER(
        NULLIF(TRIM(customer_type), '')
    ),

    'customers.csv'

FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY customer_id
           ) AS rn
    FROM bronze.customers
) c

WHERE rn = 1
  AND NULLIF(TRIM(customer_id), '') IS NOT NULL;


-- =========================================
-- 3. ACCOUNTS
-- =========================================

INSERT INTO silver.accounts (
    account_id,
    customer_id,
    branch_id,
    account_type,
    account_balance,
    account_status,
    opened_date,
    source_file
)
SELECT
    TRIM(account_id),

    TRIM(customer_id),

    TRIM(branch_id),

    LOWER(
        TRIM(account_type)
    ),

    CASE
        WHEN account_balance >= 0
        THEN account_balance
        ELSE 0
    END,

    LOWER(
        TRIM(account_status)
    ),

    opened_date,

    'accounts.csv'

FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY account_id
               ORDER BY account_id
           ) AS rn
    FROM bronze.accounts
) a

WHERE rn = 1
  AND NULLIF(TRIM(account_id), '') IS NOT NULL;


-- =========================================
-- 4. TRANSACTIONS
-- =========================================

INSERT INTO silver.transactions (
    transaction_id,
    account_id,
    transaction_date,
    transaction_type,
    amount,
    transaction_status,
    merchant_name,
    city,
    source_file
)
SELECT
    TRIM(transaction_id),

    TRIM(account_id),

    transaction_date,

    LOWER(
        TRIM(transaction_type)
    ),

    CASE
        WHEN amount >= 0
        THEN amount
        ELSE 0
    END,

    LOWER(
        TRIM(transaction_status)
    ),

    NULLIF(
        TRIM(merchant_name),
        ''
    ),

    INITCAP(
        NULLIF(TRIM(city), '')
    ),

    'transactions.csv'

FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY transaction_id
               ORDER BY transaction_id
           ) AS rn
    FROM bronze.transactions
) t

WHERE rn = 1
  AND NULLIF(TRIM(transaction_id), '') IS NOT NULL;


-- =========================================
-- SILVER RECORD COUNTS
-- =========================================

SELECT 'branches' AS table_name, COUNT(*) AS records
FROM silver.branches

UNION ALL

SELECT 'customers', COUNT(*)
FROM silver.customers

UNION ALL

SELECT 'accounts', COUNT(*)
FROM silver.accounts

UNION ALL

SELECT 'transactions', COUNT(*)
FROM silver.transactions;