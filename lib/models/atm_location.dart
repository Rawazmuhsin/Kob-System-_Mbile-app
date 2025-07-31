// lib/models/atm_location.dart
class ATMLocation {
  final String id;
  final String name;
  final String address;
  final String status;
  final bool isActive;

  ATMLocation({
    required this.id,
    required this.name,
    required this.address,
    this.status = 'Online',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'status': status,
      'isActive': isActive,
    };
  }

  factory ATMLocation.fromMap(Map<String, dynamic> map) {
    return ATMLocation(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      status: map['status'] ?? 'Online',
      isActive: map['isActive'] ?? true,
    );
  }
}
