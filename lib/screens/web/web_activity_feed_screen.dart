import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/activity_feed_bloc.dart';
import '../../constants/web_design_constants.dart';
import '../../models/recent_activity.dart';
import '../../widgets/web/web_activity_filter_bar.dart';

class WebActivityFeedScreen extends StatefulWidget {
  final Function(int, {String? postId, int? contentTabIndex})? onNavigateToTab;

  const WebActivityFeedScreen({super.key, this.onNavigateToTab});

  @override
  State<WebActivityFeedScreen> createState() => _WebActivityFeedScreenState();
}

class _WebActivityFeedScreenState extends State<WebActivityFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _entityTypeFilter;
  String? _statusFilter;
  String? _searchQuery;
  String _sortOrder = 'newest';
  List<RecentActivity> _previousActivities = [];

  @override
  void initState() {
    super.initState();
    // Load initial activities
    context.read<ActivityFeedBloc>().add(const LoadActivities());

    // Set up infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when 90% scrolled
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
      FilterActivities(entityTypeFilter: entityType, statusFilter: status),
    );
  }

  void _handleSearchChanged(String? query) {
    setState(() {
      _searchQuery = query;
    });
    context.read<ActivityFeedBloc>().add(SearchActivities(query));
  }

  void _handleSortChanged(String order) {
    setState(() {
      _sortOrder = order;
    });
    context.read<ActivityFeedBloc>().add(SortActivities(order));
  }

  void _handleReviewNavigation(RecentActivity activity) {
    final entityType = activity.entityType?.toLowerCase();
    final entityId = activity.entityId;

    if (entityType == null || entityId == null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      widget.onNavigateToTab?.call(1);
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
      backgroundColor: WebDesignConstants.webBackground,
      body: BlocConsumer<ActivityFeedBloc, ActivityFeedState>(
        listener: (context, state) {
          if (state is ActivityFeedError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: WebDesignConstants.errorRed,
              ),
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
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: WebDesignConstants.errorRed,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading activities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: WebDesignConstants.webTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: WebDesignConstants.webTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ActivityFeedBloc>().add(
                        const LoadActivities(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Track activities and loading state
          List<RecentActivity> activities;
          bool isLoadingMore = false;
          bool hasMore = false;

          if (state is ActivityFeedLoaded) {
            activities = state.activities;
            hasMore = state.hasMore;
            _previousActivities = activities; // Store for loading more state
          } else if (state is ActivityFeedLoading &&
              _previousActivities.isNotEmpty) {
            // Loading more - show previous activities
            activities = _previousActivities;
            isLoadingMore = true;
            hasMore = true; // Assume more until we know otherwise
          } else {
            activities = <RecentActivity>[];
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
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Activities',
                        style: TextStyle(
                          fontSize: WebDesignConstants.fontSizeH2,
                          fontWeight: FontWeight.w400,
                          color: WebDesignConstants.webTextPrimary,
                          height: 1.0,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Navigate back
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        color: WebDesignConstants.webTextSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Filter Bar
                  WebActivityFilterBar(
                    entityTypeFilter: _entityTypeFilter,
                    statusFilter: _statusFilter,
                    searchQuery: _searchQuery,
                    sortOrder: _sortOrder,
                    onFilterChanged: _handleFilterChanged,
                    onSearchChanged: _handleSearchChanged,
                    onSortChanged: _handleSortChanged,
                  ),
                  const SizedBox(height: 24),

                  // Activities List
                  if (activities.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: WebDesignConstants.webTextSecondary
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No activities found',
                              style: TextStyle(
                                fontSize: WebDesignConstants.fontSizeMedium,
                                color: WebDesignConstants.webTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...activities.map(
                      (activity) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildActivityItem(activity),
                      ),
                    ),

                  // Loading more indicator
                  if (isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // End of list indicator
                  if (!isLoadingMore && !hasMore && activities.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No more activities',
                          style: TextStyle(
                            fontSize: WebDesignConstants.fontSizeBody,
                            color: WebDesignConstants.webTextSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebDesignConstants.webCardBackground,
        borderRadius: BorderRadius.circular(WebDesignConstants.radiusMedium),
        boxShadow: WebDesignConstants.cardShadow,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getActivityColor(activity.iconBgColor),
              borderRadius: BorderRadius.circular(
                WebDesignConstants.radiusMedium,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              activity.iconPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.circle,
                  size: 20,
                  color: WebDesignConstants.webTextSecondary,
                );
              },
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: WebDesignConstants.fontSizeMedium,
                    fontWeight: FontWeight.w400,
                    color: WebDesignConstants.webTextPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: const TextStyle(
                    fontSize: WebDesignConstants.fontSizeBody,
                    fontWeight: FontWeight.w400,
                    color: WebDesignConstants.webTextSecondary,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: WebDesignConstants.webTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.time,
                      style: const TextStyle(
                        fontSize: WebDesignConstants.fontSizeSmall,
                        fontWeight: FontWeight.w400,
                        color: WebDesignConstants.webTextSecondary,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Review button
          Builder(
            builder: (context) {
              final shouldShowButton =
                  activity.isPending &&
                  activity.entityId != null &&
                  activity.entityData != null;

              if (!shouldShowButton) return const SizedBox.shrink();

              return TextButton(
                onPressed: () {
                  _handleReviewNavigation(activity);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      WebDesignConstants.radiusSmall,
                    ),
                    side: const BorderSide(
                      color: WebDesignConstants.webBorder,
                      width: 0.8,
                    ),
                  ),
                ),
                child: const Text(
                  'Review',
                  style: TextStyle(
                    fontSize: WebDesignConstants.fontSizeBody,
                    fontWeight: FontWeight.w400,
                    color: WebDesignConstants.webTextPrimary,
                    height: 1.43,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'yellow':
        return WebDesignConstants.badgeYellow;
      case 'red':
        return WebDesignConstants.errorRedLight;
      case 'green':
        return WebDesignConstants.successGreenLight;
      default:
        return WebDesignConstants.badgeYellow;
    }
  }
}
