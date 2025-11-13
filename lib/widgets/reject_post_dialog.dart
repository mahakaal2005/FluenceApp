import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class RejectPostDialog extends StatefulWidget {
  final String businessName;
  final Function(String reason) onConfirm;

  const RejectPostDialog({
    super.key,
    required this.businessName,
    required this.onConfirm,
  });

  @override
  State<RejectPostDialog> createState() => _RejectPostDialogState();
}

class _RejectPostDialogState extends State<RejectPostDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: 512,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.1),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Reject Post',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.0,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: -8,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Opacity(
                      opacity: 0.7,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Please provide a reason for rejecting this post:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4285714285714286,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.transparent,
                  width: 0.8,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: _reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'e.g., Inappropriate content, Duplicate post...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.4285714285714286,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                  height: 1.4285714285714286,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.1),
                          width: 0.8,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                            height: 1.4285714285714286,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_reasonController.text.trim().isEmpty) {
                        return;
                      }
                      Navigator.of(context).pop();
                      widget.onConfirm(_reasonController.text.trim());
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A200),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.white,
                            height: 1.4285714285714286,
                          ),
                        ),
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
}
