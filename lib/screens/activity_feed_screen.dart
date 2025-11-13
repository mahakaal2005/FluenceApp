import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/activity_feed_bloc.dart';
import '../models/recent_activity.dart';

class ActivityFeedScreen extends StatefulWidget {
  final Function(int, {String? postId, int? contentTabIndex})? onNavigateToTab;

  const ActivityFeedScreen({super.key, this.onNavigateToTab});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  String? _entityTypeFilter;
  String? _statusFilter;
  String? _searchQuery;
  String _sortOrder = 'newest';

  List<RecentActivity> _previousActivities = [];

  @override
  void initState() {
    super.initState();
    context.read<ActivityFeedBloc>().add(const LoadActivities());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<ActivityFeedBloc>().state;
      if (state is ActivityFeedLoaded && state.hasMore) {
        context.read<ActivityFeedBloc>().add(const LoadMoreActivities());
      }
    }
  }

  void _handleFilterChanged(String? entityType, String? status) {
    setState(() {
      _entityTypeFilter = entityType;
      _statusFilter = status;
    });
    context.read<ActivityFeedBloc>().add(
          FilterActivities(
            entityTypeFilter: entityType,
            statusFilter: status,
          ),
        );
  }

  void _handleSearchChanged(String? query) {
    setState(() {
      _searchQuery = query;
    });
    context.read<ActivityFeedBloc>().add(SearchActivities(query));
  }

  void _handleSortChanged(String order) {
    if (_sortOrder == order) return;
    setState(() {
      _sortOrder = order;
    });
    context.read<ActivityFeedBloc>().add(SortActivities(order));
  }

  void _handleReviewNavigation(RecentActivity activity) {
    final entityType = activity.entityType?.toLowerCase();
    final entityId = activity.entityId;

    if (entityType == null || entityId == null) {
      Navigator.of(context).maybePop();
      return;
    }

    if (widget.onNavigateToTab == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to navigate to the selected item.')),
      );
      return;
    }

    int targetIndex = 1;
    String? postId;
    int? contentTabIndex;

    switch (entityType) {
      case 'post':
        targetIndex = 2;
        postId = entityId;
        break;
      case 'user':
      case 'merchant':
        targetIndex = 1;
        break;
      case 'transaction':
        targetIndex = 3;
        break;
      case 'notification':
        targetIndex = 4;
        contentTabIndex = 1;
        break;
      default:
        targetIndex = 1;
        break;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onNavigateToTab?.call(
        targetIndex,
        postId: postId,
        contentTabIndex: contentTabIndex,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Activities'),
        actions: [
          IconButton(
            icon: Icon(
              _sortOrder == 'newest' ? Icons.south : Icons.north,
            ),
            tooltip:
                _sortOrder == 'newest' ? 'Sort: Newest first' : 'Sort: Oldest first',
            onPressed: () {
              final newOrder = _sortOrder == 'newest' ? 'oldest' : 'newest';
              _handleSortChanged(newOrder);
            },
          ),
        ],
      ),
      body: BlocConsumer<ActivityFeedBloc, ActivityFeedState>(
        listener: (context, state) {
          if (state is ActivityFeedError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ActivityFeedLoading && state is! ActivityFeedLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ActivityFeedError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading activities',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ActivityFeedBloc>().add(const LoadActivities());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<RecentActivity> activities;
          bool isLoadingMore = false;
          bool hasMore = false;

          if (state is ActivityFeedLoaded) {
            activities = state.activities;
            hasMore = state.hasMore;
            _previousActivities = activities;
          } else if (state is ActivityFeedLoading && _previousActivities.isNotEmpty) {
            activities = _previousActivities;
            isLoadingMore = true;
            hasMore = true;
          } else {
            activities = const [];
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ActivityFeedBloc>().add(
                    LoadActivities(
                      entityTypeFilter: _entityTypeFilter,
                      statusFilter: _statusFilter,
                      searchQuery: _searchQuery,
                      sortOrder: _sortOrder,
                    ),
                  );
            },
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _buildFilterSection(),
                if (activities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: Column(
                      children: const [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.black38),
                        SizedBox(height: 16),
                        Text(
                          'No activities found',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                else
                  ...activities.map((activity) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: _buildActivityCard(activity),
                      )),
                if (isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!isLoadingMore && !hasMore && activities.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'You’re all caught up!',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) => _handleSearchChanged(value.isEmpty ? null : value),
            decoration: InputDecoration(
              hintText: 'Search activities...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Type',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTogglePill(
                label: 'All Types',
                selected: _entityTypeFilter == null,
                onTap: () => _handleFilterChanged(null, _statusFilter),
              ),
              _buildTogglePill(
                label: 'Posts',
                selected: _entityTypeFilter == 'post',
                onTap: () => _handleFilterChanged('post', _statusFilter),
              ),
              _buildTogglePill(
                label: 'Users',
                selected: _entityTypeFilter == 'user',
                onTap: () => _handleFilterChanged('user', _statusFilter),
              ),
              _buildTogglePill(
                label: 'Merchants',
                selected: _entityTypeFilter == 'merchant',
                onTap: () => _handleFilterChanged('merchant', _statusFilter),
              ),
              _buildTogglePill(
                label: 'Transactions',
                selected: _entityTypeFilter == 'transaction',
                onTap: () => _handleFilterChanged('transaction', _statusFilter),
              ),
              _buildTogglePill(
                label: 'Notifications',
                selected: _entityTypeFilter == 'notification',
                onTap: () => _handleFilterChanged('notification', _statusFilter),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Status',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTogglePill(
                label: 'All Status',
                selected: _statusFilter == null,
                onTap: () => _handleFilterChanged(_entityTypeFilter, null),
              ),
              _buildTogglePill(
                label: 'Pending',
                selected: _statusFilter == 'pending',
                onTap: () => _handleFilterChanged(_entityTypeFilter, 'pending'),
              ),
              _buildTogglePill(
                label: 'Approved',
                selected: _statusFilter == 'approved',
                onTap: () => _handleFilterChanged(_entityTypeFilter, 'approved'),
              ),
              _buildTogglePill(
                label: 'Rejected',
                selected: _statusFilter == 'rejected',
                onTap: () => _handleFilterChanged(_entityTypeFilter, 'rejected'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Sort:'),
              const SizedBox(width: 8),
              _buildTogglePill(
                label: 'Newest',
                selected: _sortOrder == 'newest',
                onTap: () => _handleSortChanged('newest'),
              ),
              const SizedBox(width: 8),
              _buildTogglePill(
                label: 'Oldest',
                selected: _sortOrder == 'oldest',
                onTap: () => _handleSortChanged('oldest'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTogglePill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFD4A200), Color(0xFFC48828)],
                )
              : null,
          color: selected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(
                  color: Colors.black.withOpacity(0.15),
                  width: 0.8,
                ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(RecentActivity activity) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getActivityColor(activity.iconBgColor),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                activity.iconPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.circle, size: 16, color: Colors.black26);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        activity.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (activity.isPending && activity.entityId != null && activity.entityData != null)
              TextButton(
                onPressed: () => _handleReviewNavigation(activity),
                child: const Text('Review'),
              ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'yellow':
        return const Color(0xFFFFF4CC);
      case 'red':
        return const Color(0xFFFFE0E0);
      case 'green':
        return const Color(0xFFE6F7ED);
      default:
        return const Color(0xFFFFF4CC);
    }
  }
}

