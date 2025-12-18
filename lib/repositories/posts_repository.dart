import '../models/post.dart';
import '../services/api_service.dart';

class PostsRepository {
  final ApiService _apiService;

  PostsRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Get all social posts with optional filtering
  Future<List<Map<String, dynamic>>> getAllSocialPostsWithMetadata({
    int limit = 50,
    int offset = 0,
    String? status,
    String? platformId,
    String? userId,
    String? startDate,
    String? endDate,
    String? postType,
    String? search,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (status != null) queryParams['status'] = status;
      if (platformId != null) queryParams['platformId'] = platformId;
      if (userId != null) queryParams['userId'] = userId;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (postType != null) queryParams['postType'] = postType;
      if (search != null) queryParams['search'] = search;
      
      // Build URL with query parameters
      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final endpoint = 'api/admin/social/posts?$queryString';
      
      final response = await _apiService.get(
        endpoint,
        service: ServiceType.social,
      );

      if (response['success'] == true && response['data'] != null) {
        // Check if data has posts array
        if (response['data'] is Map && response['data']['posts'] != null) {
          final posts = response['data']['posts'] as List;
          
          // Filter out posts without original_transaction_id
          final validPosts = posts.where((post) {
            return post['original_transaction_id'] != null;
          }).toList();
          
          return validPosts.map((post) => post as Map<String, dynamic>).toList();
        } else if (response['data'] is List) {
          final posts = response['data'] as List;
          
          // Filter out posts without original_transaction_id
          final validPosts = posts.where((post) {
            return post['original_transaction_id'] != null;
          }).toList();
          
          return validPosts.map((post) => post as Map<String, dynamic>).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('[ERROR] [POSTS] Error: $e');
      throw Exception('Failed to fetch posts: $e');
    }
  }

  // Get pending posts only (convenience method)
  Future<List<Map<String, dynamic>>> getPendingSocialPostsWithMetadata() async {
    return getAllSocialPostsWithMetadata(status: 'pending_review');
  }

  // Legacy method for backward compatibility
  Future<List<SocialPost>> getPendingSocialPosts() async {
    final postsWithMetadata = await getPendingSocialPostsWithMetadata();
    return postsWithMetadata.map((post) => SocialPost.fromJson(post)).toList();
  }
  
  // Get all posts (convenience method)
  Future<List<SocialPost>> getAllSocialPosts({
    int limit = 50,
    int offset = 0,
    String? status,
  }) async {
    final postsWithMetadata = await getAllSocialPostsWithMetadata(
      limit: limit,
      offset: offset,
      status: status,
    );
    return postsWithMetadata.map((post) => SocialPost.fromJson(post)).toList();
  }

  // Verify/approve a social media post
  Future<void> verifySocialPost(String postId, {String? notes}) async {
    try {
      await _apiService.post(
        'api/admin/social/posts/$postId/approve',
        {
          'adminNotes': notes ?? 'Post approved',
        },
        service: ServiceType.social,
      );
    } catch (e) {
      print('[ERROR] [POSTS] Approve failed: $e');
      throw Exception('Failed to verify post: $e');
    }
  }

  // Reject a social media post
  Future<void> rejectSocialPost(String postId, String reason) async {
    try {
      await _apiService.post(
        'api/admin/social/posts/$postId/reject',
        {
          'rejectionReason': reason,
          'adminNotes': reason,
        },
        service: ServiceType.social,
      );
    } catch (e) {
      print('[ERROR] [POSTS] Reject failed: $e');
      throw Exception('Failed to reject post: $e');
    }
  }

  // Get social media analytics
  Future<Map<String, dynamic>> getSocialAnalytics() async {
    try {
      final response = await _apiService.get(
        'api/social/analytics',
        service: ServiceType.social,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      }
      return {};
    } catch (e) {
      throw Exception('Failed to fetch social analytics: $e');
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}