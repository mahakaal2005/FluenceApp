import '../services/api_service.dart';

class SessionsRepository {
  final ApiService _apiService;

  SessionsRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  /// Get active sessions count and growth from auth service
  Future<Map<String, dynamic>> getActiveSessions() async {
    try {
      final response = await _apiService.get(
        'api/auth/sessions/active',
        service: ServiceType.auth,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        
        return {
          'activeSessions': data['activeSessions'] ?? 0,
          'growth': (data['growth'] ?? 0.0).toDouble(),
          'recentSessions': data['recentSessions'] ?? 0,
          'previousSessions': data['previousSessions'] ?? 0,
        };
      }
      
      return {
        'activeSessions': 0,
        'growth': 0.0,
        'recentSessions': 0,
        'previousSessions': 0,
      };
    } catch (e) {
      print('[ERROR] [SESSIONS] Error fetching active sessions: $e');
      return {
        'activeSessions': 0,
        'growth': 0.0,
        'recentSessions': 0,
        'previousSessions': 0,
      };
    }
  }

  /// Get detailed session statistics
  Future<Map<String, dynamic>> getSessionStats() async {
    try {
      final response = await _apiService.get(
        'api/auth/sessions/stats',
        service: ServiceType.auth,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      
      return {};
    } catch (e) {
      print('[ERROR] [SESSIONS] Error fetching session stats: $e');
      return {};
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}
