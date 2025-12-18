import '../models/transaction.dart';
import '../models/dispute.dart';
import '../models/analytics.dart';
import '../services/api_service.dart';

class TransactionsRepository {
  final ApiService _apiService;

  // Cache for merchant names to avoid redundant API calls
  final Map<String, String> _merchantNameCache = {};

  // Track ongoing fetch operations to prevent duplicate concurrent requests
  final Map<String, Future<String?>> _pendingMerchantFetches = {};

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
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _apiService.get(
        'api/transactions?$query',
        service: ServiceType.cashback,
      );

      if (response['success'] == true && response['data'] != null) {
        final transactions = (response['data']['transactions'] as List)
            .map((t) => Transaction.fromJson(t))
            .toList();

        // Enrich transactions with merchant business names
        final enrichedTransactions = await _enrichTransactionsWithMerchantNames(
          transactions,
        );

        final analytics =
            response['data']['analytics'] as Map<String, dynamic>?;

        return {'transactions': enrichedTransactions, 'analytics': analytics};
      }

      return {'transactions': <Transaction>[], 'analytics': null};
    } catch (e) {
      print('[ERROR] [TRANSACTIONS] Error: $e');
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
      print('   Page: $page, Limit: $limit');
      print('   Status: $status, Type: $type');

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _apiService.get(
        'api/transactions?$query',
        service: ServiceType.cashback,
      );

      if (response['success'] == true && response['data'] != null) {
        if (response['data']['transactions'] != null) {
          final transactions = response['data']['transactions'] as List;
          final transactionsList = transactions
              .map((t) => Transaction.fromJson(t))
              .toList();

          return transactionsList;
        } else if (response['data'] is List) {
          final transactions = response['data'] as List;
          print('   Transactions found (direct array): ${transactions.length}');
          return transactions.map((t) => Transaction.fromJson(t)).toList();
        }
      }

      return [];
    } catch (e) {
      print('[ERROR] [TRANSACTIONS] Error: $e');
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
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
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
  Future<void> resolveDispute(
    String disputeId,
    String resolution, {
    String? notes,
  }) async {
    try {
      await _apiService.post('api/disputes/$disputeId/resolve', {
        'resolution': resolution,
        'notes': notes ?? 'Dispute resolved by admin',
      }, service: ServiceType.cashback);
    } catch (e) {
      throw Exception('Failed to resolve dispute: $e');
    }
  }

  /// Fetch merchant business name by profile ID
  /// Uses caching to avoid redundant API calls
  Future<String?> _fetchMerchantBusinessName(String merchantId) async {
    // Return cached value if available
    if (_merchantNameCache.containsKey(merchantId)) {
      return _merchantNameCache[merchantId];
    }

    // Return existing pending fetch if one is in progress
    if (_pendingMerchantFetches.containsKey(merchantId)) {
      return _pendingMerchantFetches[merchantId];
    }

    // Create new fetch operation
    final fetchFuture = _fetchMerchantProfile(merchantId);
    _pendingMerchantFetches[merchantId] = fetchFuture;

    try {
      final businessName = await fetchFuture;
      if (businessName != null) {
        _merchantNameCache[merchantId] = businessName;
      }
      return businessName;
    } finally {
      _pendingMerchantFetches.remove(merchantId);
    }
  }

  /// Internal method to fetch merchant profile from API
  Future<String?> _fetchMerchantProfile(String merchantId) async {
    try {

      final response = await _apiService.get(
        'api/profiles/admin/$merchantId',
        service: ServiceType.merchant,
      );

      if (response['success'] == true && response['data'] != null) {
        final profileData = response['data'] as Map<String, dynamic>;

        // Try multiple possible field names for business name
        final businessName =
            profileData['businessName'] as String? ??
            profileData['business_name'] as String? ??
            profileData['name'] as String?;

        if (businessName != null && businessName.isNotEmpty) {
          return businessName;
        }
      }

      return null;
    } catch (e) {
      // Log error but don't throw - gracefully handle missing merchants
      print('[ERROR] [MERCHANT] Failed to fetch profile for $merchantId: $e');
      return null;
    }
  }

  /// Enrich transactions with merchant business names
  /// Fetches merchant names in parallel for efficiency
  Future<List<Transaction>> _enrichTransactionsWithMerchantNames(
    List<Transaction> transactions,
  ) async {
    if (transactions.isEmpty) {
      return transactions;
    }

    print(
      '🏪 [MERCHANT] Enriching ${transactions.length} transactions with merchant names...',
    );

    // Extract unique merchant IDs from transactions
    final merchantIds = transactions
        .map((t) => t.metadata?['merchantId'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .toSet()
        .toList();

    if (merchantIds.isEmpty) {
      return transactions;
    }


    // Fetch all merchant names in parallel
    final merchantNameFutures = merchantIds.map((merchantId) async {
      final name = await _fetchMerchantBusinessName(merchantId!);
      return MapEntry(merchantId, name);
    });

    final merchantNameMap = <String, String>{};
    final results = await Future.wait(merchantNameFutures);

    for (final entry in results) {
      if (entry.value != null) {
        merchantNameMap[entry.key] = entry.value!;
      }
    }


    // Update transaction metadata with merchant names
    final enrichedTransactions = transactions.map((transaction) {
      final merchantId = transaction.metadata?['merchantId'] as String?;

      if (merchantId != null && merchantNameMap.containsKey(merchantId)) {
        final updatedMetadata = Map<String, dynamic>.from(
          transaction.metadata ?? {},
        );
        updatedMetadata['storeName'] = merchantNameMap[merchantId];

        // Create new transaction with updated metadata
        return Transaction(
          id: transaction.id,
          amount: transaction.amount,
          type: transaction.type,
          status: transaction.status,
          description: transaction.description,
          createdAt: transaction.createdAt,
          campaignId: transaction.campaignId,
          metadata: updatedMetadata,
        );
      }

      return transaction;
    }).toList();

    return enrichedTransactions;
  }

  /// Clear merchant name cache (useful for testing or forced refresh)
  void clearMerchantCache() {
    _merchantNameCache.clear();
  }

  void dispose() {
    _merchantNameCache.clear();
    _pendingMerchantFetches.clear();
    _apiService.dispose();
  }
}
