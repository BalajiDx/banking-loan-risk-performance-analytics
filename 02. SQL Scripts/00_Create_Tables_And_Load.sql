-- 00_Create_Tables_And_Load.sql
-- Purpose : create the four tables used by every script in this folder and load the cleaned CSVs.
-- Dialect : SQLite (run in the sqlite3 shell or DB Browser for SQLite). Notes for SQL Server / MySQL at the bottom.
-- Data    : SYNTHETIC, cut-off date 2024-12-31, amounts in INR.

DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Loans;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Defaults;

CREATE TABLE Customers (
    CustomerID          TEXT PRIMARY KEY,
    Age                 INTEGER,
    Region              TEXT,
    EmploymentType      TEXT,
    AnnualIncome        INTEGER,
    CreditScore         INTEGER,
    JoinDate            TEXT,
    CreditScoreImputed  INTEGER,
    AnnualIncomeImputed INTEGER
);
CREATE TABLE Loans (
    LoanID          TEXT PRIMARY KEY,
    CustomerID      TEXT REFERENCES Customers(CustomerID),
    LoanType        TEXT,
    LoanAmount      REAL,
    TenureMonths    INTEGER,
    InterestRate    REAL,
    OriginationDate TEXT,
    Status          TEXT            -- Active | Closed | Defaulted
);
CREATE TABLE Payments (
    PaymentID     TEXT PRIMARY KEY,
    LoanID        TEXT REFERENCES Loans(LoanID),
    InstallmentNo INTEGER,
    DueDate       TEXT,
    PaidDate      TEXT,
    AmountDue     REAL,
    InterestDue   REAL,
    AmountPaid    REAL,
    DaysLate      INTEGER
);
CREATE TABLE Defaults (
    DefaultID            TEXT PRIMARY KEY,
    LoanID               TEXT REFERENCES Loans(LoanID),
    DefaultDate          TEXT,
    OutstandingAtDefault REAL,
    RecoveryAmount       REAL
);

-- Load (sqlite3 shell; run from the '01. Dataset/Cleaned Dataset' folder)
.mode csv
.import --skip 1 Clean_Customers.csv Customers
.import --skip 1 Clean_Loans.csv Loans
.import --skip 1 Clean_Payments.csv Payments
.import --skip 1 Clean_Defaults.csv Defaults

-- Sanity check: expected 3200 / 4000 / 87428 / 321
SELECT 'Customers' AS tbl, COUNT(*) AS n FROM Customers
UNION ALL SELECT 'Loans',     COUNT(*) FROM Loans
UNION ALL SELECT 'Payments',  COUNT(*) FROM Payments
UNION ALL SELECT 'Defaults',  COUNT(*) FROM Defaults;

-- SQL Server: use BULK INSERT ... WITH (FIRSTROW = 2, FIELDTERMINATOR = ','), TEXT -> VARCHAR, REAL -> DECIMAL(18,2).
-- MySQL     : use LOAD DATA LOCAL INFILE ... IGNORE 1 LINES.
-- Date logic in later scripts uses SQLite functions (strftime, julianday); the equivalents are
-- FORMAT/DATEDIFF in SQL Server and DATE_FORMAT/DATEDIFF in MySQL.
