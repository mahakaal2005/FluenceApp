import 'package:flutter/material.dart';
import '../../constants/web_design_constants.dart';

class WebSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigate;
  final VoidCallback onLogout;
  
  const WebSidebar({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: WebDesignConstants.sidebarWidth,
      decoration: BoxDecoration(
        color: WebDesignConstants.webCardBackground,
        border: Border(
          right: BorderSide(
            color: WebDesignConstants.webBorder,
            width: 0.8,
          ),
        ),
        boxShadow: WebDesignConstants.sidebarShadow,
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            height: WebDesignConstants.topBarHeight,
            decoration: const BoxDecoration(
              gradient: WebDesignConstants.sidebarGradient,
              border: Border(
                bottom: BorderSide(
                  color: WebDesignConstants.webBorder,
                  width: 0,
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: 24),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: WebDesignConstants.fontSizeH3,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          
          // Navigation items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
              child: Column(
                children: [
                  _buildNavItem(
                    index: 0,
                    label: 'Dashboard',
                    iconPath: 'assets/images/dashboard_icon.png',
                    icon: Icons.dashboard,
                  ),
                  const SizedBox(height: 4),
                  _buildNavItem(
                    index: 1,
                    label: 'Users',
                    iconPath: 'assets/images/users_icon.png',
                    icon: Icons.people,
                  ),
                  const SizedBox(height: 4),
                  _buildNavItem(
                    index: 2,
                    label: 'Posts',
                    iconPath: 'assets/images/posts_icon.png',
                    icon: Icons.article,
                  ),
                  const SizedBox(height: 4),
                  _buildNavItem(
                    index: 3,
                    label: 'Payments',
                    iconPath: 'assets/images/payments_icon.png',
                    icon: Icons.payment,
                  ),
                  const SizedBox(height: 4),
                  _buildNavItem(
                    index: 4,
                    label: 'Content',
                    iconPath: 'assets/images/content_icon.png',
                    icon: Icons.content_paste,
                  ),
                ],
              ),
            ),
          ),
          
          // Logout button at bottom
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: WebDesignConstants.webBorder,
                  width: 0.8,
                ),
              ),
            ),
            child: _buildLogoutButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required String iconPath,
    required IconData icon,
  }) {
    final isSelected = currentIndex == index;
    
    return InkWell(
      onTap: () => onNavigate(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: isSelected ? WebDesignConstants.primaryGradient : null,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : WebDesignConstants.webTextSecondary,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      icon,
                      size: 20,
                      color: isSelected ? Colors.white : WebDesignConstants.webTextSecondary,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: WebDesignConstants.fontSizeMedium,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.white : WebDesignConstants.webTextSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: onLogout,
      borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: WebDesignConstants.webBorder,
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout,
              size: 16,
              color: WebDesignConstants.webTextPrimary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Logout',
              style: TextStyle(
                fontSize: WebDesignConstants.fontSizeBody,
                fontWeight: FontWeight.w400,
                color: WebDesignConstants.webTextPrimary,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
