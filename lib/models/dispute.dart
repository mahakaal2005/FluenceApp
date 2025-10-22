import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dispute.g.dart';

@JsonSerializable()
class Dispute extends Equatable {
  final String id;
  final String transactionId;
  final String type;
  final String status;
  final String reason;
  final double amount;
  final DateTime createdAt;

  const Dispute({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.status,
    required this.reason,
    required this.amount,
    required this.createdAt,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) =>
      _$DisputeFromJson(json);

  Map<String, dynamic> toJson() => _$DisputeToJson(this);

  @override
  List<Object?> get props =>
      [id, transactionId, type, status, reason, amount, createdAt];
}
