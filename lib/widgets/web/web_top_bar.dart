import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/web_design_constants.dart';
import '../../models/global_search_result.dart';
import '../../blocs/users_bloc.dart';
import '../../blocs/posts_bloc.dart';
import '../../blocs/transactions_bloc.dart';
import '../../utils/app_constants.dart';

class WebTopBar extends StatefulWidget {
  final String title;
  final int unreadNotificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final Function(int, String?)? onNavigateToTab; // tabIndex, itemId
  
  WebTopBar({
    super.key,
    required this.title,
    this.unreadNotificationCount = 0,
    required this.onNotificationTap,
    required this.onProfileTap,
    this.onNavigateToTab,
  });

  @override
  State<WebTopBar> createState() => _WebTopBarState();
}

class _WebTopBarState extends State<WebTopBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<GlobalSearchResult> _searchResults = [];
  bool _showSearchResults = false;
  int _lastBadgeCount = -1; // Track last badge count to detect changes
  
  @override
  void initState() {
    _lastBadgeCount = widget.unreadNotificationCount; // Initialize with current count
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    print('🔔 [WebTopBar] ========== initState ==========');
    print('   📊 widget.unreadNotificationCount: ${widget.unreadNotificationCount}');
    print('   🔑 widget.key: ${widget.key}');
    print('   📍 State hashCode: ${hashCode}');
    print('   📍 State identity: ${hashCode}');
    print('   📍 Widget hashCode: ${widget.hashCode}');
    print('🔔 [WebTopBar] ===============================');
  }
  
  @override
  void didUpdateWidget(WebTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('🔔 [WebTopBar] ========== didUpdateWidget ==========');
    print('   📊 OLD widget.unreadNotificationCount: ${oldWidget.unreadNotificationCount}');
    print('   📊 NEW widget.unreadNotificationCount: ${widget.unreadNotificationCount}');
    print('   📊 State _lastBadgeCount: $_lastBadgeCount');
    print('   🔑 OLD widget.key: ${oldWidget.key}');
    print('   🔑 NEW widget.key: ${widget.key}');
    print('   📍 State hashCode: ${hashCode}');
    print('   📍 State identity: ${hashCode}');
    print('   ⚖️ Values equal? ${oldWidget.unreadNotificationCount == widget.unreadNotificationCount}');
    
    // CRITICAL FIX: Update _lastBadgeCount when count changes
    // This ensures we detect the change and force widget recreation
    final countChanged = oldWidget.unreadNotificationCount != widget.unreadNotificationCount;
    if (countChanged) {
      print('   🔄 COUNT CHANGED: $_lastBadgeCount → ${widget.unreadNotificationCount}');
      _lastBadgeCount = widget.unreadNotificationCount;
    }
    
    // CRITICAL FIX: ALWAYS force rebuild to ensure widget tree is recreated
    // This is especially important when count goes from >0 to 0 to remove old badge
    print('   ✅ FORCING rebuild to ensure old badge is removed');
    setState(() {
      print('   ✅ setState() called - rebuild triggered');
    });
    print('🔔 [WebTopBar] ======================================');
  }
  
  @override
  void setState(VoidCallback fn) {
    print('🔔 [WebTopBar] setState() called');
    print('   📊 Current widget.unreadNotificationCount: ${widget.unreadNotificationCount}');
    super.setState(fn);
    print('🔔 [WebTopBar] setState() completed');
  }
  
  @override
  void dispose() {
    print('🔔 [WebTopBar] ========== dispose() called ==========');
    print('   📊 widget.unreadNotificationCount: ${widget.unreadNotificationCount}');
    print('   🔑 widget.key: ${widget.key}');
    print('   📍 State hashCode: ${hashCode}');
    print('🔔 [WebTopBar] =====================================');
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }
    
    setState(() {
      _searchResults = _performGlobalSearch(query);
      _showSearchResults = _searchResults.isNotEmpty;
    });
  }
  
  void _onFocusChanged() {
    if (!_searchFocusNode.hasFocus && _searchController.text.trim().isEmpty) {
      setState(() {
        _showSearchResults = false;
      });
    }
  }
  
  List<GlobalSearchResult> _performGlobalSearch(String query) {
    final lowerQuery = query.toLowerCase();
    final results = <GlobalSearchResult>[];
    
    if (!mounted) return results;
    
    // Search Users
    try {
      final usersState = context.read<UsersBloc>().state;
      if (usersState is UsersLoaded) {
        final matchingUsers = usersState.allUsers.where((user) {
          return user.name.toLowerCase().contains(lowerQuery) ||
                 user.email.toLowerCase().contains(lowerQuery) ||
                 user.phone.toLowerCase().contains(lowerQuery) ||
                 (user.company?.toLowerCase().contains(lowerQuery) ?? false) ||
                 (user.businessType?.toLowerCase().contains(lowerQuery) ?? false) ||
                 (user.location?.toLowerCase().contains(lowerQuery) ?? false);
        }).take(5).toList();
        
        for (var user in matchingUsers) {
          results.add(GlobalSearchResult(
            type: 'user',
            id: user.id,
            title: user.name,
            subtitle: user.email,
            icon: Icons.person,
            tabIndex: 1, // Users tab
          ));
        }
      }
    } catch (e) {
      // BLoC not available, skip
    }
    
    // Search Posts
    try {
      final postsState = context.read<PostsBloc>().state;
      if (postsState is PostsLoaded) {
        final matchingPosts = postsState.posts.where((post) {
          return post.username.toLowerCase().contains(lowerQuery) ||
                 post.businessName.toLowerCase().contains(lowerQuery) ||
                 post.description.toLowerCase().contains(lowerQuery);
        }).take(5).toList();
        
        for (var post in matchingPosts) {
          results.add(GlobalSearchResult(
            type: 'post',
            id: post.id,
            title: post.username,
            subtitle: post.description.length > 50 
                ? '${post.description.substring(0, 50)}...' 
                : post.description,
            icon: Icons.post_add,
            tabIndex: 2, // Posts tab
          ));
        }
      }
    } catch (e) {
      // BLoC not available, skip
    }
    
    // Search Transactions
    try {
      final transactionsState = context.read<TransactionsBloc>().state;
      if (transactionsState is TransactionsLoaded) {
        final matchingTransactions = transactionsState.transactions.where((transaction) {
          return transaction.id.toLowerCase().contains(lowerQuery) ||
                 transaction.businessName.toLowerCase().contains(lowerQuery) ||
                 transaction.customerName.toLowerCase().contains(lowerQuery) ||
                 transaction.description.toLowerCase().contains(lowerQuery) ||
                 transaction.amount.toString().contains(lowerQuery);
        }).take(5).toList();
        
        for (var transaction in matchingTransactions) {
          results.add(GlobalSearchResult(
            type: 'transaction',
            id: transaction.id,
            title: transaction.businessName,
            subtitle: '${AppConstants.currencySymbol} ${transaction.amount.toStringAsFixed(2)} - ${transaction.description}',
            icon: Icons.payment,
            tabIndex: 3, // Payments tab
          ));
        }
      }
    } catch (e) {
      // BLoC not available, skip
    }
    
    return results;
  }
  
  void _handleResultTap(GlobalSearchResult result) {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchResults = false;
    });
    
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab!(result.tabIndex, result.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔔 [WebTopBar] ========== build() called ==========');
    print('   📊 widget.unreadNotificationCount: ${widget.unreadNotificationCount}');
    print('   🔑 widget.key: ${widget.key}');
    print('   📍 State hashCode: ${hashCode}');
    print('   📍 State identity: ${hashCode}');
    print('   📍 Context hashCode: ${context.hashCode}');
    
    // Post-frame callback to verify what's actually rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔔 [WebTopBar] ========== Post-Frame Callback ==========');
      print('   📊 widget.unreadNotificationCount AFTER frame: ${widget.unreadNotificationCount}');
      print('   🔍 Checking if badge should be visible: ${widget.unreadNotificationCount > 0}');
      print('🔔 [WebTopBar] =========================================');
    });
    
    print('🔔 [WebTopBar] ====================================');
    final children = <Widget>[
      Container(
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
                if (widget.title == 'Dashboard') ...[
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD4A200),
                      height: 1.22,
                      letterSpacing: -0.26,
                    ),
                  ),
                ] else ...[
                  // Page Title for other pages
                  Text(
                    widget.title,
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
                      controller: _searchController,
                      focusNode: _searchFocusNode,
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
                child: Builder(
                  builder: (stackContext) {
                    print('🔔 [WebTopBar] ========== Building Stack for Badge ==========');
                    print('   📊 widget.unreadNotificationCount: ${widget.unreadNotificationCount}');
                    print('   📊 Count > 0? ${widget.unreadNotificationCount > 0}');
                    print('   🔑 Stack key: ValueKey("notification_stack_${widget.unreadNotificationCount}")');
                    
                    // CRITICAL FIX: Build children list dynamically based on count
                    // This ensures old badge widgets are completely removed
                    final timestamp = DateTime.now().millisecondsSinceEpoch;
                    final stackChildren = <Widget>[
                      Container(
                        key: ValueKey('notification_button_container_$timestamp'),
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
                          onPressed: widget.onNotificationTap,
                        ),
                      ),
                    ];
                    
                    // CRITICAL FIX: ALWAYS add a badge widget (either visible or invisible)
                    // Using a key that changes forces Flutter to dispose old widget completely
                    final badgeKey = 'badge_${widget.unreadNotificationCount}_$timestamp';
                    print('   🔑 Badge widget key: $badgeKey');
                    
                    if (widget.unreadNotificationCount > 0) {
                      print('   ✅ Adding VISIBLE BADGE widget with count: ${widget.unreadNotificationCount}');
                      final displayValue = widget.unreadNotificationCount > 9 
                          ? '9+' 
                          : widget.unreadNotificationCount.toString();
                      
                      stackChildren.add(
                        Positioned(
                          key: ValueKey(badgeKey),
                          right: 0,
                          top: 0,
                          child: Container(
                            key: ValueKey('badge_container_${widget.unreadNotificationCount}_$timestamp'),
                            constraints: const BoxConstraints(minWidth: 20),
                            height: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: WebDesignConstants.notificationRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                displayValue,
                                key: ValueKey('badge_text_${widget.unreadNotificationCount}_$timestamp'),
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
                      );
                      print('   ✅ Visible badge widget added');
                    } else {
                      print('   ❌ Count is 0 - Adding INVISIBLE badge widget to force removal');
                      // Add invisible positioned widget with same position to replace old badge
                      stackChildren.add(
                        Positioned(
                          key: ValueKey(badgeKey),
                          right: 0,
                          top: 0,
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.0,
                              child: Container(
                                key: ValueKey('badge_empty_$timestamp'),
                                width: 0,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                      );
                      print('   ✅ Invisible badge widget added');
                    }
                    
                    print('   📊 Total Stack children count: ${stackChildren.length}');
                    print('   📊 Stack children keys: ${stackChildren.map((w) => w.key).toList()}');
                    print('🔔 [WebTopBar] ===========================================');
                    
                    // CRITICAL FIX: Use timestamp in key to force complete widget disposal
                    // This ensures old badge widgets are ALWAYS removed from widget tree
                    final stackKey = 'notification_stack_${widget.unreadNotificationCount}_$timestamp';
                    final boundaryKey = 'notification_stack_boundary_${widget.unreadNotificationCount}_$timestamp';
                    
                    print('   🔑 Creating Stack with key: $stackKey (timestamp: $timestamp)');
                    print('   🔑 Creating RepaintBoundary with key: $boundaryKey');
                    
                    // Update tracked count
                    if (_lastBadgeCount != widget.unreadNotificationCount) {
                      print('   🔄 Badge count changed from $_lastBadgeCount to ${widget.unreadNotificationCount}');
                      _lastBadgeCount = widget.unreadNotificationCount;
                    }
                    
                    return RepaintBoundary(
                      key: ValueKey(boundaryKey),
                      child: Stack(
                        key: ValueKey(stackKey),
                        clipBehavior: Clip.none,
                        children: [
                          ...stackChildren,
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // User info - SECOND
              InkWell(
                onTap: widget.onProfileTap,
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
      ),
    ];
    
    // Add search results dropdown if needed
    if (_showSearchResults && _searchResults.isNotEmpty) {
      children.add(
        Positioned(
          top: WebDesignConstants.topBarHeight,
          left: 24,
          right: 24,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return InkWell(
                      onTap: () => _handleResultTap(result),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              result.icon,
                              size: 20,
                              color: WebDesignConstants.webTextSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.title,
                                    style: const TextStyle(
                                      fontSize: WebDesignConstants.fontSizeBody,
                                      fontWeight: FontWeight.w500,
                                      color: WebDesignConstants.webTextPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    result.subtitle,
                                    style: const TextStyle(
                                      fontSize: WebDesignConstants.fontSizeSmall,
                                      fontWeight: FontWeight.w400,
                                      color: WebDesignConstants.webTextSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              result.type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: WebDesignConstants.webTextSecondary.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      );
    }
    
    return Stack(
      clipBehavior: Clip.none,
      children: children,
    );
  }
}
