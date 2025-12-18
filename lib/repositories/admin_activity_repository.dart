import '../services/api_service.dart';
import '../models/admin_activity.dart';

class AdminActivityRepository {
  final ApiService _apiService;

  AdminActivityRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  /// Get recent post verification activities (approvals/rejections)
  Future<List<AdminActivity>> getRecentPostVerifications({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        'api/admin/social/activity/recent-verifications?limit=$limit',
        service: ServiceType.social,
      );

      if (response['success'] == true && response['data'] != null) {
        final activities = (response['data'] as List)
            .map((json) => AdminActivity.fromJson(json))
            .toList();
        
        return activities;
      }
      
      return [];
    } catch (e) {
      print('[ERROR] [ADMIN_ACTIVITY] Error fetching post verifications: $e');
      return [];
    }
  }

  /// Get recent application review activities (approvals/rejections/suspensions)
  Future<List<AdminActivity>> getRecentApplicationReviews({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        'api/admin/activity/recent-reviews?limit=$limit',
        service: ServiceType.merchant,
      );

      if (response['success'] == true && response['data'] != null) {
        final activities = (response['data'] as List)
            .map((json) => AdminActivity.fromJson(json))
            .toList();
        
        return activities;
      }
      
      return [];
    } catch (e) {
      print('[ERROR] [ADMIN_ACTIVITY] Error fetching application reviews: $e');
      return [];
    }
  }

  /// Get all recent admin activities (combined)
  Future<List<AdminActivity>> getAllRecentActivities({int limit = 20}) async {
    try {
      // Fetch both types of activities in parallel
      final results = await Future.wait([
        getRecentPostVerifications(limit: limit ~/ 2),
        getRecentApplicationReviews(limit: limit ~/ 2),
      ]);

      final postActivities = results[0];
      final appActivities = results[1];

      // Combine and sort by timestamp
      final allActivities = [...postActivities, ...appActivities];
      allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Take only the most recent ones up to limit
      final recentActivities = allActivities.take(limit).toList();

      return recentActivities;
    } catch (e) {
      print('[ERROR] [ADMIN_ACTIVITY] Error fetching all activities: $e');
      return [];
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}
