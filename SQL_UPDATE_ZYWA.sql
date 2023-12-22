use transactions

select * from transactions  limit



-- Monthly transactions


SELECT
  DATE_FORMAT(STR_TO_DATE(transaction_timestamp, '%d/%m/%y %H:%i'), '%Y-%m') AS month,
  COALESCE(SUM(transaction_amount), 0) AS total_amount
FROM transactions  
GROUP BY DATE_FORMAT(STR_TO_DATE(transaction_timestamp, '%d/%m/%y %H:%i'), '%Y-%m');

-- Top 5 most popular products


SELECT
  merchant_type,
  COUNT(*) AS transaction_count
FROM transactions 
GROUP BY merchant_type
ORDER BY transaction_count DESC
LIMIT 5;







-- Daily revenue trend
SELECT
    DATE_FORMAT(transaction_timestamp, '%y-%m-%d') AS date,
    SUM(transaction_amount) AS daily_revenue
FROM transactions
GROUP BY DATE_FORMAT(transaction_timestamp, '%y-%m-%d')
ORDER BY date;

-- Average transaction amount by category
SELECT
  merchant_type,
  AVG(transaction_amount) AS avg_amount
FROM transactions
GROUP BY merchant_type;


-- Transaction funnel





SET @completed_status := '1829';
SET @pending_status := '1002';
SET @cancelled_status := '0';
SET @another_status_1 := '1006';
SET @another_status_2 := '1022';
SET @another_status_3 := '9102';

SELECT
  COUNT(*) AS total_transactions,
  SUM(CASE WHEN transaction_status = @completed_status THEN 1 ELSE 0 END) AS completed_transactions,
  SUM(CASE WHEN transaction_status = @pending_status THEN 1 ELSE 0 END) AS pending_transactions,
  SUM(CASE WHEN transaction_status = @cancelled_status THEN 1 ELSE 0 END) AS cancelled_transactions,
  SUM(CASE WHEN transaction_status = @another_status_1 THEN 1 ELSE 0 END) AS another_status_1_transactions,
  SUM(CASE WHEN transaction_status = @another_status_2 THEN 1 ELSE 0 END) AS another_status_2_transactions,
  SUM(CASE WHEN transaction_status = @another_status_3 THEN 1 ELSE 0 END) AS another_status_3_transactions
FROM transactions;



-- Monthly Retention rate

WITH MonthlyUserCounts AS (
    SELECT
        EXTRACT(MONTH FROM t.transaction_timestamp) AS transaction_month,
        COUNT(DISTINCT t.user_id) AS user_count
    FROM
        transactions t
    GROUP BY
        EXTRACT(MONTH FROM t.transaction_timestamp)
),
MonthlyRetention AS (
    SELECT
        current_month.transaction_month,
        current_month.user_count AS current_month_users,
        COALESCE(previous_month.user_count, 0) AS previous_month_users
    FROM
        MonthlyUserCounts current_month
    LEFT JOIN
        MonthlyUserCounts previous_month ON current_month.transaction_month = previous_month.transaction_month + 1
)
SELECT
    transaction_month,
    current_month_users,
    previous_month_users,
    CASE
        WHEN previous_month_users = 0 THEN NULL
        ELSE ROUND((current_month_users / NULLIF(previous_month_users, 0)) * 100, 2)
    END AS retention_rate
FROM
    MonthlyRetention  -- Corrected CTE name
ORDER BY
    transaction_month;


