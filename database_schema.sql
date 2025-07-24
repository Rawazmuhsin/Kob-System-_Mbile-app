-- SQLite Database Schema for Banking App
-- Converted from MySQL structure in olddata.sql
-- Created: July 24, 2025

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Table structure for table 'accounts'
CREATE TABLE accounts (
    account_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255),
    password VARCHAR(255) NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0.00,
    account_type TEXT CHECK(account_type IN ('Checking', 'Savings')) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    phone VARCHAR(20) NOT NULL,
    account_number VARCHAR(255),
    profile_image VARCHAR(255),
    salt VARCHAR(255)
);

-- Table structure for table 'admin'
CREATE TABLE admin (
    admin_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role VARCHAR(20) DEFAULT 'manager',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME,
    is_active INTEGER DEFAULT 1,
    salt VARCHAR(255)
);

-- Table structure for table 'cards'
CREATE TABLE cards (
    card_id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER,
    card_number VARCHAR(16) NOT NULL UNIQUE,
    card_type TEXT CHECK(card_type IN ('DEBIT', 'CREDIT', 'PREPAID')) NOT NULL,
    card_usage_type TEXT CHECK(card_usage_type IN ('PHYSICAL', 'ONLINE', 'PHONE', 'INTERNET')) NOT NULL,
    card_holder_name VARCHAR(100) NOT NULL,
    expiry_date DATE NOT NULL,
    cvv VARCHAR(3) NOT NULL,
    pin_code VARCHAR(255) NOT NULL,
    pin_attempts INTEGER DEFAULT 0,
    card_status TEXT CHECK(card_status IN ('ACTIVE', 'BLOCKED', 'EXPIRED')) DEFAULT 'ACTIVE',
    daily_limit DECIMAL(12,2) DEFAULT 1000.00,
    card_balance DECIMAL(12,2) DEFAULT 0.00,
    card_name VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Table structure for table 'transactions'
CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    transaction_type TEXT CHECK(transaction_type IN ('deposit', 'withdrawal', 'transfer', 'purchase')),
    amount DECIMAL(15,2) NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    approval_date DATETIME,
    account_number VARCHAR(255),
    user_id INTEGER,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Table structure for table 'transfers'
CREATE TABLE transfers (
    transfer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    from_account_id INTEGER NOT NULL,
    to_account_id INTEGER NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transfer_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (to_account_id) REFERENCES accounts(account_id)
);

-- Table structure for table 'users'
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100),
    email VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_accounts_username ON accounts(username);
CREATE INDEX idx_accounts_email ON accounts(email);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_cards_account_id ON cards(account_id);
CREATE INDEX idx_cards_number ON cards(card_number);
CREATE INDEX idx_transfers_from_account ON transfers(from_account_id);
CREATE INDEX idx_transfers_to_account ON transfers(to_account_id);

-- Create triggers to update the updated_at column in cards table
CREATE TRIGGER update_cards_timestamp 
    AFTER UPDATE ON cards
    BEGIN
        UPDATE cards SET updated_at = CURRENT_TIMESTAMP WHERE card_id = NEW.card_id;
    END;
