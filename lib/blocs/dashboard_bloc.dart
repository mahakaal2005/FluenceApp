import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/users_repository.dart';
import '../repositories/posts_repository.dart';
import '../repositories/transactions_repository.dart';
import '../repositories/notifications_repository.dart';
import '../repositories/sessions_repository.dart';
import '../repositories/admin_activity_repository.dart';
import '../models/admin_activity.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

class RefreshDashboardData extends DashboardEvent {}

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
    required this.pendingPosts,
    this.pendingPostsGrowth = 0.0,
    required this.activeSessions,
    this.activeSessionsGrowth = 0.0,
    required this.totalTransactionVolume,
    this.transactionVolumeGrowth = 0.0,
    required this.recentActivities,
    required this.unreadNotifications,
  });

  @override
  List<Object?> get props => [
    totalUsers,
    totalUsersGrowth,
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

class RecentActivity extends Equatable {
  final String title;
  final String subtitle;
  final String time;
  final String iconPath;
  final String iconBgColor;

  const RecentActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.iconPath,
    required this.iconBgColor,
  });

  @override
  List<Object?> get props => [title, subtitle, time, iconPath, iconBgColor];
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
    await _loadData(emit);
  }

  Future<void> _onRefreshDashboardData(RefreshDashboardData event, Emitter<DashboardState> emit) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<DashboardState> emit) async {
    try {
      // Load data from multiple repositories concurrently
      final results = await Future.wait<Map<String, dynamic>>([
        _loadUsersData(),
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

      final dashboardData = DashboardData(
        totalUsers: usersData['total'] ?? 0,
        totalUsersGrowth: usersData['growth'] ?? 0.0,
        pendingPosts: postsData['pending'] ?? 0,
        pendingPostsGrowth: postsData['growth'] ?? 0.0,
        activeSessions: sessionsData['activeSessions'] ?? 0,
        activeSessionsGrowth: sessionsData['growth'] ?? 0.0,
        totalTransactionVolume: transactionsData['volume'] ?? 0.0,
        transactionVolumeGrowth: transactionsData['growth'] ?? 0.0,
        recentActivities: _generateRecentActivities(usersData, postsData, transactionsData, adminActivitiesData),
        unreadNotifications: notificationsData['unread'] ?? 0,
      );

      emit(DashboardLoaded(dashboardData));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard data: $e'));
    }
  }

  Future<Map<String, dynamic>> _loadUsersData() async {
    try {
      print('\n📊 [DASHBOARD_DATA] Loading Users Data...');
      final users = await _usersRepository.getMerchantApplications(limit: 100);
      final totalUsers = users.length;
      print('   ✓ Fetched $totalUsers total users');
      
      // Calculate growth: compare with users from 7 days ago
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final recentUsers = users.where((u) => u.joinDate.isAfter(sevenDaysAgo)).length;
      final previousUsers = totalUsers - recentUsers;
      
      final growth = previousUsers > 0 
        ? ((recentUsers / previousUsers) * 100)
        : (recentUsers > 0 ? 100.0 : 0.0);
      
      final recentUsersList = users.take(3).toList();
      print('   ✓ Recent users for activity: ${recentUsersList.length}');
      for (var i = 0; i < recentUsersList.length; i++) {
        print('     ${i + 1}. ${recentUsersList[i].name} (${recentUsersList[i].email})');
      }
      
      return {
        'total': totalUsers,
        'growth': double.parse(growth.toStringAsFixed(1)),
        'pending': users.where((u) => u.status == 'pending').length,
        'recent': recentUsersList,
      };
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
      for (var i = 0; i < recentPostsList.length; i++) {
        final post = recentPostsList[i];
        print('     ${i + 1}. ${post.username ?? post.displayName ?? 'Unknown'} - ${post.content?.substring(0, 30) ?? 'No content'}...');
      }
      
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
      print('📊 [DASHBOARD] Analytics: $analytics');
      
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
        };
        print('📊 [DASHBOARD] Returning: $returnData');
        return returnData;
      }
      print('⚠️ [DASHBOARD] Analytics is null, returning defaults');
      return {'volume': 0.0, 'growth': 0.0, 'count': 0};
    } catch (e, stackTrace) {
      print('❌ Dashboard transactions error: $e');
      print('❌ Stack trace: $stackTrace');
      return {'volume': 0.0, 'growth': 0.0, 'count': 0};
    }
  }

  Future<Map<String, dynamic>> _loadNotificationsData() async {
    try {
      final unreadCount = await _notificationsRepository.getUnreadCount();
      return {'unread': unreadCount};
    } catch (e) {
      return {'unread': 0};
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

  List<RecentActivity> _generateRecentActivities(
    Map<String, dynamic> usersData,
    Map<String, dynamic> postsData,
    Map<String, dynamic> transactionsData,
    Map<String, dynamic> adminActivitiesData,
  ) {
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 [RECENT_ACTIVITY] Generating Recent Activities');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    final activities = <RecentActivity>[];
    int activityCount = 0;

    // PRIORITY 1: Add admin activities (post approvals/rejections, application reviews)
    print('\n🔍 [RECENT_ACTIVITY] Processing Admin Activities...');
    if (adminActivitiesData['activities'] != null) {
      final adminActivities = adminActivitiesData['activities'] as List<AdminActivity>;
      print('   ✓ Found ${adminActivities.length} admin activities');
      
      for (final activity in adminActivities.take(6)) {
        final relativeTime = _getRelativeTime(activity.timestamp);
        
        activities.add(RecentActivity(
          title: activity.title,
          subtitle: activity.subtitle,
          time: relativeTime,
          iconPath: activity.iconPath,
          iconBgColor: activity.iconBgColor,
        ));
        
        activityCount++;
        print('   [$activityCount] ${activity.title} | ${activity.subtitle} | $relativeTime');
      }
    } else {
      print('   ⚠️  No admin activities available');
    }

    // PRIORITY 2: Add user registration activities
    print('\n🔍 [RECENT_ACTIVITY] Processing User Registrations...');
    if (usersData['recent'] != null) {
      final recentUsers = usersData['recent'] as List;
      print('   ✓ Found ${recentUsers.length} recent users');
      
      for (final user in recentUsers.take(2)) {
        final userName = user.name ?? 'Unknown User';
        final joinDate = user.joinDate ?? DateTime.now();
        final relativeTime = _getRelativeTime(joinDate);
        
        activities.add(RecentActivity(
          title: 'New user registration',
          subtitle: userName,
          time: relativeTime,
          iconPath: 'assets/images/activity_icon_1.png',
          iconBgColor: 'yellow',
        ));
        
        activityCount++;
        print('   [$activityCount] User: $userName | Joined: $relativeTime');
      }
    } else {
      print('   ⚠️  No recent users data available');
    }

    // PRIORITY 3: Add post submission activities
    print('\n🔍 [RECENT_ACTIVITY] Processing Post Submissions...');
    if (postsData['recent'] != null) {
      final recentPosts = postsData['recent'] as List;
      print('   ✓ Found ${recentPosts.length} recent posts');
      
      for (final post in recentPosts.take(2)) {
        final username = post.username ?? post.displayName ?? 'Unknown';
        final createdAt = post.createdAt ?? DateTime.now();
        final relativeTime = _getRelativeTime(createdAt);
        
        activities.add(RecentActivity(
          title: 'Post submitted for review',
          subtitle: 'User: $username',
          time: relativeTime,
          iconPath: 'assets/images/activity_icon_2.png',
          iconBgColor: 'yellow',
        ));
        
        activityCount++;
        print('   [$activityCount] Post by: $username | Created: $relativeTime');
      }
    } else {
      print('   ⚠️  No recent posts data available');
    }

    // Take top 10 activities
    final finalActivities = activities.take(10).toList();
    
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ [RECENT_ACTIVITY] Generated ${finalActivities.length} activities');
    print('   Activities breakdown:');
    for (int i = 0; i < finalActivities.length; i++) {
      final activity = finalActivities[i];
      print('   ${i + 1}. ${activity.title} - ${activity.subtitle} (${activity.time})');
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    return finalActivities;
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
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