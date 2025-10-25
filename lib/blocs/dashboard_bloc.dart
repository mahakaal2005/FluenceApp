import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/users_repository.dart';
import '../repositories/posts_repository.dart';
import '../repositories/transactions_repository.dart';
import '../repositories/notifications_repository.dart';

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
  final int pendingPosts;
  final int activeSessions;
  final double totalTransactionVolume;
  final List<RecentActivity> recentActivities;
  final int unreadNotifications;

  const DashboardData({
    required this.totalUsers,
    required this.pendingPosts,
    required this.activeSessions,
    required this.totalTransactionVolume,
    required this.recentActivities,
    required this.unreadNotifications,
  });

  @override
  List<Object?> get props => [
    totalUsers,
    pendingPosts,
    activeSessions,
    totalTransactionVolume,
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

  DashboardBloc({
    UsersRepository? usersRepository,
    PostsRepository? postsRepository,
    TransactionsRepository? transactionsRepository,
    NotificationsRepository? notificationsRepository,
  })  : _usersRepository = usersRepository ?? UsersRepository(),
        _postsRepository = postsRepository ?? PostsRepository(),
        _transactionsRepository = transactionsRepository ?? TransactionsRepository(),
        _notificationsRepository = notificationsRepository ?? NotificationsRepository(),
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
      ]);

      final usersData = results[0];
      final postsData = results[1];
      final transactionsData = results[2];
      final notificationsData = results[3];

      final dashboardData = DashboardData(
        totalUsers: usersData['total'] ?? 0,
        pendingPosts: postsData['pending'] ?? 0,
        activeSessions: 8, // Mock data - would come from auth service
        totalTransactionVolume: transactionsData['volume'] ?? 0.0,
        recentActivities: _generateRecentActivities(usersData, postsData, transactionsData),
        unreadNotifications: notificationsData['unread'] ?? 0,
      );

      emit(DashboardLoaded(dashboardData));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard data: $e'));
    }
  }

  Future<Map<String, dynamic>> _loadUsersData() async {
    try {
      final users = await _usersRepository.getMerchantApplications(limit: 100);
      return {
        'total': users.length,
        'pending': users.where((u) => u.status == 'pending').length,
        'recent': users.take(3).toList(),
      };
    } catch (e) {
      return {'total': 0, 'pending': 0, 'recent': []};
    }
  }

  Future<Map<String, dynamic>> _loadPostsData() async {
    try {
      final posts = await _postsRepository.getPendingSocialPosts();
      return {
        'pending': posts.length,
        'recent': posts.take(3).toList(),
      };
    } catch (e) {
      return {'pending': 0, 'recent': []};
    }
  }

  Future<Map<String, dynamic>> _loadTransactionsData() async {
    try {
      final result = await _transactionsRepository.getTransactionsWithAnalytics(limit: 100);
      final analytics = result['analytics'] as Map<String, dynamic>?;
      
      if (analytics != null) {
        final volumeValue = analytics['totalVolume'];
        final volume = volumeValue is int ? volumeValue.toDouble() : (volumeValue ?? 0.0);
        return {
          'volume': volume,
          'count': analytics['processed'] ?? 0,
        };
      }
      return {'volume': 0.0, 'count': 0};
    } catch (e) {
      print('❌ Dashboard transactions error: $e');
      return {'volume': 0.0, 'count': 0};
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

  List<RecentActivity> _generateRecentActivities(
    Map<String, dynamic> usersData,
    Map<String, dynamic> postsData,
    Map<String, dynamic> transactionsData,
  ) {
    final activities = <RecentActivity>[];

    // Add user registration activities
    if (usersData['recent'] != null) {
      final recentUsers = usersData['recent'] as List;
      for (final user in recentUsers.take(2)) {
        activities.add(RecentActivity(
          title: 'New user registration',
          subtitle: user.name ?? 'Unknown User',
          time: _getRelativeTime(user.joinDate ?? DateTime.now()),
          iconPath: 'assets/images/activity_icon_1.png',
          iconBgColor: 'yellow',
        ));
      }
    }

    // Add post submission activities
    if (postsData['recent'] != null) {
      final recentPosts = postsData['recent'] as List;
      for (final post in recentPosts.take(1)) {
        activities.add(RecentActivity(
          title: 'Post submitted for review',
          subtitle: 'User: ${post.username ?? post.displayName ?? 'Unknown'}',
          time: _getRelativeTime(post.createdAt ?? DateTime.now()),
          iconPath: 'assets/images/activity_icon_2.png',
          iconBgColor: 'yellow',
        ));
      }
    }

    // Add mock dispute activity
    activities.add(const RecentActivity(
      title: 'Payment dispute raised',
      subtitle: 'Transaction #4529',
      time: '1 hour ago',
      iconPath: 'assets/images/activity_icon_3.png',
      iconBgColor: 'red',
    ));

    return activities.take(4).toList();
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
    return super.close();
  }
}