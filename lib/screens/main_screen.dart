import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_tab.dart';
import 'users_tab.dart';
import 'posts_tab.dart';
import 'content_tab.dart';
import 'payments_tab.dart';
import 'profile_screen.dart';
import 'web/web_dashboard_screen.dart';
import 'web/web_content_screen.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/content_bloc.dart';
import '../blocs/notification_recipients_bloc.dart';
import '../repositories/notifications_repository.dart';
import '../widgets/web/web_main_layout.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _unreadNotificationCount = 0;
  int _contentTabIndex = 0; // Track which sub-tab to show in ContentTab
  String? _postIdToOpen; // Track post ID to open after navigation
  final NotificationsRepository _notificationsRepository = NotificationsRepository();

  void _navigateToTab(int index, {String? postId, int? contentTabIndex}) {
    setState(() {
      _currentIndex = index;
      if (postId != null) {
        _postIdToOpen = postId;
      }
      if (contentTabIndex != null) {
        _contentTabIndex = contentTabIndex;
      }
    });
  }

  List<Widget> get _tabs => [
    DashboardTab(
      onNavigateToTab: _navigateToTab,
    ),
    const UsersTab(),
    PostsTab(postIdToOpen: _postIdToOpen),
    const PaymentsTab(),
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ContentBloc(
            onNotificationsViewed: _loadUnreadCount,
          )..add(const RefreshAll()),
        ),
        BlocProvider(
          create: (context) => NotificationRecipientsBloc(),
        ),
      ],
      child: ContentTab(initialTabIndex: _contentTabIndex),
    ),
  ];
  
  List<Widget> get _webTabs => [
    WebDashboardScreen(
      onNavigateToTab: _navigateToTab,
    ),
    const UsersTab(),
    PostsTab(postIdToOpen: _postIdToOpen),
    const PaymentsTab(),
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ContentBloc()..add(const RefreshAll()),
        ),
        BlocProvider(
          create: (context) => NotificationRecipientsBloc(),
        ),
      ],
      child: WebContentScreen(
        initialTabIndex: _contentTabIndex,
        onNotificationsViewed: _loadUnreadCount,
      ),
    ),
  ];
  
  List<String> get _tabTitles => [
    'Dashboard',
    'User & Merchant Management',
    'Posts',
    'Payments',
    'Content & Communications',
  ];

  @override
  void initState() {
    super.initState();
    // Validate authentication on main screen load
    context.read<AuthBloc>().add(AuthTokenValidated());
    _loadUnreadCount();
  }

  // Load unseen admin notification count (only notifications RECEIVED by admin, not sent by admin)
  Future<void> _loadUnreadCount() async {
    try {
      print('🔄 [MainScreen] Loading unread count...');
      final count = await _notificationsRepository.getUnreadCount();
      print('📊 [MainScreen] Got count: $count');
      if (mounted) {
        setState(() {
          _unreadNotificationCount = count;
          print('✅ [MainScreen] Updated badge count to: $count');
        });
      }
    } catch (e) {
      print('❌ Failed to load unseen notification count: $e');
    }
  }

  @override
  void dispose() {
    _notificationsRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we should show web layout
    if (ResponsiveHelper.shouldShowWebLayout(context)) {
      return WebMainLayout(
        currentIndex: _currentIndex,
        onNavigate: _navigateToTab,
        title: _tabTitles[_currentIndex],
        unreadNotificationCount: _unreadNotificationCount,
        onNotificationTap: () {
          setState(() {
            _contentTabIndex = 1; // Notifications tab
            _currentIndex = 4; // Content tab
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            _loadUnreadCount();
          });
        },
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        },
        child: _webTabs[_currentIndex],
      );
    }
    
    // Mobile layout (existing)
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(child: _tabs[_currentIndex]),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
                height: 1.5,
              ),
            ),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Image.asset(
                          'assets/images/notification_icon.png',
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 16,
                            );
                          },
                        ),
                        onPressed: () {
                          // Navigate to Content tab (index 4) and switch to Notifications section (index 1)
                          setState(() {
                            _contentTabIndex = 1; // Notifications tab
                            _currentIndex = 4; // Content tab
                          });
                          // Reload unread count after navigation
                          Future.delayed(const Duration(milliseconds: 500), () {
                            _loadUnreadCount();
                          });
                        },
                      ),
                    ),
                    if (_unreadNotificationCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.badgeRed,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              _unreadNotificationCount > 99 ? '99+' : _unreadNotificationCount.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.white,
                                height: 1.33,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(36956300),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.white,
                        width: 1.1,
                      ),
                      borderRadius: BorderRadius.circular(36956300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36956300),
                      child: Image.asset(
                        'assets/images/profile_avatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.1),
            width: 1.1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 1.1),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Dashboard',
                iconPath: 'assets/images/dashboard_icon.png',
              ),
              _buildNavItem(
                index: 1,
                label: 'Users',
                iconPath: 'assets/images/users_icon.png',
              ),
              _buildNavItem(
                index: 2,
                label: 'Posts',
                iconPath: 'assets/images/posts_icon.png',
              ),
              _buildNavItem(
                index: 3,
                label: 'Payments',
                iconPath: 'assets/images/payments_icon.png',
              ),
              _buildNavItem(
                index: 4,
                label: 'Content',
                iconPath: 'assets/images/content_icon.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required String iconPath,
  }) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.buttonGradient : null,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.white : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.circle,
                      size: 24,
                      color: isSelected ? AppColors.white : AppColors.textSecondary,
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
