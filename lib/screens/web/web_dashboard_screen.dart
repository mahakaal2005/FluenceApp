import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/web_design_constants.dart';
import '../../blocs/dashboard_bloc.dart' as dashboard_bloc;
import '../../blocs/notification_recipients_bloc.dart';
import '../../widgets/web/web_stat_card.dart';
import '../../widgets/web/web_metric_card.dart';
import '../../widgets/web/web_quick_actions_card.dart';
import '../../widgets/web/web_activity_feed_card.dart';
import '../../widgets/web/web_system_status_card.dart';
import '../../widgets/send_notification_dialog.dart';
import '../../utils/app_constants.dart';

enum DashboardType { users, merchants }

class WebDashboardScreen extends StatefulWidget {
  final Function(int, {String? postId, int? contentTabIndex})? onNavigateToTab;
  
  const WebDashboardScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  DashboardType _dashboardType = DashboardType.merchants;

  @override
  void initState() {
    super.initState();
    // Load data with initial dashboard type
    context.read<dashboard_bloc.DashboardBloc>().add(
      dashboard_bloc.LoadDashboardData(type: _dashboardTypeToBloc(_dashboardType))
    );
  }

  // Convert UI enum to Bloc enum
  dashboard_bloc.DashboardType _dashboardTypeToBloc(DashboardType uiType) {
    return uiType == DashboardType.users 
        ? dashboard_bloc.DashboardType.users 
        : dashboard_bloc.DashboardType.merchants;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<dashboard_bloc.DashboardBloc, dashboard_bloc.DashboardState>(
      listener: (context, state) {
        if (state is dashboard_bloc.DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is dashboard_bloc.DashboardLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is dashboard_bloc.DashboardError) {
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
                    context.read<dashboard_bloc.DashboardBloc>().add(
                      dashboard_bloc.LoadDashboardData(type: _dashboardTypeToBloc(_dashboardType))
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is dashboard_bloc.DashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<dashboard_bloc.DashboardBloc>().add(
                dashboard_bloc.RefreshDashboardData(type: _dashboardTypeToBloc(_dashboardType))
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Header with Title and Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                      _buildDashboardToggle(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats Cards Row (4 columns)
                  _buildStatsGrid(state.data),
                  const SizedBox(height: 24),
                  
                  // Metric Cards Row (2 columns)
                  _buildMetricsGrid(state.data),
                  const SizedBox(height: 24),
                  
                  // Quick Actions + Recent Activity (2 columns)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: WebQuickActionsCard(
                          onNavigateToTab: widget.onNavigateToTab ?? (int index, {String? postId, int? contentTabIndex}) {},
                          onSendNotification: () {
                            showDialog(
                              context: context,
                              builder: (context) => BlocProvider(
                                create: (context) => NotificationRecipientsBloc(),
                                child: const SendNotificationDialog(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: WebActivityFeedCard(
                          activities: state.data.recentActivities,
                          onNavigateToTab: widget.onNavigateToTab,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // System Status Card
                  const WebSystemStatusCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }

        return const Center(
          child: Text('Loading dashboard...'),
        );
      },
    );
  }

  Widget _buildDashboardToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Light gray container background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            label: 'Users Dashboard',
            icon: Icons.people_outline,
            isSelected: _dashboardType == DashboardType.users,
            onTap: () {
              if (_dashboardType != DashboardType.users) {
                setState(() {
                  _dashboardType = DashboardType.users;
                });
                // Reload data with new type
                context.read<dashboard_bloc.DashboardBloc>().add(
                  dashboard_bloc.LoadDashboardData(type: dashboard_bloc.DashboardType.users)
                );
              }
            },
          ),
          const SizedBox(width: 8),
          _buildToggleButton(
            label: 'Merchant Dashboard',
            icon: Icons.store_outlined,
            isSelected: _dashboardType == DashboardType.merchants,
            onTap: () {
              if (_dashboardType != DashboardType.merchants) {
                setState(() {
                  _dashboardType = DashboardType.merchants;
                });
                // Reload data with new type
                context.read<dashboard_bloc.DashboardBloc>().add(
                  dashboard_bloc.LoadDashboardData(type: dashboard_bloc.DashboardType.merchants)
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFD4A200), // #D4A200 - rgba(212, 162, 0, 1)
                    Color(0xFFC48828), // #C48828 - rgba(196, 136, 40, 1)
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0x26000000), // rgba(0, 0, 0, 0.15) = 0x26 in hex
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF0A0A0A),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400, // Regular weight as per Figma
                color: isSelected ? Colors.white : const Color(0xFF0A0A0A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(dashboard_bloc.DashboardData data) {
    // Dynamic labels based on dashboard type
    final entityLabel = _dashboardType == DashboardType.users ? 'Users' : 'Merchants';
    
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      childAspectRatio: WebDesignConstants.statsCardAspectRatio,
      children: [
        WebStatCard(
          title: 'Total $entityLabel',
          value: _formatNumber(data.totalUsers),
          badge: _formatGrowthBadge(data.totalUsersGrowth),
          badgeColor: _getGrowthColor(data.totalUsersGrowth),
          badgeTextColor: _getGrowthTextColor(data.totalUsersGrowth),
          iconPath: 'assets/images/stat_card_icon_1.png',
        ),
        WebStatCard(
          title: 'Pending $entityLabel',
          value: data.pendingUsers.toString(),
          badge: _formatGrowthBadge(data.pendingUsersGrowth),
          badgeColor: _getGrowthColor(data.pendingUsersGrowth),
          badgeTextColor: _getGrowthTextColor(data.pendingUsersGrowth),
          iconPath: 'assets/images/stat_card_icon_2.png',
        ),
        WebStatCard(
          title: 'Approved $entityLabel',
          value: _formatNumber(data.approvedUsers),
          badge: _formatGrowthBadge(data.approvedUsersGrowth),
          badgeColor: _getGrowthColor(data.approvedUsersGrowth),
          badgeTextColor: _getGrowthTextColor(data.approvedUsersGrowth),
          iconPath: 'assets/images/stat_card_icon_3.png',
        ),
        WebStatCard(
          title: 'Total Transactions',
          value: '${AppConstants.currencySymbol}${_formatAmount(data.totalTransactionVolume)}',
          badge: _formatGrowthBadge(data.transactionVolumeGrowth),
          badgeColor: _getGrowthColor(data.transactionVolumeGrowth),
          badgeTextColor: _getGrowthTextColor(data.transactionVolumeGrowth),
          iconPath: 'assets/images/stat_card_icon_4.png',
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(dashboard_bloc.DashboardData data) {
    // Dynamic labels based on dashboard type
    final entityLabel = _dashboardType == DashboardType.users ? 'Users' : 'Merchants';
    
    // Calculate approval rate: percentage of approved vs total users
    final approvalRate = data.totalUsers > 0 
        ? ((data.approvedUsers / data.totalUsers) * 100).clamp(0, 100)
        : 94.0;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      childAspectRatio: WebDesignConstants.metricCardAspectRatio * 2, // Adjust aspect ratio for 2 columns
      children: [
        WebMetricCard(
          title: 'Verified $entityLabel',
          value: _formatNumber(data.verifiedUsers),
          indicatorColor: WebDesignConstants.infoBlue,
        ),
        WebMetricCard(
          title: 'Approval Rate',
          value: '${approvalRate.toStringAsFixed(0)}%',
          indicatorColor: WebDesignConstants.successGreen,
        ),
      ],
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

  String _formatGrowthBadge(double growth) {
    if (growth == 0) return '0%';
    final sign = growth > 0 ? '+' : '';
    return '$sign${growth.toStringAsFixed(0)}%';
  }

  Color _getGrowthColor(double growth) {
    if (growth > 0) return WebDesignConstants.successGreenLight;
    if (growth < 0) return WebDesignConstants.errorRedLight;
    return const Color(0xFFF3F4F6);
  }

  Color _getGrowthTextColor(double growth) {
    if (growth > 0) return WebDesignConstants.successGreenDark;
    if (growth < 0) return WebDesignConstants.errorRed;
    return const Color(0xFF364153);
  }
}
