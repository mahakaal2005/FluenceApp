import 'dart:convert';
import '../models/user.dart';
import '../services/api_service.dart';

class UsersRepository {
  final ApiService _apiService;

  UsersRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Get all users (for notifications, etc.)
  Future<List<Map<String, dynamic>>> getAllUsers({
    int page = 1,
    int limit = 100,
    String? role,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (role != null) queryParams['role'] = role;
      if (status != null) queryParams['status'] = status;
      
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _apiService.get(
        'api/users?$query',
        service: ServiceType.auth,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final users = data['users'] as List;
        
        return users.map((user) {
          return {
            'id': user['id'],
            'name': user['name'] ?? 'Unknown',
            'email': user['email'] ?? '',
            'role': user['role'] ?? 'user',
            'status': user['status'] ?? 'active',
            // Preserve approval metadata so dashboard analytics can compute counts correctly
            'is_approved': user['is_approved'],
            // Include phone/address meta for potential future use
            'phone': user['phone'],
            'address': user['address'],
            // Created timestamp is needed to calculate growth metrics on the dashboard
            'created_at': user['created_at'] ?? user['createdAt'],
          };
        }).toList();
      }
      
      return [];
    } catch (e) {
      print('[ERROR] [USERS] Error fetching users: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  // Get regular users (non-merchant users)
  Future<List<AdminUser>> getRegularUsers({
    int page = 1,
    int limit = 100,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'role': 'user', // Filter for regular users only
      };
      if (status != null) queryParams['status'] = status;
      
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _apiService.get(
        'api/users?$query',
        service: ServiceType.auth,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final users = data['users'] as List;
        
        final adminUsers = users.map((user) {
          // Map is_approved field to status for UI
          // Backend approval workflow uses is_approved field
          String displayStatus;
          final isApproved = user['is_approved'];
          
          if (isApproved == true) {
            displayStatus = 'approved';
          } else if (isApproved == false || isApproved == null) {
            displayStatus = 'pending';
          } else {
            displayStatus = user['status'] ?? 'active';
          }
          
          // Parse address if it's JSON format
          String? location;
          final address = user['address'];
          if (address != null && address.toString().isNotEmpty) {
            location = _parseAddress(address);
          }
          
          return AdminUser.fromJson({
            'id': user['id'],
            'name': user['name'] ?? 'Unknown',
            'email': user['email'] ?? '',
            'phone': user['phone'] ?? '',
            'status': displayStatus,
            'joinDate': user['created_at'] ?? DateTime.now().toIso8601String(),
            'userType': 'user',
            'company': null,
            'businessType': null,
            'location': location,
          });
        }).toList();
        
        return adminUsers;
      }
      
      return [];
    } catch (e) {
      print('[ERROR] [USERS] Error fetching regular users: $e');
      throw Exception('Failed to fetch regular users: $e');
    }
  }

  // Get all merchant applications (admin endpoint)
  Future<List<AdminUser>> getMerchantApplications({
    int page = 1,
    int limit = 100,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': ((page - 1) * limit).toString(),
      };
      if (status != null) queryParams['status'] = status;
      
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _apiService.get(
        'api/admin/applications?$query',
        service: ServiceType.merchant,
      );

      if (response['success'] == true && response['data'] != null) {
        List items;
        
        // Handle both response formats
        if (response['data'] is List) {
          items = response['data'] as List;
        } else if (response['data'] is Map) {
          final data = response['data'] as Map<String, dynamic>;
          items = (data['applications'] ?? data['merchants'] ?? []) as List;
        } else {
          items = [];
        }
        
        final users = items.map((item) {
          // Parse address if it's JSON format
          String? location;
          final businessAddress = item['business_address'];
          if (businessAddress != null && businessAddress.toString().isNotEmpty) {
            location = _parseAddress(businessAddress);
          }
          
          return AdminUser.fromJson({
            'id': item['id'],
            'name': item['contact_person'] ?? item['business_name'] ?? 'Unknown',
            'email': item['email'] ?? '',
            'phone': item['phone'] ?? '',
            'status': item['status'] ?? 'pending',
            'joinDate': item['submitted_at'] ?? item['created_at'] ?? DateTime.now().toIso8601String(),
            'userType': 'merchant',
            'company': item['business_name'],
            'businessType': item['business_type'],
            'location': location,
          });
        }).toList();
        
        return users;
      }
      
      return [];
    } catch (e) {
      print('[ERROR] [USERS] Error fetching merchants: $e');
      throw Exception('Failed to fetch merchants: $e');
    }
  }

  // ==================== REGULAR USER ACTIONS ====================
  
  // Approve regular user (not merchant)
  Future<void> approveUser(String userId) async {
    try {
      await _apiService.post(
        'api/users/$userId/approve',
        {
          'adminNotes': 'User approved by admin',
        },
        service: ServiceType.auth,
      );
    } catch (e) {
      throw Exception('Failed to approve user: $e');
    }
  }

  // Reject regular user (not merchant)
  Future<void> rejectUser(String userId, String reason) async {
    try {
      await _apiService.post(
        'api/users/$userId/reject',
        {
          'rejectionReason': reason,
        },
        service: ServiceType.auth,
      );
    } catch (e) {
      throw Exception('Failed to reject user: $e');
    }
  }

  // Suspend regular user (not merchant)
  Future<void> suspendUser(String userId) async {
    try {
      await _apiService.post(
        'api/users/$userId/suspend',
        {
          'suspensionReason': 'User suspended by admin',
        },
        service: ServiceType.auth,
      );
    } catch (e) {
      throw Exception('Failed to suspend user: $e');
    }
  }

  // ==================== MERCHANT APPLICATION ACTIONS ====================
  
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

  // Helper function to parse address (handles both JSON and string formats)
  static String _parseAddress(dynamic address) {
    if (address == null) return '';
    
    print('🏠 [ADDRESS] Parsing address: $address (type: ${address.runtimeType})');
    
    // If it's a Map (already parsed JSON object), extract fields directly
    if (address is Map) {
      print('   Address is Map, extracting fields...');
      final city = address['city'] ?? address['City'] ?? '';
      final state = address['state'] ?? address['State'] ?? '';
      final country = address['country'] ?? address['Country'] ?? '';
      
      print('   City: $city, State: $state, Country: $country');
      
      final parts = <String>[];
      if (city.toString().isNotEmpty) parts.add(city.toString());
      if (state.toString().isNotEmpty) parts.add(state.toString());
      if (country.toString().isNotEmpty) parts.add(country.toString());
      
      final result = parts.isNotEmpty ? parts.join(', ') : '';
      return result;
    }
    
    // If it's a string
    if (address is String) {
      final trimmed = address.trim();
      if (trimmed.isEmpty) return '';
      
      print('   Address is String: $trimmed');
      
      // Check if it's JSON format
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          print('   Attempting to parse as JSON...');
          // Try to parse as JSON
          final Map<String, dynamic> addressMap = 
              trimmed.startsWith('{') 
                  ? Map<String, dynamic>.from(jsonDecode(trimmed))
                  : {};
          
          // Extract city and country/state
          final city = addressMap['city'] ?? addressMap['City'] ?? '';
          final state = addressMap['state'] ?? addressMap['State'] ?? '';
          final country = addressMap['country'] ?? addressMap['Country'] ?? '';
          
          print('   City: $city, State: $state, Country: $country');
          
          // Build formatted address
          final parts = <String>[];
          if (city.toString().isNotEmpty) parts.add(city.toString());
          if (state.toString().isNotEmpty) parts.add(state.toString());
          if (country.toString().isNotEmpty) parts.add(country.toString());
          
          final result = parts.isNotEmpty ? parts.join(', ') : trimmed;
          return result;
        } catch (e) {
          print('[ERROR] [USERS] JSON parsing failed: $e');
          // If JSON parsing fails, return the original string
          return trimmed;
        }
      }
      
      // Not JSON, return as is
      return trimmed;
    }
    
    // Fallback: convert to string
    return address.toString();
  }

  void dispose() {
    _apiService.dispose();
  }
}