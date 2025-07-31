class Transaction {
  final int? transactionId;
  final int accountId;
  final String? transactionType;
  final double amount;
  final DateTime? transactionDate;
  final String? description;
  final String status;
  final DateTime? approvalDate;
  final String? accountNumber;
  final int? userId;

  Transaction({
    this.transactionId,
    required this.accountId,
    this.transactionType,
    required this.amount,
    this.transactionDate,
    this.description,
    this.status = 'PENDING',
    this.approvalDate,
    this.accountNumber,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'transaction_id': transactionId,
      'account_id': accountId,
      'transaction_type': transactionType,
      'amount': amount,
      'transaction_date': transactionDate?.toIso8601String(),
      'description': description,
      'status': status,
      'approval_date': approvalDate?.toIso8601String(),
      'recipient_account_number': accountNumber,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      transactionId: map['transaction_id'],
      accountId: map['account_id'] ?? 0,
      transactionType: map['transaction_type'],
      amount: (map['amount'] ?? 0.0).toDouble(),
      transactionDate:
          map['transaction_date'] != null
              ? DateTime.parse(map['transaction_date'])
              : null,
      description: map['description'],
      status: map['status'] ?? 'PENDING',
      approvalDate:
          map['approval_date'] != null
              ? DateTime.parse(map['approval_date'])
              : null,
      accountNumber: map['recipient_account_number'],
      userId: map['user_id'],
    );
  }

  Transaction copyWith({
    int? transactionId,
    int? accountId,
    String? transactionType,
    double? amount,
    DateTime? transactionDate,
    String? description,
    String? status,
    DateTime? approvalDate,
    String? accountNumber,
    int? userId,
  }) {
    return Transaction(
      transactionId: transactionId ?? this.transactionId,
      accountId: accountId ?? this.accountId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      description: description ?? this.description,
      status: status ?? this.status,
      approvalDate: approvalDate ?? this.approvalDate,
      accountNumber: accountNumber ?? this.accountNumber,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $transactionId, type: $transactionType, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.transactionId == transactionId;
  }

  @override
  int get hashCode => transactionId.hashCode;
}
