import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction extends Equatable {
  final String id;
  final double amount;
  final String type;
  final String status;
  final String description;
  final DateTime createdAt;
  final String? campaignId;
  final Map<String, dynamic>? metadata;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    required this.createdAt,
    this.campaignId,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  @override
  List<Object?> get props => [id, amount, type, status, description, createdAt, campaignId, metadata];

  // Helper getters for UI
  String get businessName => metadata?['storeName'] ?? 'Unknown Business';
  String get customerName => metadata?['customerName'] ?? metadata?['userName'] ?? 'Unknown Customer';
  DateTime? get settlementDate {
    if (status == 'completed') {
      return createdAt.add(const Duration(days: 2));
    }
    return null;
  }
  String? get failureReason => metadata?['failureReason'];
  
  TransactionStatus get transactionStatus {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'processed': // Backend uses 'processed' for successful transactions
        return TransactionStatus.success;
      case 'pending':
        return TransactionStatus.pending;
      case 'disputed':
        return TransactionStatus.disputed;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.pending;
    }
  }
}

enum TransactionStatus {
  success,
  pending,
  disputed,
  failed,
}
