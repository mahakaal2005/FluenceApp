import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/web_design_constants.dart';
import '../../blocs/auth_bloc.dart';
import 'web_sidebar.dart';
import 'web_top_bar.dart';

class WebMainLayout extends StatelessWidget {
  final int currentIndex;
  final Function(int, {String? postId, int? contentTabIndex}) onNavigate;
  final Widget child;
  final String title;
  final int unreadNotificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  
  WebMainLayout({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    required this.child,
    required this.title,
    this.unreadNotificationCount = 0,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    print('🏗️ [WebMainLayout] build() called');
    print('   📊 unreadNotificationCount: $unreadNotificationCount');
    print('   🔑 Key: ValueKey("top_bar_$unreadNotificationCount")');
    print('   📍 HashCode: ${hashCode}');
    print('   📍 Identity: ${hashCode}');
    
    return Scaffold(
      backgroundColor: WebDesignConstants.webBackground,
      body: Row(
        children: [
          // Sidebar
          WebSidebar(
            currentIndex: currentIndex,
            onNavigate: onNavigate,
            onLogout: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Top bar - Force complete rebuild when count changes
                WebTopBar(
                  key: ValueKey('top_bar_$unreadNotificationCount'), // Force rebuild when count changes
                  title: title,
                  unreadNotificationCount: unreadNotificationCount,
                  onNotificationTap: onNotificationTap,
                  onProfileTap: onProfileTap,
                  onNavigateToTab: (tabIndex, itemId) {
                    // Handle navigation from search results
                    if (itemId != null && tabIndex == 2) {
                      // Posts tab - pass postId to open specific post
                      onNavigate(tabIndex, postId: itemId);
                    } else {
                      // Other tabs - just navigate
                      onNavigate(tabIndex);
                    }
                  },
                ),
                
                // Content
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
