import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post extends Equatable {
  final String transactionId;
  final String userId;
  final String platform;
  final String postUrl;
  final String status;

  const Post({
    required this.transactionId,
    required this.userId,
    required this.platform,
    required this.postUrl,
    required this.status,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);

  @override
  List<Object?> get props => [transactionId, userId, platform, postUrl, status];
}

// UI Model for displaying posts with additional UI-specific fields
class PostUI {
  final String id;
  final String businessName;
  final String username;
  final String description;
  final String imageAssetPath;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final PostStatus status;
  final String? alertMessage;
  final AlertType? alertType;

  PostUI({
    required this.id,
    required this.businessName,
    required this.username,
    required this.description,
    required this.imageAssetPath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
    this.alertMessage,
    this.alertType,
  });
}

enum PostStatus {
  pending,
  approved,
}

enum AlertType {
  error,
  warning,
}
