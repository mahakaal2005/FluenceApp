import '../models/user.dart';
import '../services/api_service.dart';

class UsersRepository {
  final ApiService _apiService;

  UsersRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Get all merchant applications (admin endpoint)
  Future<List<AdminUser>> getMerchantApplications({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    print('👥 [USERS] Fetching merchant applications...');
    print('   Page: $page, Limit: $limit, Status: $status');
    
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;
      
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      print('   Query: $query');
      print('   Endpoint: api/admin/applications?$query');
      
      final response = await _apiService.get(
        'api/admin/applications?$query',
        service: ServiceType.merchant,
      );

      print('✅ [USERS] Response received');
      print('   Success: ${response['success']}');
      print('   Has data: ${response['data'] != null}');
      print('   Response keys: ${response.keys.toList()}');
      
      if (response['data'] != null && response['data'] is List) {
        final apps = response['data'] as List;
        print('   Applications count: ${apps.length}');
        if (apps.isNotEmpty) {
          print('   First application keys: ${apps[0].keys.toList()}');
          print('   First application: ${apps[0]}');
        }
      }

      if (response['success'] == true && response['data'] != null) {
        final applications = response['data'] as List;
        print('📦 [USERS] Parsing ${applications.length} applications...');
        
        final users = applications.map((app) {
          print('   Parsing app: ${app['id']} - ${app['business_name']}');
          return AdminUser.fromJson({
            'id': app['id'],
            'name': app['business_name'] ?? app['contact_person'] ?? 'Unknown',
            'email': app['email'] ?? app['contact_email'] ?? '',
            'phone': app['phone'] ?? app['contact_phone'] ?? '',
            'status': app['status'] ?? 'pending',
            'joinDate': app['submitted_at'] ?? app['created_at'] ?? '',
            'company': app['business_name'] ?? 'Unknown',
            'businessType': app['business_type'] ?? '',
          });
        }).toList();
        
        print('✅ [USERS] Successfully parsed ${users.length} users');
        return users;
      }
      
      print('⚠️ [USERS] No valid data in response, returning empty list');
      return [];
    } catch (e) {
      print('❌ [USERS] Error fetching merchant applications: $e');
      print('   Error type: ${e.runtimeType}');
      throw Exception('Failed to fetch merchant applications: $e');
    }
  }

  // Approve merchant application
  Future<void> approveMerchantApplication(String applicationId) async {
    try {
      await _apiService.put(
        'api/admin/applications/$applicationId/status',
        {
          'status': 'approved',
          'notes': 'Application approved by admin',
        },
        service: ServiceType.merchant,
      );
    } catch (e) {
      throw Exception('Failed to approve application: $e');
    }
  }

  // Reject merchant application
  Future<void> rejectMerchantApplication(String applicationId, String reason) async {
    try {
      await _apiService.put(
        'api/admin/applications/$applicationId/status',
        {
          'status': 'rejected',
          'notes': reason,
        },
        service: ServiceType.merchant,
      );
    } catch (e) {
      throw Exception('Failed to reject application: $e');
    }
  }

  // Suspend merchant
  Future<void> suspendMerchant(String merchantId) async {
    try {
      await _apiService.put(
        'api/admin/applications/$merchantId/status',
        {
          'status': 'suspended',
          'notes': 'Merchant suspended by admin',
        },
        service: ServiceType.merchant,
      );
    } catch (e) {
      throw Exception('Failed to suspend merchant: $e');
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}