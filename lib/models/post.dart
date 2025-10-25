import 'package:equatable/equatable.dart';

class SocialPost extends Equatable {
  final String id;
  final String userId;
  final String content;
  final String postType;
  final String status;
  final String? username;
  final String? displayName;
  final String? platformName;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final List<String>? mediaUrls;
  final DateTime? createdAt;

  const SocialPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.postType,
    required this.status,
    this.username,
    this.displayName,
    this.platformName,
    this.gpsLatitude,
    this.gpsLongitude,
    this.mediaUrls,
    this.createdAt,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String? ?? '',
      postType: json['post_type'] as String? ?? 'text',
      status: json['status'] as String? ?? 'pending',
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      platformName: json['platform_name'] as String?,
      gpsLatitude: json['gps_latitude'] != null ? double.tryParse(json['gps_latitude'].toString()) : null,
      gpsLongitude: json['gps_longitude'] != null ? double.tryParse(json['gps_longitude'].toString()) : null,
      mediaUrls: json['media_urls'] != null ? List<String>.from(json['media_urls']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'content': content,
    'post_type': postType,
    'status': status,
    'username': username,
    'display_name': displayName,
    'platform_name': platformName,
    'gps_latitude': gpsLatitude,
    'gps_longitude': gpsLongitude,
    'media_urls': mediaUrls,
    'created_at': createdAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, userId, content, postType, status, username, displayName, platformName, gpsLatitude, gpsLongitude, mediaUrls, createdAt];
}

// UI Model for displaying posts with additional UI-specific fields
class Post {
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

  Post({
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

  // Convert from SocialPost API response to UI model
  factory Post.fromSocialPost(SocialPost socialPost) {
    final latitude = socialPost.gpsLatitude ?? 0.0;
    final longitude = socialPost.gpsLongitude ?? 0.0;
    
    return Post(
      id: socialPost.id,
      businessName: socialPost.platformName ?? 'Unknown Platform',
      username: socialPost.username ?? socialPost.displayName ?? 'Unknown User',
      description: socialPost.content,
      imageAssetPath: socialPost.mediaUrls?.isNotEmpty == true ? socialPost.mediaUrls!.first : '',
      latitude: latitude,
      longitude: longitude,
      timestamp: socialPost.createdAt ?? DateTime.now(),
      status: socialPost.status == 'pending_review' ? PostStatus.pending : PostStatus.approved,
      alertMessage: _getAlertMessage(latitude, longitude),
      alertType: _getAlertType(latitude, longitude),
    );
  }

  static String? _getAlertMessage(double lat, double lng) {
    if (lat == 0.0 && lng == 0.0) return 'Invalid GPS coordinates';
    // Add more validation logic as needed
    return null;
  }

  static AlertType? _getAlertType(double lat, double lng) {
    if (lat == 0.0 && lng == 0.0) return AlertType.error;
    // Add more validation logic as needed
    return null;
  }
}

enum PostStatus {
  pending,
  approved,
}

enum AlertType {
  error,
  warning,
}
