import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/admin_activity.dart';
import '../models/recent_activity.dart';
import '../repositories/admin_activity_repository.dart';
import '../repositories/notifications_repository.dart';
import '../repositories/posts_repository.dart';
import '../repositories/transactions_repository.dart';
import '../repositories/users_repository.dart';
import '../utils/recent_activity_helper.dart';

// Events
abstract class ActivityFeedEvent extends Equatable {
  const ActivityFeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadActivities extends ActivityFeedEvent {
  final int page;
  final int limit;
  final String? entityTypeFilter;
  final String? statusFilter;
  final String? searchQuery;
  final String sortOrder; // 'newest' or 'oldest'

  const LoadActivities({
    this.page = 1,
    this.limit = 20,
    this.entityTypeFilter,
    this.statusFilter,
    this.searchQuery,
    this.sortOrder = 'newest',
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    entityTypeFilter,
    statusFilter,
    searchQuery,
    sortOrder,
  ];
}

class LoadMoreActivities extends ActivityFeedEvent {
  const LoadMoreActivities();
}

class FilterActivities extends ActivityFeedEvent {
  final String? entityTypeFilter;
  final String? statusFilter;

  const FilterActivities({this.entityTypeFilter, this.statusFilter});

  @override
  List<Object?> get props => [entityTypeFilter, statusFilter];
}

class SearchActivities extends ActivityFeedEvent {
  final String? searchQuery;

  const SearchActivities(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}

class SortActivities extends ActivityFeedEvent {
  final String sortOrder; // 'newest' or 'oldest'

  const SortActivities(this.sortOrder);

  @override
  List<Object?> get props => [sortOrder];
}

// States
abstract class ActivityFeedState extends Equatable {
  const ActivityFeedState();

  @override
  List<Object?> get props => [];
}

class ActivityFeedInitial extends ActivityFeedState {}

class ActivityFeedLoading extends ActivityFeedState {}

class ActivityFeedLoaded extends ActivityFeedState {
  final List<RecentActivity> activities;
  final int currentPage;
  final bool hasMore;
  final String? entityTypeFilter;
  final String? statusFilter;
  final String? searchQuery;
  final String sortOrder;

  const ActivityFeedLoaded({
    required this.activities,
    this.currentPage = 1,
    this.hasMore = true,
    this.entityTypeFilter,
    this.statusFilter,
    this.searchQuery,
    this.sortOrder = 'newest',
  });

  @override
  List<Object?> get props => [
    activities,
    currentPage,
    hasMore,
    entityTypeFilter,
    statusFilter,
    searchQuery,
    sortOrder,
  ];
}

class ActivityFeedError extends ActivityFeedState {
  final String message;

  const ActivityFeedError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ActivityFeedBloc extends Bloc<ActivityFeedEvent, ActivityFeedState> {
  final UsersRepository _usersRepository;
  final PostsRepository _postsRepository;
  final TransactionsRepository _transactionsRepository;
  final NotificationsRepository _notificationsRepository;
  final AdminActivityRepository _adminActivityRepository;

  ActivityFeedBloc({
    UsersRepository? usersRepository,
    PostsRepository? postsRepository,
    TransactionsRepository? transactionsRepository,
    NotificationsRepository? notificationsRepository,
    AdminActivityRepository? adminActivityRepository,
  }) : _usersRepository = usersRepository ?? UsersRepository(),
       _postsRepository = postsRepository ?? PostsRepository(),
       _transactionsRepository =
           transactionsRepository ?? TransactionsRepository(),
       _notificationsRepository =
           notificationsRepository ?? NotificationsRepository(),
       _adminActivityRepository =
           adminActivityRepository ?? AdminActivityRepository(),
       super(ActivityFeedInitial()) {
    on<LoadActivities>(_onLoadActivities);
    on<LoadMoreActivities>(_onLoadMoreActivities);
    on<FilterActivities>(_onFilterActivities);
    on<SearchActivities>(_onSearchActivities);
    on<SortActivities>(_onSortActivities);
  }

  Future<void> _onLoadActivities(
    LoadActivities event,
    Emitter<ActivityFeedState> emit,
  ) async {
    emit(ActivityFeedLoading());
    await _loadActivitiesData(emit, event);
  }

  Future<void> _onLoadMoreActivities(
    LoadMoreActivities event,
    Emitter<ActivityFeedState> emit,
  ) async {
    if (state is ActivityFeedLoaded) {
      final currentState = state as ActivityFeedLoaded;
      if (!currentState.hasMore) return;

      final nextPage = currentState.currentPage + 1;
      final loadEvent = LoadActivities(
        page: nextPage,
        limit: 20,
        entityTypeFilter: currentState.entityTypeFilter,
        statusFilter: currentState.statusFilter,
        searchQuery: currentState.searchQuery,
        sortOrder: currentState.sortOrder,
      );

      await _loadActivitiesData(
        emit,
        loadEvent,
        append: true,
        currentActivities: currentState.activities,
      );
    }
  }

  Future<void> _onFilterActivities(
    FilterActivities event,
    Emitter<ActivityFeedState> emit,
  ) async {
    final loadEvent = LoadActivities(
      page: 1,
      limit: 20,
      entityTypeFilter: event.entityTypeFilter,
      statusFilter: event.statusFilter,
      searchQuery: state is ActivityFeedLoaded
          ? (state as ActivityFeedLoaded).searchQuery
          : null,
      sortOrder: state is ActivityFeedLoaded
          ? (state as ActivityFeedLoaded).sortOrder
          : 'newest',
    );

    await _loadActivitiesData(emit, loadEvent);
  }

  Future<void> _onSearchActivities(
    SearchActivities event,
    Emitter<ActivityFeedState> emit,
  ) async {
    final loadEvent = LoadActivities(
      page: 1,
      limit: 20,
      entityTypeFilter: state is ActivityFeedLoaded
          ? (state as ActivityFeedLoaded).entityTypeFilter
          : null,
      statusFilter: state is ActivityFeedLoaded
          ? (state as ActivityFeedLoaded).statusFilter
          : null,
      searchQuery: event.searchQuery,
      sortOrder: state is ActivityFeedLoaded
          ? (state as ActivityFeedLoaded).sortOrder
          : 'newest',
    );

    await _loadActivitiesData(emit, loadEvent);
  }

  Future<void> _onSortActivities(
    SortActivities event,
    Emitter<ActivityFeedState> emit,
  ) async {
    if (state is ActivityFeedLoaded) {
      final currentState = state as ActivityFeedLoaded;
      final sortedActivities = List<RecentActivity>.from(currentState.activities);

      sortedActivities.sort((a, b) {
        final timeA = a.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final timeB = b.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        if (event.sortOrder == 'newest') {
          return timeB.compareTo(timeA);
        } else {
          return timeA.compareTo(timeB);
        }
      });

      emit(
        ActivityFeedLoaded(
          activities: sortedActivities,
          currentPage: currentState.currentPage,
          hasMore: currentState.hasMore,
          entityTypeFilter: currentState.entityTypeFilter,
          statusFilter: currentState.statusFilter,
          searchQuery: currentState.searchQuery,
          sortOrder: event.sortOrder,
        ),
      );
    }
  }

  Future<void> _loadActivitiesData(
    Emitter<ActivityFeedState> emit,
    LoadActivities event, {
    bool append = false,
    List<RecentActivity>? currentActivities,
  }) async {
    try {
      // Load data from all sources with pagination
      final usersData = await _loadAllUsersData(event.page, event.limit);
      final postsData = await _loadPostsData(event.page, event.limit);
      final transactionsData = await _loadTransactionsData(
        event.page,
        event.limit,
      );
      final notificationsData = await _loadNotificationsData(
        event.page,
        event.limit,
      );
      final adminActivitiesData = await _loadAdminActivitiesData(
        event.page,
        event.limit,
      );

      final allActivities = RecentActivityHelper.generateActivities(
        usersData: usersData,
        postsData: postsData,
        transactionsData: transactionsData,
        notificationsData: notificationsData,
        adminActivitiesData: adminActivitiesData,
        maxActivities: event.limit,
        condensed: false,
      );

      // Apply filters
      var filteredActivities = allActivities;

      if (event.entityTypeFilter != null &&
          event.entityTypeFilter!.isNotEmpty) {
        filteredActivities = filteredActivities.where((a) {
          return a.entityType?.toLowerCase() ==
              event.entityTypeFilter?.toLowerCase();
        }).toList();
      }

      if (event.statusFilter != null && event.statusFilter!.isNotEmpty) {
        filteredActivities = filteredActivities.where((a) {
          if (event.statusFilter == 'pending') {
            return a.isPending;
          }
          return a.status?.toLowerCase() == event.statusFilter?.toLowerCase();
        }).toList();
      }

      // Apply search
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        final query = event.searchQuery!.toLowerCase();
        filteredActivities = filteredActivities.where((a) {
          return a.title.toLowerCase().contains(query) ||
              a.subtitle.toLowerCase().contains(query);
        }).toList();
      }

      // Apply sort
      if (event.sortOrder == 'oldest') {
        filteredActivities.sort((a, b) {
          final timeA = a.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final timeB = b.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return timeA.compareTo(timeB);
        });
      } else {
        // newest (default)
        filteredActivities.sort((a, b) {
          final timeA = a.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final timeB = b.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return timeB.compareTo(timeA);
        });
      }

      // Combine with existing activities if appending
      final finalActivities = append && currentActivities != null
          ? [...currentActivities, ...filteredActivities]
          : filteredActivities;

      // Determine if there are more pages (simple heuristic: if we got full page, assume more)
      final hasMore = filteredActivities.length >= event.limit;

      emit(
        ActivityFeedLoaded(
          activities: finalActivities,
          currentPage: event.page,
          hasMore: hasMore,
          entityTypeFilter: event.entityTypeFilter,
          statusFilter: event.statusFilter,
          searchQuery: event.searchQuery,
          sortOrder: event.sortOrder,
        ),
      );
    } catch (e) {
      print('❌ [ACTIVITY_FEED] Error loading activities: $e');
      emit(ActivityFeedError('Failed to load activities: $e'));
    }
  }

  // Helper methods to load data (similar to DashboardBloc)
  Future<Map<String, dynamic>> _loadAllUsersData(int page, int limit) async {
    try {
      final users = await _usersRepository.getRegularUsers(
        page: page,
        limit: limit,
      );

      // Get recent users for activity generation
      final recentUsers = users.take(limit).toList();

      return {'recent': recentUsers};
    } catch (e) {
      print('❌ [ACTIVITY_FEED] Users error: $e');
      return {'recent': []};
    }
  }

  Future<Map<String, dynamic>> _loadPostsData(int page, int limit) async {
    try {
      final posts = await _postsRepository.getAllSocialPostsWithMetadata(
        limit: limit,
        offset: (page - 1) * limit,
        status: 'pending_review',
      );

      // Convert to SocialPost-like objects for activity generation
      final recentPosts = posts.take(limit).toList();

      return {'recent': recentPosts};
    } catch (e) {
      print('❌ [ACTIVITY_FEED] Posts error: $e');
      return {'recent': []};
    }
  }

  Future<Map<String, dynamic>> _loadTransactionsData(
    int page,
    int limit,
  ) async {
    try {
      final transactions = await _transactionsRepository.getTransactions(
        page: page,
        limit: limit,
      );

      // Filter for pending/disputed transactions
      final pendingTransactions = transactions
          .where((t) {
            final status = t.status.toLowerCase();
            return status == 'pending' || status == 'disputed';
          })
          .take(limit)
          .toList();

      return {'recent': pendingTransactions};
    } catch (e) {
      print('❌ [ACTIVITY_FEED] Transactions error: $e');
      return {'recent': []};
    }
  }

  Future<Map<String, dynamic>> _loadNotificationsData(
    int page,
    int limit,
  ) async {
    try {
      final notifications = await _notificationsRepository.getNotifications(
        page: page,
        limit: limit,
      );

      // Filter for scheduled/pending notifications
      final scheduledNotifications = notifications
          .where((n) {
            final status = n.status?.toLowerCase() ?? '';
            return status == 'pending' ||
                status == 'scheduled' ||
                n.sentAt == null;
          })
          .take(limit)
          .toList();

      return {'recent': scheduledNotifications};
    } catch (e) {
      print('❌ [ACTIVITY_FEED] Notifications error: $e');
      return {'recent': []};
    }
  }

  Future<Map<String, dynamic>> _loadAdminActivitiesData(
    int page,
    int limit,
  ) async {
    try {
      final activities = await _adminActivityRepository.getAllRecentActivities(
        limit: limit * 2,
      );

      return {'activities': activities};
    } catch (e) {
      print('❌ [ACTIVITY_FEED] Admin activities error: $e');
      return {'activities': <AdminActivity>[]};
    }
  }
}
