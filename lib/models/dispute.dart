import 'package:equatable/equatable.dart';

class Dispute extends Equatable {
  final String id;
  final String merchantId;
  final String? transactionId;
  final String disputeType;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? assignedTo;
  final String? resolutionNotes;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Dispute({
    required this.id,
    required this.merchantId,
    this.transactionId,
    required this.disputeType,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assignedTo,
    this.resolutionNotes,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'] as String,
      merchantId: json['merchant_id'] as String,
      transactionId: json['transaction_id'] as String?,
      disputeType: json['dispute_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      assignedTo: json['assigned_to'] as String?,
      resolutionNotes: json['resolution_notes'] as String?,
      resolvedAt: json['resolved_at'] != null 
          ? DateTime.parse(json['resolved_at'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'transaction_id': transactionId,
      'dispute_type': disputeType,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'assigned_to': assignedTo,
      'resolution_notes': resolutionNotes,
      'resolved_at': resolvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    merchantId,
    transactionId,
    disputeType,
    title,
    description,
    status,
    priority,
    assignedTo,
    resolutionNotes,
    resolvedAt,
    createdAt,
    updatedAt,
  ];
}
