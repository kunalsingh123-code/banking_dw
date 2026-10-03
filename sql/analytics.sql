-- =========================================
-- BANKING ANALYTICS
-- =========================================


-- =========================================
-- 1. TOTAL TRANSACTION VALUE
-- =========================================

SELECT
    SUM(amount) AS total_transaction_value
FROM gold.fact_transaction;


-- =========================================
-- 2. TOTAL NUMBER OF TRANSACTIONS
-- =========================================

SELECT
    COUNT(*) AS total_transactions
FROM gold.fact_transaction;


-- =========================================
-- 3. TRANSACTION VALUE BY TYPE
-- =========================================

SELECT
    transaction_type,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM gold.fact_transaction
GROUP BY transaction_type
ORDER BY total_amount DESC;


-- =========================================
-- 4. TRANSACTIONS BY STATUS
-- =========================================

SELECT
    transaction_status,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM gold.fact_transaction
GROUP BY transaction_status
ORDER BY transaction_count DESC;


-- =========================================
-- 5. TOP 10 CUSTOMERS BY TRANSACTION VALUE
-- =========================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(f.transaction_id) AS transaction_count,
    SUM(f.amount) AS total_transaction_value
FROM gold.fact_transaction f

JOIN gold.dim_customer c
    ON f.customer_key = c.customer_key

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY total_transaction_value DESC

LIMIT 10;


-- =========================================
-- 6. BRANCH PERFORMANCE
-- =========================================

SELECT
    b.branch_name,
    b.city,
    b.state,
    COUNT(f.transaction_id) AS transaction_count,
    SUM(f.amount) AS total_transaction_value
FROM gold.fact_transaction f

JOIN gold.dim_branch b
    ON f.branch_key = b.branch_key

GROUP BY
    b.branch_name,
    b.city,
    b.state

ORDER BY total_transaction_value DESC;


-- =========================================
-- 7. ACCOUNT TYPE ANALYSIS
-- =========================================

SELECT
    a.account_type,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    SUM(a.account_balance) AS total_balance
FROM gold.dim_account a
GROUP BY a.account_type
ORDER BY total_balance DESC;


-- =========================================
-- 8. CUSTOMER TYPE ANALYSIS
-- =========================================

SELECT
    c.customer_type,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(f.transaction_id) AS transactions,
    SUM(f.amount) AS total_transaction_value
FROM gold.dim_customer c

LEFT JOIN gold.fact_transaction f
    ON c.customer_key = f.customer_key

GROUP BY c.customer_type
ORDER BY total_transaction_value DESC;


-- =========================================
-- 9. MONTHLY TRANSACTION ANALYSIS
-- =========================================

SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(f.transaction_id) AS transaction_count,
    SUM(f.amount) AS total_transaction_value
FROM gold.fact_transaction f

JOIN gold.dim_date d
    ON f.date_key = d.date_key

GROUP BY
    d.year,
    d.month,
    d.month_name

ORDER BY
    d.year,
    d.month;


-- =========================================
-- 10. DAILY TRANSACTION ANALYSIS
-- =========================================

SELECT
    d.full_date,
    COUNT(f.transaction_id) AS transaction_count,
    SUM(f.amount) AS total_amount
FROM gold.fact_transaction f

JOIN gold.dim_date d
    ON f.date_key = d.date_key

GROUP BY d.full_date

ORDER BY d.full_date;


-- =========================================
-- 11. HIGH-VALUE TRANSACTIONS
-- =========================================

SELECT
    f.transaction_id,
    f.amount,
    f.transaction_type,
    f.transaction_status,
    c.customer_name,
    a.account_id,
    b.branch_name
FROM gold.fact_transaction f

JOIN gold.dim_customer c
    ON f.customer_key = c.customer_key

JOIN gold.dim_account a
    ON f.account_key = a.account_key

JOIN gold.dim_branch b
    ON f.branch_key = b.branch_key

WHERE f.amount >= 50000

ORDER BY f.amount DESC;


-- =========================================
-- 12. FAILED / REJECTED TRANSACTIONS
-- =========================================

SELECT
    transaction_status,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM gold.fact_transaction

WHERE transaction_status IN (
    'failed',
    'rejected'
)

GROUP BY transaction_status;


-- =========================================
-- 13. MERCHANT ANALYSIS
-- =========================================

SELECT
    merchant_name,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM gold.fact_transaction

WHERE merchant_name IS NOT NULL

GROUP BY merchant_name

ORDER BY total_amount DESC

LIMIT 20;


-- =========================================
-- 14. CITY-WISE TRANSACTION ANALYSIS
-- =========================================

SELECT
    city,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM gold.fact_transaction

GROUP BY city

ORDER BY total_amount DESC;


-- =========================================
-- 15. CUSTOMER TRANSACTION RANKING
-- =========================================

SELECT
    c.customer_id,
    c.customer_name,
    SUM(f.amount) AS total_amount,

    RANK() OVER (
        ORDER BY SUM(f.amount) DESC
    ) AS customer_rank

FROM gold.fact_transaction f

JOIN gold.dim_customer c
    ON f.customer_key = c.customer_key

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY customer_rank;


-- =========================================
-- 16. RUNNING TRANSACTION TOTAL
-- =========================================

SELECT
    d.full_date,

    SUM(SUM(f.amount)) OVER (
        ORDER BY d.full_date
    ) AS running_total

FROM gold.fact_transaction f

JOIN gold.dim_date d
    ON f.date_key = d.date_key

GROUP BY d.full_date

ORDER BY d.full_date;


-- =========================================
-- 17. POTENTIAL HIGH-VALUE ACTIVITY
-- =========================================

SELECT
    c.customer_name,
    COUNT(*) AS transaction_count,
    SUM(f.amount) AS total_amount,
    MAX(f.amount) AS highest_transaction
FROM gold.fact_transaction f

JOIN gold.dim_customer c
    ON f.customer_key = c.customer_key

GROUP BY c.customer_name

HAVING
    COUNT(*) >= 3
    AND SUM(f.amount) >= 100000

ORDER BY total_amount DESC;