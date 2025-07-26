🏦 KOB Banking App (Kurdish-O-Banking)

Your Future, Your Bank - A modern, secure mobile banking application built with Flutter

📱 Overview
KOB Banking is a comprehensive mobile banking application that provides users with secure, convenient banking services. Built with Flutter for cross-platform compatibility, the app offers a modern UI with dark/light theme support and follows Material Design 3 principles.
✨ Features
🔐 Authentication & Security

Secure Account Registration with email verification simulation
Password Strength Validation with real-time feedback
Encrypted Password Storage using SHA-256 hashing with salt
Forgot Password Recovery with step-by-step verification
Biometric Authentication Support (Touch ID, Face ID, PIN)

💰 Banking Operations

Real-time Balance Display with visibility toggle
Quick Deposit & Withdrawal with validation
Money Transfers between accounts
Transaction History with detailed records
Account Management (Checking & Savings accounts)

📊 Dashboard & Analytics

Personalized Dashboard with user information
Account Summary with statistics
Recent Transactions overview
Quick Action Buttons for common operations
Balance Cards with account details

🎨 User Interface

Modern Design following Material Design 3
Dark/Light Theme support with system detection
Responsive Layout optimized for mobile devices
Smooth Animations and transitions
Clean Navigation with drawer menu

🗄️ Data Management

SQLite Database for local data storage
Secure Data Handling with proper encryption
Transaction Logging for audit trails
Account Statistics and reporting

🛠️ Technology Stack
Frontend

Flutter 3.7.2+ - Cross-platform mobile framework
Dart - Programming language
Material Design 3 - UI/UX design system
Provider - State management

Database

SQLite - Local database storage
Sqflite - Flutter SQLite plugin

Security

Crypto - Password hashing and encryption
Salt-based Hashing - Enhanced password security

Dependencies
yamldependencies:
  flutter: sdk: flutter
  provider: ^6.1.1          # State management
  sqflite: ^2.3.0           # Database
  crypto: ^3.0.3            # Encryption
  shared_preferences: ^2.2.2 # Local storage
  http: ^1.1.0              # HTTP requests
  flutter_svg: ^2.0.9       # SVG support
  qr_flutter: ^4.1.0        # QR code generation
  pdf: ^3.10.7              # PDF generation
  csv: ^5.0.2               # CSV handling
  image_picker: ^1.0.4      # Image selection
  path_provider: ^2.1.1     # File path handling
  permission_handler: ^11.0.1 # Permissions
📁 Project Structure
lib/
├── confirmation/           # Authentication services
│   ├── auth_service.dart
│   ├── login/
│   ├── signup/
│   └── forgot_password/
├── core/                  # Core utilities
│   ├── constants.dart
│   ├── db_helper.dart
│   └── utils.dart
├── models/               # Data models
│   ├── account.dart
│   ├── transaction.dart
│   └── user.dart
├── providers/           # State management
│   ├── auth_provider.dart
│   ├── dashboard_provider.dart
│   ├── theme_provider.dart
│   └── forgot_password_provider.dart
├── routes/             # Navigation
│   └── app_routes.dart
├── screens/           # UI screens
│   ├── auth/
│   ├── dashboard/
│   └── welcome_screen.dart
├── services/         # Business logic services
│   └── dashboard_service.dart
└── widgets/         # Reusable UI components
    ├── dashboard/
    ├── app_logo.dart
    ├── custom_button.dart
    ├── input_field.dart
    └── navigation_drawer.dart
🚀 Getting Started
Prerequisites

Flutter SDK (3.7.2 or higher)
Dart SDK (2.19.0 or higher)
Android Studio / VS Code with Flutter extensions
iOS Simulator / Android Emulator

Installation

Clone the repository
bashgit clone https://github.com/yourusername/kob-banking-app.git
cd kob-banking-app

Install dependencies
bashflutter pub get

Run the application
bashflutter run

Build for production
bash# Android
flutter build apk --release

# iOS
flutter build ios --release


📊 Database Schema
The app uses SQLite with the following main tables:
accounts

User account information
Encrypted passwords with salt
Account types (Checking/Savings)
Balance and personal details

transactions

All financial transactions
Transaction types and status
Amount and timestamps
Reference numbers

cards (System Templates)

Available card types
Default limits and features
Card descriptions and fees

purchase_cards (User Cards)

User-purchased cards
Card details and status
Personal limits and settings

transfers

Detailed transfer information
Transfer types and fees
Recipient details

🔧 Configuration
Theme Configuration
The app supports automatic theme switching based on system preferences:
dart// Light Theme
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  // ... theme configuration
);

// Dark Theme  
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  // ... theme configuration
);
Database Configuration
Database initialization happens automatically on app startup:
dart// Database version and migration handling
Future<Database> _initDatabase() async {
  String path = join(await getDatabasesPath(), 'banking_app.db');
  return await openDatabase(path, version: 3, onCreate: _createDatabase);
}
🧪 Testing
Running Tests
bash# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
Test Structure
test/
├── unit/
│   ├── services/
│   ├── providers/
│   └── models/
├── widget/
│   ├── screens/
│   └── widgets/
└── integration/
    └── app_test.dart
🔒 Security Features

Password Hashing: SHA-256 with unique salt per user
Data Encryption: Sensitive data encrypted in database
Input Validation: Comprehensive validation for all user inputs
Session Management: Secure session handling
Biometric Support: Touch ID, Face ID, and PIN authentication

📱 Supported Platforms

✅ Android 5.0+ (API level 21+)
✅ iOS 11.0+
✅ Portrait Orientation (optimized)

🎨 Design System
Color Palette

Primary Dark: #1F2937
Primary Green: #10B981
Primary Amber: #F59E0B
Light Surface: #F1F5F9
Dark Surface: #0F172A

Typography

Font Family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto
Responsive Text Scaling: Disabled for consistent UI

🤝 Contributing

Fork the repository
Create a feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

Coding Standards

Follow Dart Style Guide
Use meaningful variable and function names
Add comments for complex logic
Write tests for new features

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
👥 Authors

Developer Name - Initial work - GitHub Profile

🙏 Acknowledgments

Flutter team for the amazing framework
Material Design team for design guidelines
SQLite for reliable local database
Community contributors and testers

📞 Support
For support, email support@kob-banking.com or create an issue in this repository.
🗺️ Roadmap
Version 2.0 (Planned)

 Real-time notifications
 Card management system
 Advanced analytics
 Multi-language support
 Biometric payment authorization
 QR code payments
 Export statements (PDF/CSV)

Version 3.0 (Future)

 Integration with real banking APIs
 Investment portfolio tracking
 Budgeting and expense tracking
 AI-powered financial insights
 Web dashboard
 Admin panel


Made with ❤️ using Flutter | © 2025 Kurdish-O-Banking (KOB)
