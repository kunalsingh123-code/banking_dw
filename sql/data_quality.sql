-- =========================================
-- DATA QUALITY CHECKS
-- =========================================


-- =========================================
-- 1. CUSTOMER DUPLICATES
-- =========================================

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM silver.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- =========================================
-- 2. ACCOUNT DUPLICATES
-- =========================================

SELECT
    account_id,
    COUNT(*) AS duplicate_count
FROM silver.accounts
GROUP BY account_id
HAVING COUNT(*) > 1;


-- =========================================
-- 3. TRANSACTION DUPLICATES
-- =========================================

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM silver.transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


-- =========================================
-- 4. ACCOUNTS WITHOUT CUSTOMERS
-- =========================================

SELECT
    a.account_id,
    a.customer_id
FROM silver.accounts a
LEFT JOIN silver.customers c
    ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- =========================================
-- 5. ACCOUNTS WITHOUT BRANCH
-- =========================================

SELECT
    a.account_id,
    a.branch_id
FROM silver.accounts a
LEFT JOIN silver.branches b
    ON a.branch_id = b.branch_id
WHERE b.branch_id IS NULL;


-- =========================================
-- 6. TRANSACTIONS WITHOUT ACCOUNT
-- =========================================

SELECT
    t.transaction_id,
    t.account_id
FROM silver.transactions t
LEFT JOIN silver.accounts a
    ON t.account_id = a.account_id
WHERE a.account_id IS NULL;


-- =========================================
-- 7. NEGATIVE TRANSACTION AMOUNTS
-- =========================================

SELECT *
FROM silver.transactions
WHERE amount < 0;


-- =========================================
-- 8. NULL CUSTOMER EMAIL
-- =========================================

SELECT *
FROM silver.customers
WHERE email IS NULL;


-- =========================================
-- 9. INVALID TRANSACTION AMOUNT
-- =========================================

SELECT *
FROM silver.transactions
WHERE amount <= 0;


-- =========================================
-- 10. INVALID ACCOUNT BALANCE
-- =========================================

SELECT *
FROM silver.accounts
WHERE account_balance < 0;


-- =========================================
-- 11. FUTURE TRANSACTIONS
-- =========================================

SELECT *
FROM silver.transactions
WHERE transaction_date > CURRENT_DATE;


-- =========================================
-- 12. DATA QUALITY SUMMARY
-- =========================================

SELECT
    'Customers' AS entity,
    COUNT(*) AS total_records,
    COUNT(customer_id) AS valid_ids,
    COUNT(*) - COUNT(customer_id) AS missing_ids
FROM silver.customers

UNION ALL

SELECT
    'Accounts',
    COUNT(*),
    COUNT(account_id),
    COUNT(*) - COUNT(account_id)
FROM silver.accounts

UNION ALL

SELECT
    'Transactions',
    COUNT(*),
    COUNT(transaction_id),
    COUNT(*) - COUNT(transaction_id)
FROM silver.transactions;