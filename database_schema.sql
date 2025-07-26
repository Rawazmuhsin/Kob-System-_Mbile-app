-- SQLite Database Schema for Banking App
-- Updated: Based on requirements discussion
-- Created: July 26, 2025

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Table structure for table 'accounts' (PRIMARY USER DATA SOURCE)
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

-- Table structure for table 'cards' (SYSTEM CARD TEMPLATES ONLY)
CREATE TABLE cards (
    card_id INTEGER PRIMARY KEY AUTOINCREMENT,
    card_name VARCHAR(50) NOT NULL, -- e.g., "KOB Gold Card", "KOB Student Card"
    card_type TEXT CHECK(card_type IN ('DEBIT', 'CREDIT', 'PREPAID')) NOT NULL,
    card_usage_type TEXT CHECK(card_usage_type IN ('PHYSICAL', 'ONLINE', 'PHONE', 'INTERNET')) NOT NULL,
    default_daily_limit DECIMAL(12,2) DEFAULT 1000.00,
    default_monthly_limit DECIMAL(12,2) DEFAULT 10000.00,
    card_description TEXT,
    card_features TEXT, -- JSON or comma-separated features
    purchase_fee DECIMAL(10,2) DEFAULT 0.00,
    annual_fee DECIMAL(10,2) DEFAULT 0.00,
    card_image_url VARCHAR(255),
    is_available INTEGER DEFAULT 1, -- Whether this card type is available for purchase
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table structure for table 'purchase_cards' (USER-PURCHASED CARDS)
CREATE TABLE purchase_cards (
    purchase_card_id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    card_id INTEGER NOT NULL, -- References system card from cards table
    user_card_number VARCHAR(16) NOT NULL UNIQUE,
    card_holder_name VARCHAR(100) NOT NULL,
    expiry_date DATE NOT NULL,
    cvv VARCHAR(3) NOT NULL,
    pin_code VARCHAR(255) NOT NULL, -- Encrypted PIN
    pin_attempts INTEGER DEFAULT 0,
    card_status TEXT CHECK(card_status IN ('ACTIVE', 'BLOCKED', 'EXPIRED', 'PENDING')) DEFAULT 'PENDING',
    daily_limit DECIMAL(12,2) DEFAULT 1000.00,
    monthly_limit DECIMAL(12,2) DEFAULT 10000.00,
    card_balance DECIMAL(12,2) DEFAULT 0.00,
    card_nickname VARCHAR(50), -- User can give custom name
    purchase_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    activation_date DATETIME,
    last_used DATETIME,
    delivery_address TEXT,
    delivery_status TEXT CHECK(delivery_status IN ('PENDING', 'SHIPPED', 'DELIVERED', 'CANCELLED')) DEFAULT 'PENDING',
    delivery_date DATETIME,
    purchase_fee DECIMAL(10,2) DEFAULT 0.00,
    annual_fee DECIMAL(10,2) DEFAULT 0.00,
    is_primary_card INTEGER DEFAULT 0, -- If user has multiple cards
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (card_id) REFERENCES cards(card_id)
);

-- Table structure for table 'transactions' (ALL FINANCIAL TRANSACTIONS)
CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    transaction_type TEXT CHECK(transaction_type IN ('deposit', 'withdrawal', 'transfer', 'purchase', 'card_payment')) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    approval_date DATETIME,
    recipient_account_number VARCHAR(255), -- For transfers
    purchase_card_id INTEGER, -- For card payments, references purchase_cards
    reference_number VARCHAR(100), -- Transaction reference
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (purchase_card_id) REFERENCES purchase_cards(purchase_card_id)
);

-- Table structure for table 'transfers' (DETAILED TRANSFER INFO)
CREATE TABLE transfers (
    transfer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaction_id INTEGER NOT NULL, -- Links to main transaction record
    from_account_id INTEGER NOT NULL,
    to_account_id INTEGER NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transfer_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    transfer_type TEXT CHECK(transfer_type IN ('internal', 'external', 'wire')) DEFAULT 'internal',
    transfer_fee DECIMAL(10,2) DEFAULT 0.00,
    recipient_name VARCHAR(100),
    recipient_bank VARCHAR(100),
    notes TEXT,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (from_account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (to_account_id) REFERENCES accounts(account_id)
);

-- Table structure for beneficiaries (frequent transfer recipients)
CREATE TABLE beneficiaries (
    beneficiary_id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    beneficiary_name VARCHAR(100) NOT NULL,
    beneficiary_account_number VARCHAR(255) NOT NULL,
    beneficiary_bank VARCHAR(100),
    nickname VARCHAR(50),
    is_favorite INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_used DATETIME,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Table for notifications/alerts
CREATE TABLE notifications (
    notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type TEXT CHECK(notification_type IN ('transaction', 'security', 'promotional', 'system')) NOT NULL,
    is_read INTEGER DEFAULT 0,
    priority TEXT CHECK(priority IN ('low', 'medium', 'high')) DEFAULT 'medium',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    read_at DATETIME,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Create indexes for better performance
CREATE INDEX idx_accounts_username ON accounts(username);
CREATE INDEX idx_accounts_email ON accounts(email);
CREATE INDEX idx_accounts_account_number ON accounts(account_number);

CREATE INDEX idx_cards_type ON cards(card_type);
CREATE INDEX idx_cards_available ON cards(is_available);

CREATE INDEX idx_purchase_cards_account_id ON purchase_cards(account_id);
CREATE INDEX idx_purchase_cards_card_number ON purchase_cards(user_card_number);
CREATE INDEX idx_purchase_cards_status ON purchase_cards(card_status);

CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_transactions_status ON transactions(status);

CREATE INDEX idx_transfers_from_account ON transfers(from_account_id);
CREATE INDEX idx_transfers_to_account ON transfers(to_account_id);
CREATE INDEX idx_transfers_transaction ON transfers(transaction_id);

CREATE INDEX idx_beneficiaries_account_id ON beneficiaries(account_id);
CREATE INDEX idx_notifications_account_id ON notifications(account_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);

-- Create triggers to update timestamps
CREATE TRIGGER update_cards_timestamp 
    AFTER UPDATE ON cards
    BEGIN
        UPDATE cards SET updated_at = CURRENT_TIMESTAMP WHERE card_id = NEW.card_id;
    END;

CREATE TRIGGER update_purchase_cards_timestamp 
    AFTER UPDATE ON purchase_cards
    BEGIN
        UPDATE purchase_cards SET updated_at = CURRENT_TIMESTAMP 
        WHERE purchase_card_id = NEW.purchase_card_id;
    END;