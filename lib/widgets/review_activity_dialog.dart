import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/posts_bloc.dart';
import '../blocs/dashboard_bloc.dart';
import '../utils/app_colors.dart';
import 'approve_post_dialog.dart';
import 'reject_post_dialog.dart';

class ReviewActivityDialog extends StatelessWidget {
  final String entityId;
  final String entityType;
  final Map<String, dynamic> entityData;

  const ReviewActivityDialog({
    super.key,
    required this.entityId,
    required this.entityType,
    required this.entityData,
  });

  @override
  Widget build(BuildContext context) {
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entityType == 'post' ? 'Review Post' : 'Review Application',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: entityType == 'post'
                    ? _buildPostContent(context)
                    : _buildUserContent(context),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: 'Approve',
                      color: AppColors.buttonApprove,
                      onTap: () => _handleApprove(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: 'Reject',
                      color: AppColors.buttonReject,
                      onTap: () => _handleReject(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent(BuildContext context) {
    final String username = entityData['username'] ?? entityData['businessName'] ?? 'Unknown';
    final String platform = entityData['platform'] ?? 'social media';
    final String description = entityData['description'] ?? entityData['content'] ?? 'No description';
    final String? imageUrl = entityData['imageUrl'] ?? entityData['imageAssetPath'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Info
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.badgeYellow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.person, size: 24, color: AppColors.badgeYellowText),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'on $platform',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Post Image (if available)
        if (imageUrl != null && imageUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: AppColors.badgeGray,
                      child: const Icon(Icons.image, size: 48, color: AppColors.textSecondary),
                    ),
                  )
                : Image.asset(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: AppColors.badgeGray,
                      child: const Icon(Icons.image, size: 48, color: AppColors.textSecondary),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
        ],

        // Post Description
        const Text(
          'Post Content',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildUserContent(BuildContext context) {
    final String businessName = entityData['businessName'] ?? 'Unknown Business';
    final String contactName = entityData['contactName'] ?? entityData['name'] ?? 'Unknown';
    final String email = entityData['contactEmail'] ?? entityData['email'] ?? 'No email';
    final String phone = entityData['contactPhone'] ?? entityData['phone'] ?? 'No phone';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business Info
        _buildInfoRow('Business Name', businessName),
        const SizedBox(height: 12),
        _buildInfoRow('Contact Person', contactName),
        const SizedBox(height: 12),
        _buildInfoRow('Email', email),
        const SizedBox(height: 12),
        _buildInfoRow('Phone', phone),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _handleApprove(BuildContext context) {
    if (entityType == 'post') {
      final String businessName = entityData['username'] ?? entityData['businessName'] ?? 'Unknown';
      Navigator.of(context).pop(); // Close review dialog
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (dialogContext) => ApprovePostDialog(
          businessName: businessName,
          onConfirm: () {
            context.read<PostsBloc>().add(ApprovePost(entityId));
            // Refresh dashboard after approval
            Future.delayed(const Duration(milliseconds: 500), () {
              context.read<DashboardBloc>().add(RefreshDashboardData());
            });
          },
        ),
      );
    } else {
      // Handle user/merchant approval
      // TODO: Implement when UsersBloc is available
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User approval feature coming soon'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _handleReject(BuildContext context) {
    if (entityType == 'post') {
      final String businessName = entityData['username'] ?? entityData['businessName'] ?? 'Unknown';
      Navigator.of(context).pop(); // Close review dialog
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (dialogContext) => RejectPostDialog(
          businessName: businessName,
          onConfirm: (reason) {
            context.read<PostsBloc>().add(RejectPost(entityId, reason));
            // Refresh dashboard after rejection
            Future.delayed(const Duration(milliseconds: 500), () {
              context.read<DashboardBloc>().add(RefreshDashboardData());
            });
          },
        ),
      );
    } else {
      // Handle user/merchant rejection
      // TODO: Implement when UsersBloc is available
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User rejection feature coming soon'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}

