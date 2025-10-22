import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import '../widgets/approve_post_dialog.dart';
import '../widgets/reject_post_dialog.dart';
import '../utils/app_colors.dart';

class PostsTab extends StatefulWidget {
  const PostsTab({super.key});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  // Mock data for posts
  late List<Post> posts;

  @override
  void initState() {
    super.initState();
    posts = [
      Post(
        id: '1',
        businessName: 'Coffee House',
        username: '@priya_sharma',
        description: 'Amazing cappuccino and ambiance! ☕ Highly recommend this place.',
        imageAssetPath: 'assets/images/post_coffee_house.png',
        latitude: 19.0760,
        longitude: 72.8777,
        timestamp: DateTime(2024, 10, 17, 14, 30),
        status: PostStatus.pending,
      ),
      Post(
        id: '2',
        businessName: 'Green Grocers Ltd',
        username: '@rajesh_k',
        description: 'Fresh organic vegetables at great prices! 🥬🥕',
        imageAssetPath: 'assets/images/post_green_grocers.png',
        latitude: 0.0000,
        longitude: 0.0000,
        timestamp: DateTime(2024, 10, 17, 12, 15),
        status: PostStatus.pending,
        alertMessage: 'Invalid GPS coordinates',
        alertType: AlertType.error,
      ),
      Post(
        id: '3',
        businessName: 'Bookworm Cafe',
        username: '@anita_d',
        description: 'Perfect spot for reading and coffee! 📚',
        imageAssetPath: 'assets/images/post_bookworm_cafe.png',
        latitude: 19.0896,
        longitude: 72.8656,
        timestamp: DateTime(2024, 10, 17, 10, 0),
        status: PostStatus.pending,
        alertMessage: 'Possible duplicate post detected',
        alertType: AlertType.warning,
      ),
      Post(
        id: '4',
        businessName: 'Fitness First Gym',
        username: '@vikram_s',
        description: 'Great workout session today! 💪',
        imageAssetPath: 'assets/images/post_fitness_gym.png',
        latitude: 19.1136,
        longitude: 72.8697,
        timestamp: DateTime(2024, 10, 16, 18, 45),
        status: PostStatus.approved,
      ),
    ];
  }

  void _showApproveDialog(BuildContext context, String postId) {
    final post = posts.firstWhere((p) => p.id == postId);
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => ApprovePostDialog(
        businessName: post.businessName,
        onConfirm: () {
          // TODO: Implement backend integration
          // Approved post: $postId
        },
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String postId) {
    final post = posts.firstWhere((p) => p.id == postId);
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => RejectPostDialog(
        businessName: post.businessName,
        onConfirm: (reason) {
          // TODO: Implement backend integration with reason
          // Rejected post: $postId with reason: $reason
        },
      ),
    );
  }

  void _handleApprove(String postId) {
    _showApproveDialog(context, postId);
  }

  void _handleReject(String postId) {
    _showRejectDialog(context, postId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: PostCard(
                post: post,
                onApprove: () => _handleApprove(post.id),
                onReject: () => _handleReject(post.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
