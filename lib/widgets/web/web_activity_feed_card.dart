import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/web_design_constants.dart';
import '../../models/recent_activity.dart';
import '../../blocs/activity_feed_bloc.dart';
import '../../screens/web/web_activity_feed_screen.dart';

class WebActivityFeedCard extends StatelessWidget {
  final List<RecentActivity> activities;
  final Function(int, {String? postId, int? contentTabIndex})? onNavigateToTab;
  
  const WebActivityFeedCard({
    super.key,
    required this.activities,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450, // Fixed height to match Quick Actions card
      decoration: BoxDecoration(
        color: WebDesignConstants.webCardBackground,
        borderRadius: BorderRadius.circular(WebDesignConstants.radiusLarge),
        boxShadow: WebDesignConstants.cardShadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: WebDesignConstants.fontSizeMedium,
                  fontWeight: FontWeight.w400,
                  color: WebDesignConstants.webTextPrimary,
                  height: 1.0,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full activity feed screen
                  final bloc = context.read<ActivityFeedBloc>();
                  bloc.add(const LoadActivities());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: bloc,
                        child: WebActivityFeedScreen(
                          onNavigateToTab: onNavigateToTab,
                        ),
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
                    side: const BorderSide(
                      color: WebDesignConstants.webBorder,
                      width: 0.8,
                    ),
                  ),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: WebDesignConstants.fontSizeBody,
                    fontWeight: FontWeight.w400,
                    color: WebDesignConstants.webTextPrimary,
                    height: 1.43,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Scrollable activity list - limited to 5 items
          Expanded(
            child: activities.isEmpty
                ? const Center(
                    child: Text(
                      'No recent activities',
                      style: TextStyle(
                        fontSize: WebDesignConstants.fontSizeBody,
                        color: WebDesignConstants.webTextSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: activities.length > 5 ? 5 : activities.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildActivityItem(activities[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebDesignConstants.webBackground,
        borderRadius: BorderRadius.circular(WebDesignConstants.radiusMedium),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getActivityColor(activity.iconBgColor),
              borderRadius: BorderRadius.circular(WebDesignConstants.radiusMedium),
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
              final shouldShowButton = activity.isPending && 
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
                borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
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

  void _handleReviewNavigation(RecentActivity activity) {
    final entityType = activity.entityType?.toLowerCase();
    final entityId = activity.entityId;
    
    if (entityType == null || entityId == null) {
      onNavigateToTab?.call(1);
      return;
    }
    
    switch (entityType) {
      case 'post':
        onNavigateToTab?.call(2, postId: entityId);
        break;
      case 'user':
      case 'merchant':
        onNavigateToTab?.call(1);
        break;
      case 'transaction':
        onNavigateToTab?.call(3);
        break;
      case 'notification':
        onNavigateToTab?.call(4, contentTabIndex: 1);
        break;
      default:
        onNavigateToTab?.call(1);
        break;
    }
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
