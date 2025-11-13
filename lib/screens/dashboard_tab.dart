import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../blocs/dashboard_bloc.dart';
import '../blocs/activity_feed_bloc.dart';
import '../models/recent_activity.dart';
import '../widgets/send_notification_dialog.dart';
import 'activity_feed_screen.dart';

class DashboardTab extends StatefulWidget {
  final Function(int, {String? postId, int? contentTabIndex})? onNavigateToTab;
  
  const DashboardTab({super.key, this.onNavigateToTab});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when the tab is initialized
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(LoadDashboardData());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(RefreshDashboardData());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards Grid
                    _buildStatsGrid(state.data),
                    const SizedBox(height: 24),
                    
                    // Quick Actions Card
                    _buildQuickActionsCard(),
                    const SizedBox(height: 24),
                    
                    // Recent Activity Card
                    _buildRecentActivityCard(state.data),
                    const SizedBox(height: 100), // Extra padding to prevent bottom overflow
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: Text('Loading dashboard...'),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(DashboardData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.05, // Adjusted for better fit
      children: [
        _buildStatCard(
          title: 'Total Users',
          value: _formatNumber(data.totalUsers),
          badge: _formatGrowthBadge(data.totalUsersGrowth),
          badgeColor: _getGrowthColor(data.totalUsersGrowth),
          badgeTextColor: _getGrowthTextColor(data.totalUsersGrowth),
          iconPath: 'assets/images/stat_card_icon_1.png',
        ),
        _buildStatCard(
          title: 'Pending Posts',
          value: data.pendingPosts.toString(),
          badge: _formatGrowthBadge(data.pendingPostsGrowth),
          badgeColor: _getGrowthColor(data.pendingPostsGrowth),
          badgeTextColor: _getGrowthTextColor(data.pendingPostsGrowth),
          iconPath: 'assets/images/stat_card_icon_2.png',
        ),
        _buildStatCard(
          title: 'Active Sessions',
          value: data.activeSessions.toString(),
          badge: _formatGrowthBadge(data.activeSessionsGrowth),
          badgeColor: _getGrowthColor(data.activeSessionsGrowth),
          badgeTextColor: _getGrowthTextColor(data.activeSessionsGrowth),
          iconPath: 'assets/images/stat_card_icon_3.png',
        ),
        _buildStatCard(
          title: 'Transactions',
          value: '${AppConstants.currencySymbol} ${_formatAmount(data.totalTransactionVolume)}',
          badge: _formatGrowthBadge(data.transactionVolumeGrowth),
          badgeColor: _getGrowthColor(data.transactionVolumeGrowth),
          badgeTextColor: _getGrowthTextColor(data.transactionVolumeGrowth),
          iconPath: 'assets/images/stat_card_icon_4.png',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String badge,
    required Color badgeColor,
    required Color badgeTextColor,
    required String iconPath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: badgeTextColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(5),
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, color: Colors.white, size: 40);
                  },
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        left: 24,
        top: 24,
        right: 24,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 42), // Figma gap: 41.97px
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.676, // 140.7 / 83.95 ≈ 1.676
            children: [
              _buildQuickActionButton(
                label: 'Sessions',
                iconPath: 'assets/images/quick_action_sessions.png',
                onTap: () {
                  // Navigate to Users tab to see active sessions
                  widget.onNavigateToTab?.call(1);
                },
              ),
              _buildQuickActionButton(
                label: 'Approve Users',
                iconPath: 'assets/images/quick_action_approve.png',
                onTap: () {
                  // Navigate to Users tab
                  widget.onNavigateToTab?.call(1);
                },
              ),
              _buildQuickActionButton(
                label: 'Review Posts',
                iconPath: 'assets/images/quick_action_review.png',
                onTap: () {
                  // Navigate to Posts tab
                  widget.onNavigateToTab?.call(2);
                },
              ),
              _buildQuickActionButton(
                label: 'Send Notice',
                iconPath: 'assets/images/quick_action_notice.png',
                onTap: () {
                  // Open send notification dialog
                  showDialog(
                    context: context,
                    builder: (context) => const SendNotificationDialog(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 24, // Figma: 23.99px
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image, color: Colors.white, size: 24);
              },
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
                height: 1.43,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(DashboardData data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  final bloc = context.read<ActivityFeedBloc>();
                  bloc.add(const LoadActivities());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: bloc,
                        child: ActivityFeedScreen(
                          onNavigateToTab: widget.onNavigateToTab,
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...data.recentActivities.map((activity) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActivityItem(
                  activity: activity,
                  iconPath: activity.iconPath,
                  iconBgColor: _getActivityColor(activity.iconBgColor),
                  title: activity.title,
                  subtitle: activity.subtitle,
                  time: activity.time,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required RecentActivity activity,
    required String iconPath,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              iconPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.circle, size: 16);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.43,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.33,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
          // Show Review button only for pending items
          Builder(
            builder: (context) {
              final shouldShowButton = activity.isPending && 
                                      activity.entityId != null && 
                                      activity.entityData != null;
              
              // Debug logging
              if (activity.status != null) {
                print('🔘 [ACTIVITY_ITEM] ${activity.title}');
                print('   Status: ${activity.status} | isPending: ${activity.isPending}');
                print('   entityId: ${activity.entityId}');
                print('   hasEntityData: ${activity.entityData != null}');
                print('   → Show Review Button: $shouldShowButton');
              }
              
              if (!shouldShowButton) return const SizedBox.shrink();
              
              return TextButton(
                onPressed: () {
                  print('🎯 [REVIEW_BUTTON] Button clicked!');
                  _handleReviewNavigation(activity);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Review',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleReviewNavigation(RecentActivity activity) {
    print('🔍 [REVIEW_NAVIGATION] Handling review navigation...');
    print('   Entity ID: ${activity.entityId}');
    print('   Entity Type: ${activity.entityType}');
    print('   Status: ${activity.status}');
    
    final entityType = activity.entityType?.toLowerCase();
    final entityId = activity.entityId;
    
    if (entityType == null || entityId == null) {
      print('   ⚠️  Missing entityType or entityId, defaulting to Users tab');
      widget.onNavigateToTab?.call(1);
      return;
    }
    
    switch (entityType) {
      case 'post':
        // Navigate to Posts tab and open post detail dialog
        print('   → Navigating to Posts tab with postId: $entityId');
        widget.onNavigateToTab?.call(2, postId: entityId);
        break;
        
      case 'user':
      case 'merchant':
        // Navigate to Users tab
        print('   → Navigating to Users tab');
        widget.onNavigateToTab?.call(1);
        break;
        
      case 'transaction':
        // Navigate to Payments tab
        print('   → Navigating to Payments tab');
        widget.onNavigateToTab?.call(3);
        break;
        
      case 'notification':
        // Navigate to Content tab → Notifications sub-tab (index 1)
        print('   → Navigating to Content tab → Notifications sub-tab');
        widget.onNavigateToTab?.call(4, contentTabIndex: 1);
        break;
        
      default:
        // Default to Users tab for unknown entity types
        print('   ⚠️  Unknown entityType: $entityType, defaulting to Users tab');
        widget.onNavigateToTab?.call(1);
        break;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  /// Format growth percentage for badge display
  String _formatGrowthBadge(double growth) {
    if (growth == 0) return '0%';
    final sign = growth > 0 ? '+' : '';
    return '$sign${growth.toStringAsFixed(1)}%';
  }

  /// Get badge background color based on growth value
  Color _getGrowthColor(double growth) {
    if (growth > 0) return AppColors.badgeGreen;
    if (growth < 0) return AppColors.badgeRed;
    return AppColors.badgeGray;
  }

  /// Get badge text color based on growth value
  Color _getGrowthTextColor(double growth) {
    if (growth > 0) return AppColors.badgeGreenText;
    if (growth < 0) return AppColors.badgeRedText;
    return AppColors.badgeGrayText;
  }

  Color _getActivityColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'yellow':
        return AppColors.activityYellow;
      case 'red':
        return AppColors.activityRed;
      case 'green':
        return AppColors.activityGreen;
      default:
        return AppColors.activityYellow;
    }
  }
}
