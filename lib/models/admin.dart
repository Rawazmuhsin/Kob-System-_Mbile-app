// lib/models/admin.dart
class Admin {
  final int? adminId;
  final String username;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String role;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String? salt;

  Admin({
    this.adminId,
    required this.username,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.role = 'manager',
    this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.salt,
  });

  Map<String, dynamic> toMap() {
    return {
      'admin_id': adminId,
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'salt': salt,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      adminId: map['admin_id'],
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      firstName: map['first_name'],
      lastName: map['last_name'],
      role: map['role'] ?? 'manager',
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      lastLogin:
          map['last_login'] != null ? DateTime.parse(map['last_login']) : null,
      isActive: (map['is_active'] ?? 1) == 1,
      salt: map['salt'],
    );
  }

  Admin copyWith({
    int? adminId,
    String? username,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    String? salt,
  }) {
    return Admin(
      adminId: adminId ?? this.adminId,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      salt: salt ?? this.salt,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }

  @override
  String toString() {
    return 'Admin(adminId: $adminId, username: $username, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Admin && other.adminId == adminId;
  }

  @override
  int get hashCode => adminId.hashCode;
}
