import '../models/transaction.dart';
import '../models/dispute.dart';
import '../models/analytics.dart';
import '../services/api_service.dart';

class TransactionsRepository {
  final ApiService _apiService;

  TransactionsRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Get transactions with analytics
  Future<Map<String, dynamic>> getTransactionsWithAnalytics({
    int page = 1,
    int limit = 10,
    String? status,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('💰 [TRANSACTIONS] Fetching transactions with analytics...');
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _apiService.get(
        'api/transactions?$query',
        service: ServiceType.cashback,
      );

      if (response['success'] == true && response['data'] != null) {
        print('💰 [TRANSACTIONS] Response data keys: ${response['data'].keys.toList()}');
        
        final transactions = (response['data']['transactions'] as List)
            .map((t) => Transaction.fromJson(t))
            .toList();
        
        final analytics = response['data']['analytics'] as Map<String, dynamic>?;
        print('💰 [TRANSACTIONS] Analytics object: $analytics');
        
        if (analytics != null) {
          print('💰 [TRANSACTIONS] Analytics keys: ${analytics.keys.toList()}');
          print('💰 [TRANSACTIONS] totalVolume: ${analytics['totalVolume']}');
          print('💰 [TRANSACTIONS] volumeGrowth: ${analytics['volumeGrowth']}');
          print('💰 [TRANSACTIONS] growth: ${analytics['growth']}');
        }
        
        return {
          'transactions': transactions,
          'analytics': analytics,
        };
      }
      
      print('⚠️ [TRANSACTIONS] No valid data in response');
      return {'transactions': <Transaction>[], 'analytics': null};
    } catch (e) {
      print('❌ [TRANSACTIONS] Error: $e');
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  // Get transactions with filtering (legacy method)
  Future<List<Transaction>> getTransactions({
    int page = 1,
    int limit = 10,
    String? status,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('💰 [TRANSACTIONS] Fetching transactions...');
      print('   Page: $page, Limit: $limit');
      print('   Status: $status, Type: $type');
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      print('   Query: $query');
      print('   Endpoint: api/transactions?$query');
      print('   Service: cashback (port 4002)');
      
      final response = await _apiService.get(
        'api/transactions?$query',
        service: ServiceType.cashback,
      );

      print('✅ [TRANSACTIONS] Response received');
      print('   Success: ${response['success']}');
      print('   Has data: ${response['data'] != null}');
      print('   Response keys: ${response.keys.toList()}');

      if (response['success'] == true && response['data'] != null) {
        print('   Data keys: ${response['data'].keys.toList()}');
        
        // Store analytics if present
        Map<String, dynamic>? analytics;
        if (response['data']['analytics'] != null) {
          analytics = response['data']['analytics'] as Map<String, dynamic>;
          print('   Analytics: $analytics');
        }
        
        if (response['data']['transactions'] != null) {
          final transactions = response['data']['transactions'] as List;
          print('   Transactions found: ${transactions.length}');
          final transactionsList = transactions.map((t) => Transaction.fromJson(t)).toList();
          
          // Return both transactions and analytics
          // We'll need to modify the return type
          return transactionsList;
        } else if (response['data'] is List) {
          final transactions = response['data'] as List;
          print('   Transactions found (direct array): ${transactions.length}');
          return transactions.map((t) => Transaction.fromJson(t)).toList();
        }
      }
      
      print('⚠️ [TRANSACTIONS] No transactions found, returning empty list');
      return [];
    } catch (e) {
      print('❌ [TRANSACTIONS] Error: $e');
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  // Get transaction analytics
  Future<Analytics> getTransactionAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (type != null) queryParams['type'] = type;
      
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _apiService.get(
        'api/transactions/analytics${query.isNotEmpty ? '?$query' : ''}',
        service: ServiceType.cashback,
      );

      if (response['success'] == true && response['data'] != null) {
        return Analytics.fromJson(response['data']);
      }
      throw Exception('No analytics data available');
    } catch (e) {
      throw Exception('Failed to fetch analytics: $e');
    }
  }

  // Get disputes
  Future<List<Dispute>> getDisputes({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;
      
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _apiService.get(
        'api/disputes?$query',
        service: ServiceType.cashback,
      );

      if (response['success'] == true && response['data'] != null) {
        final disputes = response['data']['disputes'] as List;
        return disputes.map((d) => Dispute.fromJson(d)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch disputes: $e');
    }
  }

  // Resolve dispute
  Future<void> resolveDispute(String disputeId, String resolution, {String? notes}) async {
    try {
      await _apiService.post(
        'api/disputes/$disputeId/resolve',
        {
          'resolution': resolution,
          'notes': notes ?? 'Dispute resolved by admin',
        },
        service: ServiceType.cashback,
      );
    } catch (e) {
      throw Exception('Failed to resolve dispute: $e');
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}