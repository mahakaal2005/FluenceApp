import 'package:equatable/equatable.dart';

class RecentActivity extends Equatable {
  final String title;
  final String subtitle;
  final String time;
  final String iconPath;
  final String iconBgColor;
  final String? entityId; // ID of the post/user/merchant
  final String? entityType; // 'post', 'user', 'merchant'
  final String? status; // 'pending', 'approved', 'rejected'
  final Map<String, dynamic>? entityData; // Full entity data for review
  final DateTime? occurredAt;

  const RecentActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.iconPath,
    required this.iconBgColor,
    this.entityId,
    this.entityType,
    this.status,
    this.entityData,
    this.occurredAt,
  });

  bool get isPending {
    if (status == null) return false;
    final lowerStatus = status!.toLowerCase();
    return lowerStatus == 'pending' ||
        lowerStatus == 'pending_review' ||
        lowerStatus == 'disputed' ||
        lowerStatus == 'scheduled';
  }

  @override
  List<Object?> get props => [
        title,
        subtitle,
        time,
        iconPath,
        iconBgColor,
        entityId,
        entityType,
        status,
        entityData,
        occurredAt,
      ];
}

