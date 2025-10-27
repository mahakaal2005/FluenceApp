import 'package:equatable/equatable.dart';

class AdminActivity extends Equatable {
  final String id;
  final String type; // post_approved, post_rejected, application_approved, application_rejected, application_suspended
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String? reason;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const AdminActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.reason,
    this.notes,
    this.metadata,
  });

  factory AdminActivity.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    // Generate title and subtitle based on activity type
    String title;
    String subtitle;

    switch (type) {
      case 'post_approved':
        title = 'Post approved';
        subtitle = 'User: ${json['username'] ?? 'Unknown'} on ${json['platform'] ?? 'social media'}';
        break;
      case 'post_rejected':
        title = 'Post rejected';
        subtitle = 'User: ${json['username'] ?? 'Unknown'} - ${json['reason'] ?? 'No reason provided'}';
        break;
      case 'application_approved':
        title = 'Application approved';
        subtitle = '${json['businessName'] ?? 'Unknown Business'} - ${json['contactPerson'] ?? 'Unknown'}';
        break;
      case 'application_rejected':
        title = 'Application rejected';
        subtitle = '${json['businessName'] ?? 'Unknown Business'} - ${json['reason'] ?? 'No reason provided'}';
        break;
      case 'application_suspended':
        title = 'Merchant suspended';
        subtitle = '${json['businessName'] ?? 'Unknown Business'} - ${json['reason'] ?? 'No reason provided'}';
        break;
      default:
        title = 'Admin action';
        subtitle = type;
    }

    return AdminActivity(
      id: json['id'] as String,
      type: type,
      title: title,
      subtitle: subtitle,
      timestamp: DateTime.parse(json['verifiedAt'] ?? json['createdAt'] as String),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      metadata: json,
    );
  }

  /// Get icon path based on activity type
  String get iconPath {
    switch (type) {
      case 'post_approved':
        return 'assets/images/activity_icon_2.png'; // Post icon
      case 'post_rejected':
        return 'assets/images/activity_icon_3.png'; // Rejection icon
      case 'application_approved':
        return 'assets/images/activity_icon_1.png'; // User icon
      case 'application_rejected':
      case 'application_suspended':
        return 'assets/images/activity_icon_3.png'; // Rejection icon
      default:
        return 'assets/images/activity_icon_1.png';
    }
  }

  /// Get icon background color based on activity type
  String get iconBgColor {
    switch (type) {
      case 'post_approved':
      case 'application_approved':
        return 'green'; // Success color
      case 'post_rejected':
      case 'application_rejected':
      case 'application_suspended':
        return 'red'; // Error/rejection color
      default:
        return 'yellow';
    }
  }

  @override
  List<Object?> get props => [id, type, title, subtitle, timestamp, reason, notes];
}
