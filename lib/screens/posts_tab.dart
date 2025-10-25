import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/post_card.dart';
import '../widgets/approve_post_dialog.dart';
import '../widgets/reject_post_dialog.dart';
import '../utils/app_colors.dart';
import '../blocs/posts_bloc.dart';

class PostsTab extends StatefulWidget {
  const PostsTab({super.key});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  @override
  void initState() {
    super.initState();
    // Load posts when the tab is initialized
    context.read<PostsBloc>().add(LoadPosts());
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocConsumer<PostsBloc, PostsState>(
        listener: (context, state) {
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
            if (state.posts.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.post_add_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No pending posts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'All posts have been reviewed',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostsBloc>().add(LoadPosts());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: PostCard(
                        post: post,
                        onApprove: () => _handleApprove(post.id, post.businessName),
                        onReject: () => _handleReject(post.id, post.businessName),
                      ),
                    ),
                  );
                },
              ),
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
