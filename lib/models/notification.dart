import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationModel extends Equatable {
  final String id;
  final String type;
  @JsonKey(name: 'subject')
  final String title;
  final String message;
  final String? status;
  @JsonKey(name: 'read_at')
  final DateTime? readAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'sent_at')
  final DateTime? sentAt;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'read_count')
  final int? readCountFromBackend;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.status,
    this.readAt,
    required this.createdAt,
    this.sentAt,
    this.metadata,
    this.readCountFromBackend,
  });

  bool get isRead => readAt != null;
  
  int? get recipientCount {
    if (metadata != null) {
      // Try different possible field names from backend
      if (metadata!['recipientCount'] != null) {
        return metadata!['recipientCount'] as int?;
      }
      if (metadata!['recipient_count'] != null) {
        return metadata!['recipient_count'] as int?;
      }
      if (metadata!['recipients'] != null) {
        return metadata!['recipients'] as int?;
      }
      if (metadata!['total_recipients'] != null) {
        return metadata!['total_recipients'] as int?;
      }
    }
    return null;
  }

  // Number of users who have READ this notification
  int get readCount {
    // First check if backend provided read_count directly
    if (readCountFromBackend != null) {
      return readCountFromBackend!;
    }
    
    // Fallback to metadata
    if (metadata != null) {
      // Try different possible field names from backend
      if (metadata!['readCount'] != null) {
        return metadata!['readCount'] as int? ?? 0;
      }
      if (metadata!['read_count'] != null) {
        return metadata!['read_count'] as int? ?? 0;
      }
      if (metadata!['reads'] != null) {
        return metadata!['reads'] as int? ?? 0;
      }
      if (metadata!['total_reads'] != null) {
        return metadata!['total_reads'] as int? ?? 0;
      }
    }
    return 0;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  @override
  List<Object?> get props => [id, type, title, message, status, readAt, createdAt, sentAt, metadata, readCountFromBackend];
}
