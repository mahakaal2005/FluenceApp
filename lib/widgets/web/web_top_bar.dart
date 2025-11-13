import 'package:flutter/material.dart';
import '../../constants/web_design_constants.dart';

class WebTopBar extends StatelessWidget {
  final String title;
  final int unreadNotificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  
  const WebTopBar({
    super.key,
    required this.title,
    this.unreadNotificationCount = 0,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: WebDesignConstants.topBarHeight,
      decoration: BoxDecoration(
        color: WebDesignConstants.webCardBackground,
        border: Border(
          bottom: BorderSide(
            color: WebDesignConstants.webBorder,
            width: 0.8,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13.6),
      child: Row(
        children: [
          // Left side - Fluence Pay branding and Search
          Expanded(
            child: Row(
              children: [
                // Show Fluence Pay branding only on Dashboard, otherwise show page title
                if (title == 'Dashboard') ...[
                  // Fluence Pay Logo and Title
                  Image.asset(
                    'assets/images/fluence_pay_logo.png',
                    width: 23.45,
                    height: 23.45,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 23.45,
                        height: 23.45,
                        decoration: const BoxDecoration(
                          gradient: WebDesignConstants.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Fluence Pay',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD4A200),
                      height: 1.22,
                      letterSpacing: -0.26,
                      fontFamilyFallback: ['Roboto', 'Arial'],
                    ),
                  ),
                ] else ...[
                  // Page Title for other pages
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0A0A0A),
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(width: 24),
                
                // Search bar
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    height: 36,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: const TextStyle(
                          fontSize: WebDesignConstants.fontSizeBody,
                          fontWeight: FontWeight.w400,
                          color: WebDesignConstants.webTextSecondary,
                          height: 1.5,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 16,
                          color: WebDesignConstants.webTextSecondary,
                        ),
                        filled: true,
                        fillColor: WebDesignConstants.webBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 0.8,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 0.8,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
                          borderSide: const BorderSide(
                            color: WebDesignConstants.gradientStart,
                            width: 0.8,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Right side - Notification bell, then user info
          Row(
            children: [
              // Notification button - FIRST
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Image.asset(
                          'assets/images/notification_bell_icon.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.notifications_outlined,
                              color: WebDesignConstants.webTextPrimary,
                              size: 40,
                            );
                          },
                        ),
                        onPressed: onNotificationTap,
                      ),
                    ),
                    // Badge - always show for testing, remove condition later
                    if (unreadNotificationCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          height: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: WebDesignConstants.notificationRed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              unreadNotificationCount > 9 ? '9+' : unreadNotificationCount.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // User info - SECOND
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Admin User',
                            style: TextStyle(
                              fontSize: WebDesignConstants.fontSizeBody,
                              fontWeight: FontWeight.w400,
                              color: WebDesignConstants.webTextPrimary,
                              height: 1.43,
                            ),
                          ),
                          Text(
                            'admin@panel.com',
                            style: TextStyle(
                              fontSize: WebDesignConstants.fontSizeSmall,
                              fontWeight: FontWeight.w400,
                              color: WebDesignConstants.webTextSecondary,
                              height: 1.33,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Profile icon - THIRD (circular with golden gradient and white icon)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1.6,
                          ),
                        ),
                        padding: const EdgeInsets.all(1.6),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: WebDesignConstants.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/profile_icon_white.png',
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: WebDesignConstants.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
