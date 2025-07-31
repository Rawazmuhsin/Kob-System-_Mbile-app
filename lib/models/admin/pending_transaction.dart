// lib/models/admin/pending_transaction.dart
class PendingTransaction {
  final int transactionId;
  final int accountId;
  final String username;
  final String accountNumber;
  final String transactionType;
  final double amount;
  final DateTime transactionDate;
  final String description;
  final String status;

  PendingTransaction({
    required this.transactionId,
    required this.accountId,
    required this.username,
    required this.accountNumber,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    required this.description,
    required this.status,
  });

  factory PendingTransaction.fromMap(Map<String, dynamic> map) {
    return PendingTransaction(
      transactionId: map['transaction_id'],
      accountId: map['account_id'],
      username: map['username'] ?? 'Unknown',
      accountNumber: map['account_number'] ?? 'Unknown',
      transactionType: map['transaction_type'] ?? 'Unknown',
      amount: (map['amount'] ?? 0.0).toDouble(),
      transactionDate:
          map['transaction_date'] != null
              ? DateTime.parse(map['transaction_date'])
              : DateTime.now(),
      description: map['description'] ?? '',
      status: map['status'] ?? 'PENDING',
    );
  }
}
