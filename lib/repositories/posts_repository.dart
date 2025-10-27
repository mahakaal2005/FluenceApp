import '../models/post.dart';
import '../services/api_service.dart';

class PostsRepository {
  final ApiService _apiService;

  PostsRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Get pending social posts for verification with raw data for duplicate detection
  Future<List<Map<String, dynamic>>> getPendingSocialPostsWithMetadata() async {
    try {
      print('📝 [POSTS] Fetching pending posts...');
      print('   Service: social (port 4007)');
      print('   Endpoint: api/admin/social/posts/pending');
      
      final response = await _apiService.get(
        'api/admin/social/posts/pending',
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
          print('   Posts found: ${posts.length}');
          if (posts.isNotEmpty) {
            print('   First post keys: ${posts[0].keys.toList()}');
            if (posts[0]['has_duplicates'] != null) {
              print('   ✓ Duplicate detection data present');
            }
          }
          return posts.map((post) => post as Map<String, dynamic>).toList();
        } else if (response['data'] is List) {
          final posts = response['data'] as List;
          print('   Posts found (direct array): ${posts.length}');
          return posts.map((post) => post as Map<String, dynamic>).toList();
        }
      }
      
      print('⚠️ [POSTS] No posts found, returning empty list');
      return [];
    } catch (e) {
      print('❌ [POSTS] Error: $e');
      throw Exception('Failed to fetch pending posts: $e');
    }
  }

  // Legacy method for backward compatibility
  Future<List<SocialPost>> getPendingSocialPosts() async {
    final postsWithMetadata = await getPendingSocialPostsWithMetadata();
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