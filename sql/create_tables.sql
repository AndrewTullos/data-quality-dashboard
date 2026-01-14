DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS data_quality_logs;

CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    member_firstname VARCHAR(50) NOT NULL,
    member_lastname VARCHAR(50) NOT NULL
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    member_id INT NOT NULL,
    balance_after DECIMAL(18,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_date DATE NOT NULL
        CHECK (transaction_date <= CURRENT_DATE),
    balance_after DECIMAL(18,2) NOT NULL,
    transaction_amount DECIMAL(18,2) NOT NULL
        CHECK (transaction_amount <> 0),

    transaction_currency VARCHAR(3) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL
        CHECK (transaction_type IN ('DEBIT', 'CREDIT')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Enforce DEBIT = negative, CREDIT = positive
    CHECK (
        (transaction_type = 'DEBIT' AND transaction_amount < 0)
        OR
        (transaction_type = 'CREDIT' AND transaction_amount > 0)
    ),

    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE data_quality_logs (
    dq_log_id SERIAL PRIMARY KEY,

    table_name VARCHAR(100) NOT NULL,
    column_name VARCHAR(100),

    check_type VARCHAR(50) NOT NULL,
    -- e.g. NOT_NULL, DUPLICATE, RANGE_CHECK, FK_CHECK

    check_description TEXT,

    total_records INT,
    failed_records INT,

    severity VARCHAR(20) NOT NULL,
    -- INFO, WARNING, CRITICAL

    status VARCHAR(20) NOT NULL,
-- PASSED, FAILED

    run_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    pipeline_name VARCHAR(100),
    triggered_by VARCHAR(50)    -- SCHEDULED, MANUAL, BACKFILL
);

INSERT INTO data_quality_logs (
    table_name,
    column_name,
    check_type,
    check_description,
    total_records,
    failed_records,
    severity,
    status,
    pipeline_name,
    triggered_by
)
VALUES (
    'transactions',
    'transaction_amount',
    'RANGE_CHECK',
    'Transaction amount must be greater than 0',
    10000,
    12,
    'CRITICAL',
    'FAILED',
    'daily_transactions_etl',
    'SCHEDULED'
);
