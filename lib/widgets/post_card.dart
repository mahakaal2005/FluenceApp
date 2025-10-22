import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/post.dart';
import '../utils/app_colors.dart';
import 'post_detail_dialog.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const PostCard({
    super.key,
    required this.post,
    this.onApprove,
    this.onReject,
  });

  void _showPostDetail(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => PostDetailDialog(
        post: post,
        onApprove: onApprove,
        onReject: onReject,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Post Card - Wrapped with InkWell for tap functionality
        InkWell(
          onTap: () => _showPostDetail(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 341,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Alert Message (if any) - AT THE TOP OF THE CARD
              if (post.alertMessage != null && post.alertType != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: post.alertType == AlertType.error
                        ? AppColors.alertErrorBackground
                        : AppColors.alertWarningBackground,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: post.alertType == AlertType.error
                            ? AppColors.alertErrorBorder
                            : AppColors.alertWarningBorder,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: post.alertType == AlertType.error
                            ? AppColors.alertErrorText
                            : AppColors.alertWarningText,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          post.alertMessage!,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: post.alertType == AlertType.error
                                ? AppColors.alertErrorText
                                : AppColors.alertWarningText,
                            height: 1.43,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Post Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail Image
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.badgeGray,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          post.imageAssetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.badgeGray,
                              child: const Icon(
                                Icons.image,
                                color: AppColors.textSecondary,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Post Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Business Name + Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.businessName,
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textPrimary,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      post.username,
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textSecondary,
                                        height: 1.43,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: post.status == PostStatus.pending
                                      ? AppColors.badgeYellow
                                      : AppColors.badgeGreen,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  post.status == PostStatus.pending
                                      ? 'pending'
                                      : 'approved',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: post.status == PostStatus.pending
                                        ? AppColors.badgeYellowText
                                        : AppColors.badgeGreenText,
                                    height: 1.33,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Description
                          Text(
                            post.description,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                              height: 1.43,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Metadata: Location + Timestamp
                          Row(
                            children: [
                              // Location - Vertical layout (coordinates stacked)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Image.asset(
                                      'assets/images/location_icon.png',
                                      width: 11,
                                      height: 11,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.location_on,
                                          size: 11,
                                          color: AppColors.textSecondary,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.latitude.toStringAsFixed(4),
                                        style: const TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textSecondary,
                                          height: 1.33,
                                        ),
                                      ),
                                      Text(
                                        post.longitude.toStringAsFixed(4),
                                        style: const TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textSecondary,
                                          height: 1.33,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // Timestamp - Vertical layout (date and time stacked)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Image.asset(
                                      'assets/images/time_icon.png',
                                      width: 11,
                                      height: 11,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.access_time,
                                          size: 11,
                                          color: AppColors.textSecondary,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM,').format(post.timestamp),
                                        style: const TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textSecondary,
                                          height: 1.33,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('hh:mm a').format(post.timestamp),
                                        style: const TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textSecondary,
                                          height: 1.33,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    // Approve Button
                    Expanded(
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.buttonApprove,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onApprove,
                            borderRadius: BorderRadius.circular(14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/approve_button_icon.png',
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: AppColors.white,
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Approve',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.white,
                                    height: 1.43,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Reject Button
                    Expanded(
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.buttonReject,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onReject,
                            borderRadius: BorderRadius.circular(14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/reject_button_icon.png',
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppColors.white,
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Reject',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.white,
                                    height: 1.43,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ],
    );
  }
}
