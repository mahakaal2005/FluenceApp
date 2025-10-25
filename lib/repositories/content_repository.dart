import '../models/faq.dart';
import '../models/terms.dart';
import '../services/api_service.dart';

class ContentRepository {
  final ApiService _apiService;

  ContentRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // ==================== FAQ Methods ====================
  
  /// Get all FAQs with optional filtering
  Future<List<FAQ>> getFAQs({
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _apiService.get(
        'api/content/faq?$query',
        service: ServiceType.notification,
      );

      if (response['success'] == true && response['data'] != null) {
        final faqs = response['data']['faqs'] as List<dynamic>;
        return faqs.map((f) => FAQ.fromJson(f as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      print('❌ FAQ Repository Error: $e');
      throw Exception('Failed to fetch FAQs: $e');
    }
  }

  /// Create a new FAQ (Admin only)
  Future<FAQ> createFAQ({
    required String question,
    required String answer,
    required String category,
    List<String>? tags,
  }) async {
    try {
      final response = await _apiService.post(
        'api/content/faq',
        {
          'question': question,
          'answer': answer,
          'category': category,
          if (tags != null) 'tags': tags,
        },
        service: ServiceType.notification,
      );

      if (response['success'] == true && response['data'] != null) {
        return FAQ.fromJson(response['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to create FAQ');
    } catch (e) {
      print('❌ Create FAQ Error: $e');
      throw Exception('Failed to create FAQ: $e');
    }
  }

  // ==================== Terms & Conditions Methods ====================
  
  /// Get current Terms & Conditions
  Future<Terms> getTerms({String? version}) async {
    try {
      final queryParams = <String, String>{};
      
      if (version != null && version.isNotEmpty) {
        queryParams['version'] = version;
      }
      
      final query = queryParams.isEmpty 
          ? '' 
          : '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      
      final response = await _apiService.get(
        'api/content/terms$query',
        service: ServiceType.notification,
      );

      if (response['success'] == true && response['data'] != null) {
        return Terms.fromJson(response['data'] as Map<String, dynamic>);
      }
      throw Exception('Terms & Conditions not found');
    } catch (e) {
      print('❌ Terms Repository Error: $e');
      throw Exception('Failed to fetch Terms & Conditions: $e');
    }
  }

  /// Create new Terms & Conditions version (Admin only)
  Future<Terms> createTerms({
    required String title,
    required String content,
    required String version,
    required DateTime effectiveDate,
  }) async {
    try {
      final response = await _apiService.post(
        'api/content/terms',
        {
          'title': title,
          'content': content,
          'version': version,
          'effectiveDate': effectiveDate.toIso8601String(),
        },
        service: ServiceType.notification,
      );

      if (response['success'] == true && response['data'] != null) {
        return Terms.fromJson(response['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to create Terms & Conditions');
    } catch (e) {
      print('❌ Create Terms Error: $e');
      throw Exception('Failed to create Terms & Conditions: $e');
    }
  }

  // ==================== Utility Methods ====================
  
  void dispose() {
    // Clean up resources if needed
  }
}
