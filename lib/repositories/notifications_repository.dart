import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationsRepository {
  final ApiService _apiService;

  NotificationsRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Get notifications
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 10,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': ((page - 1) * limit).toString(),
      };
      
      if (type != null) queryParams['type'] = type;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _apiService.get(
        'api/notifications?$query',
        service: ServiceType.notification,
      );

      if (response['success'] == true && response['data'] != null) {
        final notifications = response['data']['notifications'] as List;
        return notifications.map((n) => NotificationModel.fromJson(n)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Get sent notifications with read statistics (Admin)
  Future<List<Map<String, dynamic>>> getSentNotificationsWithStats({
    int page = 1,
    int limit = 10,
    }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': ((page - 1) * limit).toString(),
      };
      
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _apiService.get(
        'api/notifications/sent-with-stats?$query',
        service: ServiceType.notification,
      );

      if (response['success'] == true && response['data'] != null) {
        final notifications = response['data']['notifications'] as List;
        return notifications.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print('[ERROR] [NotificationsRepo] Error fetching sent notifications: $e');
      throw Exception('Failed to fetch sent notifications: $e');
    }
  }

  // Send notification to all users (Admin) - immediately or scheduled
  Future<void> sendNotification({
    required String title,
    required String message,
    String type = 'in_app',
    Map<String, dynamic>? data,
    DateTime? scheduledAt,
  }) async {
    try {
      await _apiService.post(
        'api/admin/notifications/send',
        {
          'title': title,
          'message': message,
          'type': type,
          if (data != null) 'data': data,
          if (scheduledAt != null) 'scheduledAt': scheduledAt.toIso8601String(),
        },
        service: ServiceType.notification,
      );
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  // Get unseen admin notification count
  // Only counts notifications RECEIVED by admin (not sent by admin)
  // Filters by admin category notifications (admin_new_post, admin_new_merchant_application, etc.)
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        'api/notifications/unread-count',
        service: ServiceType.notification,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data']['unreadCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      // Handle rate limiting gracefully - return 0 instead of throwing
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('429') || errorStr.contains('too many requests') || errorStr.contains('rate limit')) {
        return 0;
      }
      throw Exception('Failed to fetch unread count: $e');
    }
  }

  // Mark all admin notifications as opened/viewed
  // Only marks notifications RECEIVED by admin (not sent by admin)
  // This should be called when admin views their notifications list
  Future<void> markAllAsOpened() async {
    try {
      await _apiService.put(
        'api/notifications/opened-all',
        {},
        service: ServiceType.notification,
      );
    } catch (e) {
      throw Exception('Failed to mark notifications as opened: $e');
    }
  }

  // Get total user count (Admin)
  Future<int> getUserCount() async {
    try {
      final response = await _apiService.get(
        'api/admin/notifications/user-count',
        service: ServiceType.notification,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data']['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      throw Exception('Failed to fetch user count: $e');
    }
  }

  // Get admin analytics (Admin)
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await _apiService.get(
        'api/admin/notifications/analytics',
        service: ServiceType.notification,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      }
      return {};
    } catch (e) {
      throw Exception('Failed to fetch analytics: $e');
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}