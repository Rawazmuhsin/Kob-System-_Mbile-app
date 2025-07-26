import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'banking_app.db');

    return await openDatabase(
      path,
      version: 2, // Increment version for schema changes
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onOpen: (db) async {
        // Enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create accounts table (PRIMARY USER DATA SOURCE)
    await db.execute('''
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
      )
    ''');

    // Create admin table
    await db.execute('''
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
      )
    ''');

    // Create cards table (SYSTEM CARD TEMPLATES ONLY)
    await db.execute('''
      CREATE TABLE cards (
        card_id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name VARCHAR(50) NOT NULL,
        card_type TEXT CHECK(card_type IN ('DEBIT', 'CREDIT', 'PREPAID')) NOT NULL,
        card_usage_type TEXT CHECK(card_usage_type IN ('PHYSICAL', 'ONLINE', 'PHONE', 'INTERNET')) NOT NULL,
        default_daily_limit DECIMAL(12,2) DEFAULT 1000.00,
        default_monthly_limit DECIMAL(12,2) DEFAULT 10000.00,
        card_description TEXT,
        card_features TEXT,
        purchase_fee DECIMAL(10,2) DEFAULT 0.00,
        annual_fee DECIMAL(10,2) DEFAULT 0.00,
        card_image_url VARCHAR(255),
        is_available INTEGER DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create purchase_cards table (USER-PURCHASED CARDS)
    await db.execute('''
      CREATE TABLE purchase_cards (
        purchase_card_id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        card_id INTEGER NOT NULL,
        user_card_number VARCHAR(16) NOT NULL UNIQUE,
        card_holder_name VARCHAR(100) NOT NULL,
        expiry_date DATE NOT NULL,
        cvv VARCHAR(3) NOT NULL,
        pin_code VARCHAR(255) NOT NULL,
        pin_attempts INTEGER DEFAULT 0,
        card_status TEXT CHECK(card_status IN ('ACTIVE', 'BLOCKED', 'EXPIRED', 'PENDING')) DEFAULT 'PENDING',
        daily_limit DECIMAL(12,2) DEFAULT 1000.00,
        monthly_limit DECIMAL(12,2) DEFAULT 10000.00,
        card_balance DECIMAL(12,2) DEFAULT 0.00,
        card_nickname VARCHAR(50),
        purchase_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        activation_date DATETIME,
        last_used DATETIME,
        delivery_address TEXT,
        delivery_status TEXT CHECK(delivery_status IN ('PENDING', 'SHIPPED', 'DELIVERED', 'CANCELLED')) DEFAULT 'PENDING',
        delivery_date DATETIME,
        purchase_fee DECIMAL(10,2) DEFAULT 0.00,
        annual_fee DECIMAL(10,2) DEFAULT 0.00,
        is_primary_card INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (account_id) REFERENCES accounts(account_id),
        FOREIGN KEY (card_id) REFERENCES cards(card_id)
      )
    ''');

    // Create transactions table (ALL FINANCIAL TRANSACTIONS)
    await db.execute('''
      CREATE TABLE transactions (
        transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        transaction_type TEXT CHECK(transaction_type IN ('deposit', 'withdrawal', 'transfer', 'purchase', 'card_payment')) NOT NULL,
        amount DECIMAL(15,2) NOT NULL,
        transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        description VARCHAR(255),
        status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
        approval_date DATETIME,
        recipient_account_number VARCHAR(255),
        purchase_card_id INTEGER,
        reference_number VARCHAR(100),
        FOREIGN KEY (account_id) REFERENCES accounts(account_id),
        FOREIGN KEY (purchase_card_id) REFERENCES purchase_cards(purchase_card_id)
      )
    ''');

    // Create transfers table (DETAILED TRANSFER INFO)
    await db.execute('''
      CREATE TABLE transfers (
        transfer_id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
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
      )
    ''');

    // Create beneficiaries table
    await db.execute('''
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
      )
    ''');

    // Create notifications table
    await db.execute('''
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
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_accounts_username ON accounts(username)',
    );
    await db.execute('CREATE INDEX idx_accounts_email ON accounts(email)');
    await db.execute(
      'CREATE INDEX idx_accounts_account_number ON accounts(account_number)',
    );

    await db.execute('CREATE INDEX idx_cards_type ON cards(card_type)');
    await db.execute('CREATE INDEX idx_cards_available ON cards(is_available)');

    await db.execute(
      'CREATE INDEX idx_purchase_cards_account_id ON purchase_cards(account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_purchase_cards_card_number ON purchase_cards(user_card_number)',
    );
    await db.execute(
      'CREATE INDEX idx_purchase_cards_status ON purchase_cards(card_status)',
    );

    await db.execute(
      'CREATE INDEX idx_transactions_account_id ON transactions(account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_date ON transactions(transaction_date)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_type ON transactions(transaction_type)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_status ON transactions(status)',
    );

    await db.execute(
      'CREATE INDEX idx_transfers_from_account ON transfers(from_account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transfers_to_account ON transfers(to_account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transfers_transaction ON transfers(transaction_id)',
    );

    await db.execute(
      'CREATE INDEX idx_beneficiaries_account_id ON beneficiaries(account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_notifications_account_id ON notifications(account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_notifications_read ON notifications(is_read)',
    );

    // Create triggers for updating timestamps
    await db.execute('''
      CREATE TRIGGER update_cards_timestamp 
        AFTER UPDATE ON cards
        BEGIN
          UPDATE cards SET updated_at = CURRENT_TIMESTAMP WHERE card_id = NEW.card_id;
        END
    ''');

    await db.execute('''
      CREATE TRIGGER update_purchase_cards_timestamp 
        AFTER UPDATE ON purchase_cards
        BEGIN
          UPDATE purchase_cards SET updated_at = CURRENT_TIMESTAMP 
          WHERE purchase_card_id = NEW.purchase_card_id;
        END
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Handle migration from old schema to new schema
      // You might want to backup existing data before dropping tables

      // Drop old tables that are no longer needed
      await db.execute('DROP TABLE IF EXISTS users');

      // Recreate with new schema
      await _createDatabase(db, newVersion);
    }
  }

  // Generic CRUD operations (same as before)
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
