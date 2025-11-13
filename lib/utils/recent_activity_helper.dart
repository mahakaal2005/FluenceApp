import '../models/admin_activity.dart';
import '../models/notification.dart';
import '../models/recent_activity.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../utils/app_constants.dart';

class RecentActivityHelper {
  static List<RecentActivity> generateActivities({
    required Map<String, dynamic> usersData,
    required Map<String, dynamic> postsData,
    required Map<String, dynamic> transactionsData,
    required Map<String, dynamic> notificationsData,
    required Map<String, dynamic> adminActivitiesData,
    int? maxActivities,
    bool condensed = false,
  }) {
    final activities = <RecentActivity>[];

    activities.addAll(_buildAdminActivities(adminActivitiesData, condensed));
    activities.addAll(_buildUserActivities(usersData, condensed));
    activities.addAll(_buildPostActivities(postsData, condensed));
    activities.addAll(_buildMerchantActivities(usersData, condensed));
    activities.addAll(_buildTransactionActivities(transactionsData, condensed));
    activities.addAll(_buildNotificationActivities(notificationsData, condensed));

    activities.sort((a, b) {
      final timeA = a.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA);
    });

    if (maxActivities != null && activities.length > maxActivities) {
      return activities.take(maxActivities).toList();
    }

    return activities;
  }

  static Iterable<RecentActivity> _buildAdminActivities(
    Map<String, dynamic> data,
    bool condensed,
  ) sync* {
    if (data['activities'] == null) return;
    final adminActivities = data['activities'] as List<AdminActivity>;
    final limit = condensed ? 6 : adminActivities.length;

    for (final activity in adminActivities.take(limit)) {
      final occurredAt = activity.timestamp;
      String activityStatus = 'completed';
      if (activity.type.contains('approved')) {
        activityStatus = 'approved';
      } else if (activity.type.contains('rejected')) {
        activityStatus = 'rejected';
      }

      yield RecentActivity(
        title: activity.title,
        subtitle: activity.subtitle,
        time: _formatRelativeTime(occurredAt),
        iconPath: activity.iconPath,
        iconBgColor: activity.iconBgColor,
        status: activityStatus,
        occurredAt: occurredAt,
      );
    }
  }

  static Iterable<RecentActivity> _buildUserActivities(
    Map<String, dynamic> data,
    bool condensed,
  ) sync* {
    if (data['recent'] == null) return;
    final recentUsers = data['recent'] as List;
    final regularUsers = recentUsers.where((user) {
      final type = _getUserType(user);
      return type == 'user';
    }).toList();

    final limit = condensed ? 2 : regularUsers.length;

    for (final user in regularUsers.take(limit)) {
      final occurredAt = _getUserJoinDate(user) ?? DateTime.now();
      final status = _getUserStatus(user) ?? 'active';
      final isPendingUser = status.toLowerCase() == 'pending';

      yield RecentActivity(
        title: isPendingUser ? 'User pending approval' : 'New user registration',
        subtitle: _getUserName(user) ?? 'Unknown User',
        time: _formatRelativeTime(occurredAt),
        iconPath: 'assets/images/activity_icon_1.png',
        iconBgColor: isPendingUser ? 'yellow' : 'green',
        status: status,
        entityId: isPendingUser ? _getUserId(user) : null,
        entityType: isPendingUser ? 'user' : null,
        entityData: isPendingUser
            ? {
                'id': _getUserId(user),
                'name': _getUserName(user) ?? 'Unknown User',
                'email': _getUserEmail(user) ?? 'No email',
                'phone': _getUserPhone(user) ?? 'No phone',
                'businessName': _getUserCompany(user) ?? _getUserName(user),
                'status': status,
              }
            : null,
        occurredAt: occurredAt,
      );
    }
  }

  static Iterable<RecentActivity> _buildPostActivities(
    Map<String, dynamic> data,
    bool condensed,
  ) sync* {
    if (data['recent'] == null) return;
    final recentPosts = data['recent'] as List;
    final limit = condensed ? 3 : recentPosts.length;

    for (final post in recentPosts.take(limit)) {
      final info = _extractPostInfo(post);
      if (info == null) continue;

      yield RecentActivity(
        title: info.isPending
            ? 'Post awaiting review'
            : info.status.toLowerCase() == 'approved'
                ? 'Post approved'
                : 'Post submitted',
        subtitle: 'User: ${info.username} on ${info.platform}',
        time: _formatRelativeTime(info.createdAt),
        iconPath: 'assets/images/activity_icon_2.png',
        iconBgColor: info.isPending ? 'yellow' : 'green',
        entityId: info.id,
        entityType: 'post',
        status: info.status,
        entityData: info.entityData,
        occurredAt: info.createdAt,
      );
    }
  }

  static Iterable<RecentActivity> _buildMerchantActivities(
    Map<String, dynamic> data,
    bool condensed,
  ) sync* {
    if (data['recent'] == null) return;
    final recentItems = data['recent'] as List;
    final pendingMerchants = recentItems.where((merchant) {
      final type = _getMerchantType(merchant) ?? 'user';
      final status = _getMerchantStatus(merchant) ?? 'active';
      return type == 'merchant' && status.toLowerCase() == 'pending';
    }).toList();

    final limit = condensed ? 2 : pendingMerchants.length;

    for (final merchant in pendingMerchants.take(limit)) {
      final occurredAt = _getMerchantJoinDate(merchant) ?? DateTime.now();
      final status = _getMerchantStatus(merchant) ?? 'pending';

      yield RecentActivity(
        title: 'Merchant application pending',
        subtitle:
            '${_getMerchantBusinessName(merchant) ?? 'Unknown Business'} - ${_getMerchantName(merchant) ?? 'Unknown Merchant'}',
        time: _formatRelativeTime(occurredAt),
        iconPath: 'assets/images/activity_icon_1.png',
        iconBgColor: 'yellow',
        status: status,
        entityId: _getMerchantId(merchant),
        entityType: 'merchant',
        entityData: {
          'id': _getMerchantId(merchant),
          'name': _getMerchantName(merchant) ?? 'Unknown Merchant',
          'businessName':
              _getMerchantBusinessName(merchant) ?? 'Unknown Business',
          'email': _getMerchantEmail(merchant) ?? 'No email',
          'phone': _getMerchantPhone(merchant) ?? 'No phone',
          'status': status,
        },
        occurredAt: occurredAt,
      );
    }
  }

  static Iterable<RecentActivity> _buildTransactionActivities(
    Map<String, dynamic> data,
    bool condensed,
  ) sync* {
    if (data['recent'] == null) return;
    final recentTransactions = data['recent'] as List;
    final limit = condensed ? 2 : recentTransactions.length;

    for (final transaction in recentTransactions.take(limit)) {
      final info = _extractTransactionInfo(transaction);
      if (info == null) continue;

      yield RecentActivity(
        title: info.isPending
            ? (info.status.toLowerCase() == 'disputed'
                ? 'Transaction disputed'
                : 'Transaction pending')
            : 'Transaction',
        subtitle:
            '${info.businessName} - ${AppConstants.currencySymbol}${info.amount.toStringAsFixed(2)}',
        time: _formatRelativeTime(info.createdAt),
        iconPath: 'assets/images/activity_icon_3.png',
        iconBgColor: info.isPending ? 'yellow' : 'green',
        status: info.status,
        entityId: info.isPending ? info.id : null,
        entityType: info.isPending ? 'transaction' : null,
        entityData: info.isPending
            ? {
                'id': info.id,
                'amount': info.amount,
                'status': info.status,
                'merchantName': info.businessName,
                'createdAt': info.createdAt.toIso8601String(),
              }
            : null,
        occurredAt: info.createdAt,
      );
    }
  }

  static Iterable<RecentActivity> _buildNotificationActivities(
    Map<String, dynamic> data,
    bool condensed,
  ) sync* {
    if (data['recent'] == null) return;
    final recentNotifications = data['recent'] as List;
    final limit = condensed ? 2 : recentNotifications.length;

    for (final notification in recentNotifications.take(limit)) {
      final info = _extractNotificationInfo(notification);
      if (info == null) continue;

      yield RecentActivity(
        title:
            info.scheduledAt != null ? 'Notification scheduled' : 'Notification pending',
        subtitle: info.title,
        time: _formatRelativeTime(info.occurredAt),
        iconPath: 'assets/images/activity_icon_4.png',
        iconBgColor: 'yellow',
        status: info.status,
        entityId: info.isPending ? info.id : null,
        entityType: info.isPending ? 'notification' : null,
        entityData: info.isPending
            ? {
                'id': info.id,
                'title': info.title,
                'message': info.message,
                'status': info.status,
                'scheduledAt': info.scheduledAt?.toIso8601String(),
                'createdAt': info.createdAt.toIso8601String(),
              }
            : null,
        occurredAt: info.occurredAt,
      );
    }
  }

  static String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String? _getUserId(dynamic user) {
    if (user is AdminUser) return user.id;
    if (user is Map<String, dynamic>) return user['id']?.toString();
    return null;
  }

  static String? _getUserName(dynamic user) {
    if (user is AdminUser) return user.name;
    if (user is Map<String, dynamic>) {
      return user['name']?.toString() ??
          user['full_name']?.toString() ??
          user['display_name']?.toString();
    }
    return null;
  }

  static String? _getUserEmail(dynamic user) {
    if (user is AdminUser) return user.email;
    if (user is Map<String, dynamic>) return user['email']?.toString();
    return null;
  }

  static String? _getUserPhone(dynamic user) {
    if (user is AdminUser) return user.phone;
    if (user is Map<String, dynamic>) return user['phone']?.toString();
    return null;
  }

  static String? _getUserCompany(dynamic user) {
    if (user is AdminUser) return user.company;
    if (user is Map<String, dynamic>) {
      return user['company']?.toString() ?? user['business_name']?.toString();
    }
    return null;
  }

  static String? _getUserStatus(dynamic user) {
    if (user is AdminUser) return user.status;
    if (user is Map<String, dynamic>) return user['status']?.toString();
    return null;
  }

  static DateTime? _getUserJoinDate(dynamic user) {
    if (user is AdminUser) return user.joinDate;
    if (user is Map<String, dynamic>) {
      return _parseDate(user['joinDate'] ?? user['created_at']);
    }
    return null;
  }

  static String? _getUserType(dynamic user) {
    if (user is AdminUser) return user.userType;
    if (user is Map<String, dynamic>) {
      return user['userType']?.toString() ?? user['user_type']?.toString();
    }
    return null;
  }

  static String? _getMerchantType(dynamic merchant) {
    if (merchant is AdminUser) return merchant.userType;
    if (merchant is Map<String, dynamic>) {
      return merchant['userType']?.toString() ?? merchant['user_type']?.toString();
    }
    return null;
  }

  static String? _getMerchantStatus(dynamic merchant) {
    if (merchant is AdminUser) return merchant.status;
    if (merchant is Map<String, dynamic>) return merchant['status']?.toString();
    return null;
  }

  static String? _getMerchantId(dynamic merchant) {
    if (merchant is AdminUser) return merchant.id;
    if (merchant is Map<String, dynamic>) return merchant['id']?.toString();
    return null;
  }

  static String? _getMerchantName(dynamic merchant) {
    if (merchant is AdminUser) return merchant.name;
    if (merchant is Map<String, dynamic>) return merchant['name']?.toString();
    return null;
  }

  static String? _getMerchantBusinessName(dynamic merchant) {
    if (merchant is AdminUser) return merchant.company;
    if (merchant is Map<String, dynamic>) {
      return merchant['company']?.toString() ??
          merchant['business_name']?.toString();
    }
    return null;
  }

  static String? _getMerchantEmail(dynamic merchant) {
    if (merchant is AdminUser) return merchant.email;
    if (merchant is Map<String, dynamic>) return merchant['email']?.toString();
    return null;
  }

  static String? _getMerchantPhone(dynamic merchant) {
    if (merchant is AdminUser) return merchant.phone;
    if (merchant is Map<String, dynamic>) return merchant['phone']?.toString();
    return null;
  }

  static DateTime? _getMerchantJoinDate(dynamic merchant) {
    if (merchant is AdminUser) return merchant.joinDate;
    if (merchant is Map<String, dynamic>) {
      return _parseDate(merchant['joinDate'] ?? merchant['created_at']);
    }
    return null;
  }

  static _PostInfo? _extractPostInfo(dynamic post) {
    try {
      if (post is SocialPost) {
        final createdAt = post.createdAt ?? DateTime.now();
        final status = post.status;
        final username = post.username ?? post.displayName ?? 'Unknown';
        final platform = post.platformName ?? 'instagram';
        return _PostInfo(
          id: post.id,
          username: username,
          platform: platform,
          status: status,
          createdAt: createdAt,
          entityData: {
            'id': post.id,
            'username': username,
            'businessName': platform,
            'description': post.content,
            'content': post.content,
            'imageUrl': post.mediaUrls?.isNotEmpty == true
                ? post.mediaUrls!.first
                : '',
            'status': status,
          },
        );
      }
      if (post is Map<String, dynamic>) {
        final createdAt = _parseDate(post['created_at']) ?? DateTime.now();
        final status = post['status']?.toString() ?? 'pending';
        final username = post['username']?.toString() ??
            post['display_name']?.toString() ??
            'Unknown';
        final platform = post['platform_name']?.toString() ?? 'instagram';
        final media = post['media_urls'];
        return _PostInfo(
          id: post['id']?.toString(),
          username: username,
          platform: platform,
          status: status,
          createdAt: createdAt,
          entityData: {
            'id': post['id']?.toString(),
            'username': username,
            'businessName': platform,
            'description': post['content']?.toString() ?? '',
            'content': post['content']?.toString() ?? '',
            'imageUrl': media is List && media.isNotEmpty
                ? media.first.toString()
                : '',
            'status': status,
          },
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static _TransactionInfo? _extractTransactionInfo(dynamic transaction) {
    try {
      if (transaction is Transaction) {
        final status = transaction.status;
        return _TransactionInfo(
          id: transaction.id,
          amount: transaction.amount,
          status: status,
          businessName: transaction.businessName,
          createdAt: transaction.createdAt,
        );
      }
      if (transaction is Map<String, dynamic>) {
        final amountValue = transaction['amount'];
        double amount = 0.0;
        if (amountValue is num) {
          amount = amountValue.toDouble();
        } else if (amountValue != null) {
          amount = double.tryParse(amountValue.toString()) ?? 0.0;
        }

        return _TransactionInfo(
          id: transaction['id']?.toString(),
          amount: amount,
          status: transaction['status']?.toString() ?? 'pending',
          businessName: transaction['merchant_name']?.toString() ??
              transaction['storeName']?.toString() ??
              transaction['metadata']?['storeName']?.toString() ??
              'Unknown Business',
          createdAt: _parseDate(transaction['created_at']) ?? DateTime.now(),
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static _NotificationInfo? _extractNotificationInfo(dynamic notification) {
    try {
      if (notification is NotificationModel) {
        DateTime? scheduledAt;
        final metaValue = notification.metadata?['scheduled_at'] ??
            notification.metadata?['scheduledAt'];
        if (metaValue != null) {
          scheduledAt = DateTime.tryParse(metaValue.toString());
        }
        final createdAt = notification.createdAt;
        final occurredAt = scheduledAt ?? createdAt;
        final status = notification.status ?? 'pending';
        return _NotificationInfo(
          id: notification.id,
          title: notification.title,
          status: status,
          message: notification.message,
          createdAt: createdAt,
          scheduledAt: scheduledAt,
          sentAt: notification.sentAt,
          occurredAt: occurredAt,
        );
      }
      if (notification is Map<String, dynamic>) {
        final createdAt = _parseDate(notification['created_at']) ?? DateTime.now();
        final scheduledAt = _parseDate(notification['scheduled_at']) ??
            _parseDate(notification['metadata']?['scheduled_at']) ??
            _parseDate(notification['metadata']?['scheduledAt']);
        final occurredAt = scheduledAt ?? createdAt;
        return _NotificationInfo(
          id: notification['id']?.toString(),
          title: notification['title']?.toString() ??
              notification['subject']?.toString() ??
              'Notification',
          status: notification['status']?.toString() ?? 'pending',
          message: notification['message']?.toString() ?? '',
          createdAt: createdAt,
          scheduledAt: scheduledAt,
          sentAt: _parseDate(notification['sent_at']),
          occurredAt: occurredAt,
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

class _PostInfo {
  final String? id;
  final String username;
  final String platform;
  final String status;
  final DateTime createdAt;
  final bool isPending;
  final Map<String, dynamic> entityData;

  _PostInfo({
    required this.id,
    required this.username,
    required this.platform,
    required this.status,
    required this.createdAt,
    required this.entityData,
  }) : isPending = status.toLowerCase() == 'pending' ||
            status.toLowerCase() == 'pending_review';
}

class _TransactionInfo {
  final String? id;
  final double amount;
  final String status;
  final String businessName;
  final DateTime createdAt;

  _TransactionInfo({
    required this.id,
    required this.amount,
    required this.status,
    required this.businessName,
    required this.createdAt,
  });

  bool get isPending =>
      status.toLowerCase() == 'pending' || status.toLowerCase() == 'disputed';
}

class _NotificationInfo {
  final String? id;
  final String title;
  final String status;
  final String message;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime occurredAt;

  _NotificationInfo({
    required this.id,
    required this.title,
    required this.status,
    required this.message,
    required this.createdAt,
    required this.scheduledAt,
    required this.sentAt,
    required this.occurredAt,
  });

  bool get isPending => (sentAt == null) ||
      status.toLowerCase() == 'pending' ||
      status.toLowerCase() == 'scheduled';
}

