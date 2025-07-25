// Account data model
class Account {
  final int? accountId;
  final String username;
  final String? email;
  final String password;
  final double balance;
  final String accountType;
  final DateTime? createdAt;
  final String phone;
  final String? accountNumber;
  final String? profileImage;
  final String? salt;

  Account({
    this.accountId,
    required this.username,
    this.email,
    required this.password,
    this.balance = 0.00,
    required this.accountType,
    this.createdAt,
    required this.phone,
    this.accountNumber,
    this.profileImage,
    this.salt,
  });

  Map<String, dynamic> toMap() {
    return {
      'account_id': accountId,
      'username': username,
      'email': email,
      'password': password,
      'balance': balance,
      'account_type': accountType,
      'created_at': createdAt?.toIso8601String(),
      'phone': phone,
      'account_number': accountNumber,
      'profile_image': profileImage,
      'salt': salt,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      accountId: map['account_id'],
      username: map['username'] ?? '',
      email: map['email'],
      password: map['password'] ?? '',
      balance: (map['balance'] ?? 0.0).toDouble(),
      accountType: map['account_type'] ?? 'Checking',
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      phone: map['phone'] ?? '',
      accountNumber: map['account_number'],
      profileImage: map['profile_image'],
      salt: map['salt'],
    );
  }

  Account copyWith({
    int? accountId,
    String? username,
    String? email,
    String? password,
    double? balance,
    String? accountType,
    DateTime? createdAt,
    String? phone,
    String? accountNumber,
    String? profileImage,
    String? salt,
  }) {
    return Account(
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      balance: balance ?? this.balance,
      accountType: accountType ?? this.accountType,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
      accountNumber: accountNumber ?? this.accountNumber,
      profileImage: profileImage ?? this.profileImage,
      salt: salt ?? this.salt,
    );
  }

  @override
  String toString() {
    return 'Account(accountId: $accountId, username: $username, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account && other.accountId == accountId;
  }

  @override
  int get hashCode => accountId.hashCode;
}
