import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/post_card.dart';
import '../widgets/approve_post_dialog.dart';
import '../widgets/reject_post_dialog.dart';
import '../widgets/post_detail_dialog.dart';
import '../utils/app_colors.dart';
import '../blocs/posts_bloc.dart';
import '../models/post.dart';

class PostsTab extends StatefulWidget {
  final String? postIdToOpen;
  
  const PostsTab({super.key, this.postIdToOpen});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  String _selectedTab = 'All';
  bool _hasOpenedPost = false;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    // Load posts when the tab is initialized
    context.read<PostsBloc>().add(LoadPosts());
  }

  @override
  void didUpdateWidget(PostsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If postIdToOpen changed and we haven't opened it yet, reset the flag
    if (widget.postIdToOpen != oldWidget.postIdToOpen && widget.postIdToOpen != null) {
      _hasOpenedPost = false;
    }
  }

  void _openPostDetailIfNeeded(PostsState state) {
    if (widget.postIdToOpen == null || _hasOpenedPost) {
      return;
    }

    if (state is PostsLoaded) {
      try {
        final post = state.posts.firstWhere(
          (p) => p.id == widget.postIdToOpen,
        );

        // Wait a bit for the UI to render, then open the dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_hasOpenedPost) {
            _hasOpenedPost = true;
            showDialog(
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.5),
              builder: (context) => PostDetailDialog(
                post: post,
                onApprove: () => _handleApprove(post.id, post.businessName),
                onReject: () => _handleReject(post.id, post.businessName),
              ),
            );
          }
        });
      } catch (e) {
        // Post not found - show error message
        if (mounted && !_hasOpenedPost) {
          _hasOpenedPost = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post not found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  void _showApproveDialog(BuildContext context, String postId, String businessName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => ApprovePostDialog(
        businessName: businessName,
        onConfirm: () {
          context.read<PostsBloc>().add(ApprovePost(postId));
        },
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String postId, String businessName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => RejectPostDialog(
        businessName: businessName,
        onConfirm: (reason) {
          context.read<PostsBloc>().add(RejectPost(postId, reason));
        },
      ),
    );
  }

  void _handleApprove(String postId, String businessName) {
    _showApproveDialog(context, postId, businessName);
  }

  void _handleReject(String postId, String businessName) {
    _showRejectDialog(context, postId, businessName);
  }

  Widget _buildStatsCards(PostsState state) {
    int totalPosts = 0;
    int pendingCount = 0;
    int approvedCount = 0;
    int rejectedCount = 0;

    if (state is PostsLoaded) {
      totalPosts = state.allPosts.length;
      pendingCount = state.pendingPosts.length;
      approvedCount = state.approvedPosts.length;
      rejectedCount = state.rejectedPosts.length;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Posts', totalPosts.toString(), const Color(0xFF0A0A0A))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('Pending Review', pendingCount.toString(), const Color(0xFFD4A200))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('Approved', approvedCount.toString(), const Color(0xFF00C950))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('Rejected', rejectedCount.toString(), const Color(0xFFE7000B))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF717182),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 0.8,
          ),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search posts...',
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF717182),
            ),
            prefixIcon: const Icon(
              Icons.search,
              size: 16,
              color: Color(0xFF717182),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 0,
            ),
            isDense: true,
          ),
          textAlignVertical: TextAlignVertical.center,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTabList(PostsState state) {
    int pendingCount = 0;
    if (state is PostsLoaded) {
      pendingCount = state.pendingCount;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.tabBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTab('All'),
          _buildTab('Pending', badge: pendingCount),
          _buildTab('Approved'),
          _buildTab('Rejected'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, {int? badge}) {
    final isSelected = _selectedTab == label;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = label;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            border: Border.all(
              color: Colors.transparent,
              width: 1.1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.43,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (badge != null && badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      badge.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Check if a post matches the search query
  bool _postMatchesSearch(Post post, String query) {
    if (query.trim().isEmpty) return true;
    final lowerQuery = query.toLowerCase().trim();
    
    return post.username.toLowerCase().contains(lowerQuery) ||
           post.businessName.toLowerCase().contains(lowerQuery) ||
           post.description.toLowerCase().contains(lowerQuery);
  }

  List<Post> _getFilteredPosts(PostsLoaded state) {
    // First filter by tab status
    List<Post> tabFiltered;
    switch (_selectedTab) {
      case 'All':
        tabFiltered = state.allPosts;
        break;
      case 'Pending':
        tabFiltered = state.pendingPosts;
        break;
      case 'Approved':
        tabFiltered = state.approvedPosts;
        break;
      case 'Rejected':
        tabFiltered = state.rejectedPosts;
        break;
      default:
        tabFiltered = state.allPosts;
    }
    
    // Then filter by search query if provided
    if (_searchQuery.trim().isEmpty) {
      return tabFiltered;
    }
    
    return tabFiltered.where((post) => _postMatchesSearch(post, _searchQuery)).toList();
  }

  /// Get maximum card width for responsive grid
  /// Cards will never exceed this width, automatically calculating columns
  double _getMaxCrossAxisExtent(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return 360.0; // Mobile: 360px max (1-2 columns) - tighter
    if (width < 1024) return 380.0; // Tablet: 380px max (2-3 columns) - tighter
    if (width < 1440) return 400.0; // Desktop: 400px max (3-4 columns) - tighter
    return 420.0; // Large desktop: 420px max (4-5 columns) - tighter
  }

  /// Get responsive grid spacing based on screen size
  /// Tighter spacing for better visual density and reduced gaps
  double _getGridSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return 12.0; // Mobile: tighter spacing
    if (width < 1024) return 16.0; // Tablet: balanced spacing
    return 20.0; // Desktop: comfortable but compact spacing
  }

  /// Get responsive grid padding based on screen size
  /// Optimized padding for better edge spacing
  double _getGridPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return 12.0; // Mobile: compact padding
    if (width < 1024) return 16.0; // Tablet: balanced padding
    return 20.0; // Desktop: comfortable padding
  }

  /// Get responsive card aspect ratio based on screen size
  /// Slightly adjusted for better card proportions
  double _getCardAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return 1.15; // Mobile: slightly taller cards
    if (width < 1024) return 1.25; // Tablet: balanced cards
    return 1.35; // Desktop: wider cards (but not too wide)
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocConsumer<PostsBloc, PostsState>(
        listener: (context, state) {
          // Try to open post detail if needed
          _openPostDetailIfNeeded(state);
          
          if (state is PostsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PostActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PostsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is PostsError) {
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
                    'Error loading posts',
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
                      context.read<PostsBloc>().add(LoadPosts());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PostsLoaded) {
            final filteredPosts = _getFilteredPosts(state);
            
            return Column(
              children: [
                // Search bar
                _buildSearchBar(),
                const SizedBox(height: 16),
                // Stats cards
                _buildStatsCards(state),
                const SizedBox(height: 16),
                // Tab list
                _buildTabList(state),
                // Posts grid
                Expanded(
                  child: filteredPosts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.post_add_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No ${_selectedTab.toLowerCase()} posts',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<PostsBloc>().add(LoadPosts());
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate responsive grid properties
                              final double gridPadding = _getGridPadding(context);
                              final double spacing = _getGridSpacing(context);
                              final double maxExtent = _getMaxCrossAxisExtent(context);
                              final double aspectRatio = _getCardAspectRatio(context);
                              
                              return GridView.builder(
                                padding: EdgeInsets.all(gridPadding),
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: maxExtent,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                  childAspectRatio: aspectRatio,
                                ),
                                itemCount: filteredPosts.length,
                                itemBuilder: (context, index) {
                                  final post = filteredPosts[index];
                                  // PostCard is wrapped in Container with MainAxisSize.min
                                  // to ensure consistent sizing and prevent overflow
                                  return PostCard(
                                    post: post,
                                    onApprove: () => _handleApprove(post.id, post.businessName),
                                    onReject: () => _handleReject(post.id, post.businessName),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('Loading posts...'),
          );
        },
      ),
    );
  }
}
