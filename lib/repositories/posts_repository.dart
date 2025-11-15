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
      print('📝 [POSTS] Fetching all posts...');
      print('   Service: social');
      print('   Endpoint: api/admin/social/posts');
      print('   Filters: status=$status, limit=$limit, offset=$offset');
      
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

      print('✅ [POSTS] Response received');
      print('   Success: ${response['success']}');
      print('   Has data: ${response['data'] != null}');
      
      if (response['success'] == true && response['data'] != null) {
        print('   Response structure: ${response.keys.toList()}');
        
        // Check if data has posts array
        if (response['data'] is Map && response['data']['posts'] != null) {
          final posts = response['data']['posts'] as List;
          final pagination = response['data']['pagination'];
          print('   Posts found: ${posts.length}');
          print('   Total posts: ${pagination?['total'] ?? 'unknown'}');
          
          // Filter out posts without original_transaction_id
          final validPosts = posts.where((post) {
            final hasTransactionId = post['original_transaction_id'] != null;
            if (!hasTransactionId) {
              print('   ⚠️ Filtering out post ${post['id']} - missing transaction ID');
            }
            return hasTransactionId;
          }).toList();
          
          print('   Valid posts (with transaction ID): ${validPosts.length}');
          if (validPosts.isNotEmpty) {
            print('   First post keys: ${validPosts[0].keys.toList()}');
            print('   First post status: ${validPosts[0]['status']}');
          }
          return validPosts.map((post) => post as Map<String, dynamic>).toList();
        } else if (response['data'] is List) {
          final posts = response['data'] as List;
          print('   Posts found (direct array): ${posts.length}');
          
          // Filter out posts without original_transaction_id
          final validPosts = posts.where((post) {
            final hasTransactionId = post['original_transaction_id'] != null;
            if (!hasTransactionId) {
              print('   ⚠️ Filtering out post ${post['id']} - missing transaction ID');
            }
            return hasTransactionId;
          }).toList();
          
          print('   Valid posts (with transaction ID): ${validPosts.length}');
          return validPosts.map((post) => post as Map<String, dynamic>).toList();
        }
      }
      
      print('⚠️ [POSTS] No posts found, returning empty list');
      return [];
    } catch (e) {
      print('❌ [POSTS] Error: $e');
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
      print('✅ [POSTS] Approving post: $postId');
      await _apiService.post(
        'api/admin/social/posts/$postId/approve',
        {
          'adminNotes': notes ?? 'Post approved',
        },
        service: ServiceType.social,
      );
      print('✅ [POSTS] Post approved successfully');
    } catch (e) {
      print('❌ [POSTS] Approve failed: $e');
      throw Exception('Failed to verify post: $e');
    }
  }

  // Reject a social media post
  Future<void> rejectSocialPost(String postId, String reason) async {
    try {
      print('❌ [POSTS] Rejecting post: $postId');
      await _apiService.post(
        'api/admin/social/posts/$postId/reject',
        {
          'rejectionReason': reason,
          'adminNotes': reason,
        },
        service: ServiceType.social,
      );
      print('✅ [POSTS] Post rejected successfully');
    } catch (e) {
      print('❌ [POSTS] Reject failed: $e');
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