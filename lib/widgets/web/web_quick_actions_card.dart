import 'package:flutter/material.dart';
import '../../constants/web_design_constants.dart';

class WebQuickActionsCard extends StatelessWidget {
  final Function(int, {String? postId, int? contentTabIndex})? onNavigateToTab;
  final VoidCallback? onSendNotification;
  
  const WebQuickActionsCard({
    super.key,
    this.onNavigateToTab,
    this.onSendNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450, // Fixed height to show all action buttons properly
      decoration: BoxDecoration(
        color: WebDesignConstants.webCardBackground,
        borderRadius: BorderRadius.circular(WebDesignConstants.radiusLarge),
        boxShadow: WebDesignConstants.cardShadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: WebDesignConstants.fontSizeMedium,
              fontWeight: FontWeight.w400,
              color: WebDesignConstants.webTextPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            children: [
              _buildActionButton(
                label: 'Sessions',
                iconPath: 'assets/images/quick_action_sessions.png',
                icon: Icons.people,
                onTap: () => onNavigateToTab?.call(1),
              ),
              _buildActionButton(
                label: 'Approve Users',
                iconPath: 'assets/images/quick_action_approve.png',
                icon: Icons.person_add,
                onTap: () => onNavigateToTab?.call(1),
              ),
              _buildActionButton(
                label: 'Review Posts',
                iconPath: 'assets/images/quick_action_review.png',
                icon: Icons.article,
                onTap: () => onNavigateToTab?.call(2),
              ),
              _buildActionButton(
                label: 'Send Notice',
                iconPath: 'assets/images/quick_action_notice.png',
                icon: Icons.notifications,
                onTap: onSendNotification,
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required String iconPath,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
      child: Container(
        decoration: BoxDecoration(
          gradient: WebDesignConstants.primaryGradient,
          borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
          boxShadow: WebDesignConstants.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: WebDesignConstants.fontSizeBody,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.43,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
