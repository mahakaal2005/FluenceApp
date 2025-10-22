import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards Grid
            _buildStatsGrid(),
            const SizedBox(height: 24),
            
            // Quick Actions Card
            _buildQuickActionsCard(),
            const SizedBox(height: 24),
            
            // Recent Activity Card
            _buildRecentActivityCard(),
            const SizedBox(height: 100), // Extra padding to prevent bottom overflow
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
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
          value: '12,458',
          badge: '+12%',
          badgeColor: AppColors.badgeGreen,
          badgeTextColor: AppColors.badgeGreenText,
          iconPath: 'assets/images/stat_card_icon_1.png',
        ),
        _buildStatCard(
          title: 'Pending Posts',
          value: '47',
          badge: '+5',
          badgeColor: AppColors.badgeGreen,
          badgeTextColor: AppColors.badgeGreenText,
          iconPath: 'assets/images/stat_card_icon_2.png',
        ),
        _buildStatCard(
          title: 'Active Sessions',
          value: '8',
          badge: '2',
          badgeColor: AppColors.badgeGray,
          badgeTextColor: AppColors.badgeGrayText,
          iconPath: 'assets/images/stat_card_icon_3.png',
        ),
        _buildStatCard(
          title: 'Transactions',
          value: '₹45.2K',
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
                onTap: () {},
              ),
              _buildQuickActionButton(
                label: 'Approve Users',
                iconPath: 'assets/images/quick_action_approve.png',
                onTap: () {},
              ),
              _buildQuickActionButton(
                label: 'Review Posts',
                iconPath: 'assets/images/quick_action_review.png',
                onTap: () {},
              ),
              _buildQuickActionButton(
                label: 'Send Notice',
                iconPath: 'assets/images/quick_action_notice.png',
                onTap: () {},
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

  Widget _buildRecentActivityCard() {
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
          _buildActivityItem(
            iconPath: 'assets/images/activity_icon_1.png',
            iconBgColor: AppColors.activityYellow,
            title: 'New user registration',
            subtitle: 'Priya Sharma',
            time: '2 min ago',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            iconPath: 'assets/images/activity_icon_2.png',
            iconBgColor: AppColors.activityYellow,
            title: 'Post submitted for review',
            subtitle: 'Merchant: Coffee House',
            time: '15 min ago',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            iconPath: 'assets/images/activity_icon_3.png',
            iconBgColor: AppColors.activityRed,
            title: 'Payment dispute raised',
            subtitle: 'Transaction #4529',
            time: '1 hour ago',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            iconPath: 'assets/images/activity_icon_4.png',
            iconBgColor: AppColors.activityGreen,
            title: 'Merchant approved',
            subtitle: 'Green Grocers Ltd',
            time: '2 hours ago',
          ),
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
}
