import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_colors.dart';
import '../blocs/dashboard_bloc.dart';
import '../widgets/send_notification_dialog.dart';

class DashboardTab extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
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
          badge: '+12%',
          badgeColor: AppColors.badgeGreen,
          badgeTextColor: AppColors.badgeGreenText,
          iconPath: 'assets/images/stat_card_icon_1.png',
        ),
        _buildStatCard(
          title: 'Pending Posts',
          value: data.pendingPosts.toString(),
          badge: '+${data.pendingPosts}',
          badgeColor: AppColors.badgeGreen,
          badgeTextColor: AppColors.badgeGreenText,
          iconPath: 'assets/images/stat_card_icon_2.png',
        ),
        _buildStatCard(
          title: 'Active Sessions',
          value: data.activeSessions.toString(),
          badge: '${data.activeSessions}',
          badgeColor: AppColors.badgeGray,
          badgeTextColor: AppColors.badgeGrayText,
          iconPath: 'assets/images/stat_card_icon_3.png',
        ),
        _buildStatCard(
          title: 'Transactions',
          value: '₹${_formatAmount(data.totalTransactionVolume)}',
          badge: '+8%',
          badgeColor: AppColors.badgeGreen,
          badgeTextColor: AppColors.badgeGreenText,
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
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          ...data.recentActivities.map((activity) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildActivityItem(
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
        ],
      ),
    );
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
