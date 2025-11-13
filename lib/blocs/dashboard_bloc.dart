import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/users_repository.dart';
import '../repositories/posts_repository.dart';
import '../repositories/transactions_repository.dart';
import '../repositories/notifications_repository.dart';
import '../repositories/sessions_repository.dart';
import '../repositories/admin_activity_repository.dart';
import '../models/admin_activity.dart';
import '../models/user.dart';
import '../models/recent_activity.dart';
import '../utils/recent_activity_helper.dart';

// Dashboard type enum
enum DashboardType { users, merchants }

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final DashboardType type;
  
  const LoadDashboardData({this.type = DashboardType.merchants});
  
  @override
  List<Object?> get props => [type];
}

class RefreshDashboardData extends DashboardEvent {
  final DashboardType type;
  
  const RefreshDashboardData({this.type = DashboardType.merchants});
  
  @override
  List<Object?> get props => [type];
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData data;
  
  const DashboardLoaded(this.data);
  
  @override
  List<Object?> get props => [data];
}

class DashboardError extends DashboardState {
  final String message;
  
  const DashboardError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Data model for dashboard
class DashboardData extends Equatable {
  final int totalUsers;
  final double totalUsersGrowth;
  final int pendingUsers;
  final double pendingUsersGrowth;
  final int approvedUsers;
  final double approvedUsersGrowth;
  final int pendingPosts;
  final double pendingPostsGrowth;
  final int activeSessions;
  final double activeSessionsGrowth;
  final double totalTransactionVolume;
  final double transactionVolumeGrowth;
  final List<RecentActivity> recentActivities;
  final int unreadNotifications;

  const DashboardData({
    required this.totalUsers,
    this.totalUsersGrowth = 0.0,
    required this.pendingUsers,
    this.pendingUsersGrowth = 0.0,
    required this.approvedUsers,
    this.approvedUsersGrowth = 0.0,
    required this.pendingPosts,
    this.pendingPostsGrowth = 0.0,
    required this.activeSessions,
    this.activeSessionsGrowth = 0.0,
    required this.totalTransactionVolume,
    this.transactionVolumeGrowth = 0.0,
    this.recentActivities = const [],
    this.unreadNotifications = 0,
  });

  // Verified users is the same as approved users
  int get verifiedUsers => approvedUsers;

  @override
  List<Object?> get props => [
    totalUsers,
    totalUsersGrowth,
    pendingUsers,
    pendingUsersGrowth,
    approvedUsers,
    approvedUsersGrowth,
    pendingPosts,
    pendingPostsGrowth,
    activeSessions,
    activeSessionsGrowth,
    totalTransactionVolume,
    transactionVolumeGrowth,
    recentActivities,
    unreadNotifications,
  ];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final UsersRepository _usersRepository;
  final PostsRepository _postsRepository;
  final TransactionsRepository _transactionsRepository;
  final NotificationsRepository _notificationsRepository;
  final SessionsRepository _sessionsRepository;
  final AdminActivityRepository _adminActivityRepository;

  DashboardBloc({
    UsersRepository? usersRepository,
    PostsRepository? postsRepository,
    TransactionsRepository? transactionsRepository,
    NotificationsRepository? notificationsRepository,
    SessionsRepository? sessionsRepository,
    AdminActivityRepository? adminActivityRepository,
  })  : _usersRepository = usersRepository ?? UsersRepository(),
        _postsRepository = postsRepository ?? PostsRepository(),
        _transactionsRepository = transactionsRepository ?? TransactionsRepository(),
        _notificationsRepository = notificationsRepository ?? NotificationsRepository(),
        _sessionsRepository = sessionsRepository ?? SessionsRepository(),
        _adminActivityRepository = adminActivityRepository ?? AdminActivityRepository(),
        super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  Future<void> _onLoadDashboardData(LoadDashboardData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    await _loadData(emit, event.type);
  }

  Future<void> _onRefreshDashboardData(RefreshDashboardData event, Emitter<DashboardState> emit) async {
    await _loadData(emit, event.type);
  }

  Future<void> _loadData(Emitter<DashboardState> emit, DashboardType dashboardType) async {
    try {
      // Load data from multiple repositories concurrently
      final results = await Future.wait<Map<String, dynamic>>([
        _loadUsersData(dashboardType),
        _loadPostsData(),
        _loadTransactionsData(),
        _loadNotificationsData(),
        _loadSessionsData(),
        _loadAdminActivitiesData(),
      ]);

      final usersData = results[0];
      final postsData = results[1];
      final transactionsData = results[2];
      final notificationsData = results[3];
      final sessionsData = results[4];
      final adminActivitiesData = results[5];

      final totalUsers = usersData['total'] ?? 0;
      final pendingUsers = usersData['pending'] ?? 0;
      final approvedUsers = totalUsers - pendingUsers;

      final dashboardData = DashboardData(
        totalUsers: totalUsers,
        totalUsersGrowth: usersData['growth'] ?? 0.0,
        pendingUsers: pendingUsers,
        pendingUsersGrowth: usersData['pendingGrowth'] ?? 0.0,
        approvedUsers: approvedUsers,
        approvedUsersGrowth: usersData['approvedGrowth'] ?? 0.0,
        pendingPosts: postsData['pending'] ?? 0,
        pendingPostsGrowth: postsData['growth'] ?? 0.0,
        activeSessions: sessionsData['activeSessions'] ?? 0,
        activeSessionsGrowth: sessionsData['growth'] ?? 0.0,
        totalTransactionVolume: transactionsData['volume'] ?? 0.0,
        transactionVolumeGrowth: transactionsData['growth'] ?? 0.0,
        recentActivities: RecentActivityHelper.generateActivities(
          usersData: usersData,
          postsData: postsData,
          transactionsData: transactionsData,
          notificationsData: notificationsData,
          adminActivitiesData: adminActivitiesData,
          maxActivities: 10,
          condensed: true,
        ),
        unreadNotifications: notificationsData['unread'] ?? 0,
      );

      emit(DashboardLoaded(dashboardData));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard data: $e'));
    }
  }

  Future<Map<String, dynamic>> _loadUsersData(DashboardType dashboardType) async {
    try {
      if (dashboardType == DashboardType.users) {
        // Fetch from auth service - all users
        print('\n📊 [DASHBOARD_DATA] Loading Users Data from Auth Service...');
        return await _loadAllUsersData();
      } else {
        // Fetch from merchant service - merchant applications
        print('\n📊 [DASHBOARD_DATA] Loading Merchant Applications Data...');
        return await _loadMerchantApplicationsData();
      }
    } catch (e) {
      print('❌ [DASHBOARD_DATA] Users data error: $e');
      return {
        'total': 0, 
        'growth': 0.0,
        'pending': 0, 
        'recent': [],
      };
    }
  }

  Future<Map<String, dynamic>> _loadAllUsersData() async {
    try {
      // Fetch all users from auth service with role='user' (regular app users, not merchants)
      final allUsersResponse = await _usersRepository.getAllUsers(limit: 1000, role: 'user');
      final totalUsers = allUsersResponse.length;
      print('   ✓ Fetched $totalUsers total regular users (role=user) from auth service');
      
      // For Users Dashboard, count based on is_approved field
      // Backend uses is_approved field for user approval workflow:
      // - Pending Users = users where is_approved is false or null (awaiting admin approval)
      // - Approved Users = users where is_approved is true
      
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      // Helper function to check if user was created recently
      bool isRecentUser(Map<String, dynamic> u) {
        final createdAt = u['created_at'];
        if (createdAt == null) return false;
        try {
          final date = DateTime.parse(createdAt.toString());
          return date.isAfter(sevenDaysAgo);
        } catch (e) {
          return false;
        }
      }
      
      // Calculate overall users count and growth
      int recentUsers = 0;
      try {
        recentUsers = allUsersResponse.where(isRecentUser).length;
      } catch (e) {
        print('   ⚠️  Could not calculate recent users: $e');
      }
      
      final previousUsers = totalUsers - recentUsers;
      final growth = previousUsers > 0 
          ? ((recentUsers / previousUsers) * 100)
          : (recentUsers > 0 ? 100.0 : 0.0);
      
      // Calculate pending users count and growth
      final pendingUsersList = allUsersResponse.where((u) => 
        u['is_approved'] == false || u['is_approved'] == null
      ).toList();
      final totalPending = pendingUsersList.length;
      final recentPending = pendingUsersList.where(isRecentUser).length;
      final previousPending = totalPending - recentPending;
      final pendingGrowth = previousPending > 0
          ? ((recentPending / previousPending) * 100)
          : (recentPending > 0 ? 100.0 : 0.0);
      
      // Calculate approved users count and growth
      final approvedUsersList = allUsersResponse.where((u) => u['is_approved'] == true).toList();
      final totalApproved = approvedUsersList.length;
      final recentApproved = approvedUsersList.where(isRecentUser).length;
      final previousApproved = totalApproved - recentApproved;
      final approvedGrowth = previousApproved > 0
          ? ((recentApproved / previousApproved) * 100)
          : (recentApproved > 0 ? 100.0 : 0.0);
      
      print('   ✓ Total: $totalUsers, Pending (is_approved=false/null): $totalPending, Approved (is_approved=true): $totalApproved');
      print('   ✓ Total Growth: ${growth.toStringAsFixed(1)}% (recent: $recentUsers, previous: $previousUsers)');
      print('   ✓ Pending Growth: ${pendingGrowth.toStringAsFixed(1)}% (recent: $recentPending, previous: $previousPending)');
      print('   ✓ Approved Growth: ${approvedGrowth.toStringAsFixed(1)}% (recent: $recentApproved, previous: $previousApproved)');
      
      // Get recent pending users for activities
      final recentPendingUsers = pendingUsersList.take(3).toList();
      print('   ✓ Recent pending users for activity: ${recentPendingUsers.length}');
      
      // Convert to AdminUser format for activities
      final recentUsersForActivity = recentPendingUsers.map((u) {
        return AdminUser.fromJson({
          'id': u['id'],
          'name': u['name'] ?? 'Unknown',
          'email': u['email'] ?? '',
          'phone': u['phone'] ?? '',
          'status': 'pending', // Already filtered to pending
          'joinDate': u['created_at'] ?? DateTime.now().toIso8601String(),
          'userType': 'user',
          'company': null,
          'businessType': null,
          'location': null,
        });
      }).toList();
      
      return {
        'total': totalUsers,
        'growth': double.parse(growth.toStringAsFixed(1)),
        'pending': totalPending,
        'pendingGrowth': double.parse(pendingGrowth.toStringAsFixed(1)),
        'approvedGrowth': double.parse(approvedGrowth.toStringAsFixed(1)),
        'recent': recentUsersForActivity, // Recent pending users for review
      };
    } catch (e) {
      print('❌ [DASHBOARD_DATA] All users data error: $e');
      return {
        'total': 0,
        'growth': 0.0,
        'pending': 0,
        'pendingGrowth': 0.0,
        'approvedGrowth': 0.0,
        'recent': [],
      };
    }
  }

  Future<Map<String, dynamic>> _loadMerchantApplicationsData() async {
    try {
      final users = await _usersRepository.getMerchantApplications(limit: 100);
      final totalUsers = users.length;
      print('   ✓ Fetched $totalUsers merchant applications');
      
      // Calculate overall growth: compare with users from 7 days ago
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final recentUsers = users.where((u) => u.joinDate.isAfter(sevenDaysAgo)).length;
      final previousUsers = totalUsers - recentUsers;
      
      final growth = previousUsers > 0 
        ? ((recentUsers / previousUsers) * 100)
        : (recentUsers > 0 ? 100.0 : 0.0);
      
      // Calculate pending merchants growth
      final pendingMerchants = users.where((u) => u.status == 'pending').toList();
      final totalPending = pendingMerchants.length;
      final recentPending = pendingMerchants.where((u) => u.joinDate.isAfter(sevenDaysAgo)).length;
      final previousPending = totalPending - recentPending;
      final pendingGrowth = previousPending > 0
          ? ((recentPending / previousPending) * 100)
          : (recentPending > 0 ? 100.0 : 0.0);
      
      // Calculate approved merchants growth
      final approvedMerchants = users.where((u) => u.status == 'approved').toList();
      final totalApproved = approvedMerchants.length;
      final recentApproved = approvedMerchants.where((u) => u.joinDate.isAfter(sevenDaysAgo)).length;
      final previousApproved = totalApproved - recentApproved;
      final approvedGrowth = previousApproved > 0
          ? ((recentApproved / previousApproved) * 100)
          : (recentApproved > 0 ? 100.0 : 0.0);
      
      print('   ✓ Total Growth: ${growth.toStringAsFixed(1)}%');
      print('   ✓ Pending ($totalPending): ${pendingGrowth.toStringAsFixed(1)}% (recent: $recentPending, previous: $previousPending)');
      print('   ✓ Approved ($totalApproved): ${approvedGrowth.toStringAsFixed(1)}% (recent: $recentApproved, previous: $previousApproved)');
      
      // Get recent pending merchants for activities
      final recentPendingMerchants = pendingMerchants.take(3).toList();
      print('   ✓ Recent pending applications for activity: ${recentPendingMerchants.length}');
      for (var i = 0; i < recentPendingMerchants.length; i++) {
        print('     ${i + 1}. ${recentPendingMerchants[i].name} (${recentPendingMerchants[i].email})');
      }
      
      return {
        'total': totalUsers,
        'growth': double.parse(growth.toStringAsFixed(1)),
        'pending': totalPending,
        'pendingGrowth': double.parse(pendingGrowth.toStringAsFixed(1)),
        'approvedGrowth': double.parse(approvedGrowth.toStringAsFixed(1)),
        'recent': recentPendingMerchants, // Only pending merchants for review
      };
    } catch (e) {
      print('❌ [DASHBOARD_DATA] Merchant applications data error: $e');
      return {
        'total': 0, 
        'growth': 0.0,
        'pending': 0,
        'pendingGrowth': 0.0,
        'approvedGrowth': 0.0,
        'recent': [],
      };
    }
  }

  Future<Map<String, dynamic>> _loadSessionsData() async {
    try {
      return await _sessionsRepository.getActiveSessions();
    } catch (e) {
      print('❌ Dashboard sessions error: $e');
      return {
        'activeSessions': 0,
        'growth': 0.0,
      };
    }
  }

  Future<Map<String, dynamic>> _loadPostsData() async {
    try {
      print('\n📊 [DASHBOARD_DATA] Loading Posts Data...');
      final posts = await _postsRepository.getPendingSocialPosts();
      final pendingCount = posts.length;
      print('   ✓ Fetched $pendingCount pending posts');
      
      // Calculate growth based on post age distribution
      // Compare posts from last 7 days vs previous 7 days
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final fourteenDaysAgo = now.subtract(const Duration(days: 14));
      
      final recentPosts = posts.where((p) {
        final createdAt = p.createdAt;
        return createdAt != null && createdAt.isAfter(sevenDaysAgo);
      }).length;
      
      final olderPosts = posts.where((p) {
        final createdAt = p.createdAt;
        return createdAt != null && 
               createdAt.isAfter(fourteenDaysAgo) && 
               createdAt.isBefore(sevenDaysAgo);
      }).length;
      
      // Calculate growth percentage
      double growth = 0.0;
      if (olderPosts > 0) {
        growth = ((recentPosts - olderPosts) / olderPosts) * 100;
      } else if (recentPosts > 0) {
        growth = 100.0;
      } else if (pendingCount > 0) {
        growth = 0.0;
      }
      
      final recentPostsList = posts.take(3).toList();
      print('   ✓ Recent posts for activity: ${recentPostsList.length}');
      // Skip detailed printing to avoid console encoding issues with emojis
      // The data is fine, just the Windows console can't display all Unicode characters
      
      return {
        'pending': pendingCount,
        'growth': double.parse(growth.toStringAsFixed(1)),
        'recent': recentPostsList,
      };
    } catch (e) {
      print('❌ [DASHBOARD_DATA] Posts data error: $e');
      return {'pending': 0, 'growth': 0.0, 'recent': []};
    }
  }

  Future<Map<String, dynamic>> _loadTransactionsData() async {
    try {
      print('📊 [DASHBOARD] Loading transactions data...');
      final result = await _transactionsRepository.getTransactionsWithAnalytics(limit: 100);
      print('📊 [DASHBOARD] Result keys: ${result.keys.toList()}');
      
      final analytics = result['analytics'] as Map<String, dynamic>?;
      final transactions = result['transactions'] as List? ?? [];
      print('📊 [DASHBOARD] Analytics: $analytics');
      print('📊 [DASHBOARD] Transactions count: ${transactions.length}');
      
      // Get pending and disputed transactions for activities
      final pendingTransactions = transactions.where((t) {
        final status = t.status?.toLowerCase() ?? '';
        return status == 'pending' || status == 'disputed';
      }).take(3).toList();
      
      print('📊 [DASHBOARD] Pending/Disputed transactions: ${pendingTransactions.length}');
      
      if (analytics != null) {
        print('📊 [DASHBOARD] Analytics keys: ${analytics.keys.toList()}');
        
        final volumeValue = analytics['totalVolume'];
        final volume = volumeValue is int ? volumeValue.toDouble() : (volumeValue ?? 0.0);
        print('📊 [DASHBOARD] Volume: $volume');
        
        // Calculate growth from analytics if available
        final growthValue = analytics['volumeGrowth'] ?? analytics['growth'];
        print('📊 [DASHBOARD] Raw growth value: $growthValue (type: ${growthValue.runtimeType})');
        
        final growth = growthValue is int ? growthValue.toDouble() : (growthValue ?? 0.0);
        print('📊 [DASHBOARD] Parsed growth: $growth');
        
        final finalGrowth = double.parse(growth.toStringAsFixed(1));
        print('📊 [DASHBOARD] Final growth: $finalGrowth');
        
        final returnData = {
          'volume': volume,
          'growth': finalGrowth,
          'count': analytics['processed'] ?? 0,
          'recent': pendingTransactions,
        };
        print('📊 [DASHBOARD] Returning: $returnData');
        return returnData;
      }
      print('⚠️ [DASHBOARD] Analytics is null, returning defaults');
      return {'volume': 0.0, 'growth': 0.0, 'count': 0, 'recent': []};
    } catch (e, stackTrace) {
      print('❌ Dashboard transactions error: $e');
      print('❌ Stack trace: $stackTrace');
      return {'volume': 0.0, 'growth': 0.0, 'count': 0, 'recent': []};
    }
  }

  Future<Map<String, dynamic>> _loadNotificationsData() async {
    try {
      final unreadCount = await _notificationsRepository.getUnreadCount();
      
      // Get scheduled/pending notifications for activities
      final notifications = await _notificationsRepository.getNotifications(
        page: 1,
        limit: 10,
      );
      
      // Filter for scheduled/pending notifications
      final scheduledNotifications = notifications.where((n) {
        final status = n.status?.toLowerCase() ?? '';
        return status == 'pending' || status == 'scheduled' || n.sentAt == null;
      }).take(3).toList();
      
      print('📬 [DASHBOARD] Scheduled/Pending notifications: ${scheduledNotifications.length}');
      
      return {
        'unread': unreadCount,
        'recent': scheduledNotifications,
      };
    } catch (e) {
      print('❌ [DASHBOARD] Notifications error: $e');
      return {'unread': 0, 'recent': []};
    }
  }

  Future<Map<String, dynamic>> _loadAdminActivitiesData() async {
    try {
      print('\n📊 [DASHBOARD_DATA] Loading Admin Activities...');
      final activities = await _adminActivityRepository.getAllRecentActivities(limit: 10);
      print('   ✓ Fetched ${activities.length} admin activities');
      return {
        'activities': activities,
      };
    } catch (e) {
      print('❌ [DASHBOARD_DATA] Admin activities error: $e');
      return {
        'activities': <AdminActivity>[],
      };
    }
  }

  @override
  Future<void> close() {
    _usersRepository.dispose();
    _postsRepository.dispose();
    _transactionsRepository.dispose();
    _notificationsRepository.dispose();
    _sessionsRepository.dispose();
    _adminActivityRepository.dispose();
    return super.close();
  }
}