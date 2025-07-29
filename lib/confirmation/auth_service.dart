import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../core/db_helper.dart';
import '../models/account.dart';
import '../models/admin.dart';
import '../services/admin_service.dart';

enum UserType { user, admin, unknown }

class AuthResult {
  final bool success;
  final UserType userType;
  final Account? account;
  final Admin? admin;
  final String? errorMessage;

  AuthResult({
    required this.success,
    required this.userType,
    this.account,
    this.admin,
    this.errorMessage,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  AuthService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AdminService _adminService = AdminService.instance;

  // Generate salt for password hashing
  String _generateSalt() {
    final bytes = utf8.encode(DateTime.now().millisecondsSinceEpoch.toString());
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  // Hash password with salt
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  // Generate unique account number
  String _generateAccountNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'KOB${timestamp.toString().substring(5)}';
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone format
  bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  Future<bool> updateAccountInfo({
    required int accountId,
    required String username,
    required String email,
    required String phone,
  }) async {
    try {
      print('=== UPDATING ACCOUNT INFO ===');
      print('Account ID: $accountId');
      print('New Username: $username');
      print('New Email: $email');
      print('New Phone: $phone');

      // Validate inputs using existing methods
      if (!isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      if (!isValidPhone(phone)) {
        throw Exception('Invalid phone number format');
      }

      // Check if new email already exists for a different account
      final existingUserType = await detectUserType(email);
      if (existingUserType != UserType.unknown) {
        // Check if this email belongs to the current account
        final currentAccount = await getAccountById(accountId);
        if (currentAccount == null ||
            currentAccount.email?.toLowerCase() != email.toLowerCase()) {
          throw Exception('Email already exists in system');
        }
      }

      // Update account data
      final result = await _dbHelper.update(
        'accounts',
        {
          'username': username.trim(),
          'email': email.toLowerCase().trim(),
          'phone': phone.trim(),
        },
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      if (result > 0) {
        print('✅ Account info updated successfully');
        return true;
      } else {
        print('❌ Failed to update account info');
        return false;
      }
    } catch (e) {
      print('❌ Update account info error: $e');
      throw Exception('Update account info error: $e');
    }
  }

  // Validate strong password
  bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  // Detect user type by email - NEW METHOD
  Future<UserType> detectUserType(String email) async {
    try {
      print('=== DETECTING USER TYPE ===');
      print('Email: $email');

      // Check admin table first
      final adminExists = await _adminService.adminEmailExists(email);
      if (adminExists) {
        print('✅ Email found in ADMIN table');
        return UserType.admin;
      }

      // Check user accounts table
      final userExists = await emailExists(email);
      if (userExists) {
        print('✅ Email found in USER table');
        return UserType.user;
      }

      print('❌ Email not found in any table');
      return UserType.unknown;
    } catch (e) {
      print('❌ Error detecting user type: $e');
      return UserType.unknown;
    }
  }

  // Universal authentication method - NEW METHOD
  Future<AuthResult> authenticateUser(String email, String password) async {
    try {
      print('=== UNIVERSAL AUTHENTICATION ===');
      print('Email: $email');

      // First detect user type
      final userType = await detectUserType(email);

      switch (userType) {
        case UserType.admin:
          print('🔐 Attempting ADMIN authentication...');
          final admin = await _adminService.authenticateAdmin(email, password);
          if (admin != null) {
            return AuthResult(
              success: true,
              userType: UserType.admin,
              admin: admin,
            );
          } else {
            return AuthResult(
              success: false,
              userType: UserType.admin,
              errorMessage: 'Invalid admin credentials',
            );
          }

        case UserType.user:
          print('👤 Attempting USER authentication...');
          final account = await authenticate(email, password);
          if (account != null) {
            return AuthResult(
              success: true,
              userType: UserType.user,
              account: account,
            );
          } else {
            return AuthResult(
              success: false,
              userType: UserType.user,
              errorMessage: 'Invalid user credentials',
            );
          }

        case UserType.unknown:
          return AuthResult(
            success: false,
            userType: UserType.unknown,
            errorMessage: 'Email not found in system',
          );
      }
    } catch (e) {
      print('❌ Universal authentication error: $e');
      return AuthResult(
        success: false,
        userType: UserType.unknown,
        errorMessage: 'Authentication error: $e',
      );
    }
  }

  // Check if email already exists in user table - WITH BETTER ERROR HANDLING
  Future<bool> emailExists(String email) async {
    try {
      print('=== CHECKING USER EMAIL IN DATABASE ===');
      print('Email to check: $email');

      final accounts = await _dbHelper.query(
        'accounts',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      print('Query executed successfully');
      print('Found ${accounts.length} user accounts with this email');
      print('=================================');

      return accounts.isNotEmpty;
    } catch (e) {
      print('❌ Error checking user email existence: $e');
      print('Database might not be initialized properly');

      // Return false to allow registration to continue
      return false;
    }
  }

  // Authenticate user credentials (legacy method, still used internally) - WITH DEBUG PRINTS
  Future<Account?> authenticate(String email, String password) async {
    try {
      print('=== USER LOGIN DEBUG ===');
      print('Trying to login user with email: $email');
      print('Trying to login user with password: $password');

      final accounts = await _dbHelper.query(
        'accounts',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      print('Found ${accounts.length} user accounts with this email');

      if (accounts.isEmpty) {
        print('❌ No user account found with email: $email');
        return null; // Email not found
      }

      final accountData = accounts.first;
      final salt = accountData['salt'] as String? ?? '';
      final storedHashedPassword = accountData['password'] as String;
      final hashedPassword = _hashPassword(password, salt);

      print('User stored salt: $salt');
      print('User stored hashed password: $storedHashedPassword');
      print('User new hashed password: $hashedPassword');
      print('User passwords match: ${hashedPassword == storedHashedPassword}');
      print('==================');

      if (hashedPassword == storedHashedPassword) {
        print('✅ User login successful!');
        return Account.fromMap(accountData);
      }

      print('❌ User password mismatch!');
      return null; // Password doesn't match
    } catch (e) {
      print('❌ User authentication error: $e');
      throw Exception('User authentication error: $e');
    }
  }

  // Create new user account - WITH IMPROVED ERROR HANDLING
  Future<Account?> createAccount({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String accountType,
  }) async {
    try {
      print('=== USER ACCOUNT CREATION DEBUG ===');
      print('Creating user account for: $email');

      // Validate inputs
      if (!isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      if (!isValidPhone(phone)) {
        throw Exception('Invalid phone number format');
      }

      if (!isStrongPassword(password)) {
        throw Exception(
          'Password must be at least 8 characters with uppercase, lowercase, and number',
        );
      }

      // Check if email already exists in ANY table
      final userType = await detectUserType(email);
      if (userType != UserType.unknown) {
        throw Exception('Email already exists in system');
      }

      // Generate salt and hash password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);
      final accountNumber = _generateAccountNumber();

      print('Salt: $salt');
      print('Hashed Password: $hashedPassword');
      print('Account Number: $accountNumber');

      // Create account data
      final accountData = {
        'username': username.trim(),
        'email': email.toLowerCase().trim(),
        'password': hashedPassword,
        'balance': 0.0,
        'account_type': accountType,
        'phone': phone.trim(),
        'account_number': accountNumber,
        'salt': salt,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Inserting user account data into database...');

      // Insert into database
      final accountId = await _dbHelper.insert('accounts', accountData);

      if (accountId > 0) {
        print('✅ User account created with ID: $accountId');

        // Return the created account
        return Account.fromMap({'account_id': accountId, ...accountData});
      }

      throw Exception(
        'Failed to create user account - database insert returned 0',
      );
    } catch (e) {
      print('❌ User account creation error: $e');
      throw Exception('User account creation error: $e');
    }
  }

  // Reset password method (works for both users and admins)
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      // Validate new password
      if (!isStrongPassword(newPassword)) {
        throw Exception(
          'Password must be at least 8 characters with uppercase, lowercase, and number',
        );
      }

      final userType = await detectUserType(email);

      if (userType == UserType.unknown) {
        throw Exception('Email not found in system');
      }

      // Generate new salt and hash new password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(newPassword, salt);

      print('=== PASSWORD RESET DEBUG ===');
      print('Email: $email');
      print('User Type: $userType');
      print('New Password: $newPassword');
      print('New Salt: $salt');
      print('New Hashed Password: $hashedPassword');
      print('============================');

      int result = 0;

      if (userType == UserType.user) {
        // Update user password in accounts table
        result = await _dbHelper.update(
          'accounts',
          {'password': hashedPassword, 'salt': salt},
          where: 'email = ?',
          whereArgs: [email.toLowerCase().trim()],
        );
      } else if (userType == UserType.admin) {
        // Update admin password in admin table
        result = await _dbHelper.update(
          'admin',
          {'password': hashedPassword, 'salt': salt},
          where: 'email = ?',
          whereArgs: [email.toLowerCase().trim()],
        );
      }

      if (result > 0) {
        print('✅ Password reset successful for $userType');
        return true;
      } else {
        print('❌ Password reset failed for $userType');
        return false;
      }
    } catch (e) {
      print('❌ Password reset error: $e');
      throw Exception('Password reset error: $e');
    }
  }

  // Initialize system (create default admin if needed)
  Future<void> initializeSystem() async {
    try {
      await _adminService.createDefaultAdmin();
    } catch (e) {
      print('❌ Error initializing system: $e');
    }
  }

  // Update account balance
  Future<bool> updateAccountBalance(int accountId, double newBalance) async {
    try {
      final result = await _dbHelper.update(
        'accounts',
        {'balance': newBalance},
        where: 'account_id = ?',
        whereArgs: [accountId],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Error updating balance: $e');
    }
  }

  // Get account by ID
  Future<Account?> getAccountById(int accountId) async {
    try {
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      if (accounts.isNotEmpty) {
        return Account.fromMap(accounts.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error retrieving account: $e');
    }
  }

  // Get account by email
  Future<Account?> getAccountByEmail(String email) async {
    try {
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      if (accounts.isNotEmpty) {
        return Account.fromMap(accounts.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error retrieving account: $e');
    }
  }

  // Close database connection
  Future<void> closeDatabase() async {
    try {
      await _dbHelper.close();
    } catch (e) {
      print('Error closing database: $e');
    }
  }
}
