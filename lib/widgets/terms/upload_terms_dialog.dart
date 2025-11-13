import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../repositories/content_repository.dart';

class UploadTermsDialog extends StatefulWidget {
  const UploadTermsDialog({super.key});

  @override
  State<UploadTermsDialog> createState() => _UploadTermsDialogState();
}

class _UploadTermsDialogState extends State<UploadTermsDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _versionController = TextEditingController();
  DateTime _effectiveDate = DateTime.now();
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _effectiveDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _effectiveDate) {
      setState(() {
        _effectiveDate = picked;
      });
    }
  }

  Future<void> _uploadTerms() async {
    if (_titleController.text.trim().isEmpty || 
        _contentController.text.trim().isEmpty ||
        _versionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final repository = ContentRepository();
      await repository.createTerms(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        version: _versionController.text.trim(),
        effectiveDate: _effectiveDate,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true on success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terms & Conditions uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload Terms: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Overlay background
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Dialog box
          Center(
            child: Container(
              width: 450,
              constraints: const BoxConstraints(maxHeight: 650),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.1),
                  width: 1.1,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25.09, 25.09, 25.09, 0),
                    child: Stack(
                      children: [
                        const SizedBox(
                          width: double.infinity,
                          height: 18,
                          child: Center(
                            child: Text(
                              'Upload New Terms & Conditions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: -8,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Opacity(
                              opacity: 0.7,
                              child: Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
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
                  ),
                  const SizedBox(height: 15.99),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 25.09),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title field
                          const Text(
                            'Title',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.428,
                            ),
                          ),
                          const SizedBox(height: 7.985),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextField(
                              controller: _titleController,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'e.g., Fluence Pay Terms & Conditions',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.987),
                          // Version and Date Row
                          Row(
                            children: [
                              // Version field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Version',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textSecondary,
                                        height: 1.428,
                                      ),
                                    ),
                                    const SizedBox(height: 7.985),
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F3F5),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: TextField(
                                        controller: _versionController,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textPrimary,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'e.g., 1.0.0',
                                          hintStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.textSecondary,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Effective Date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Effective Date',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textSecondary,
                                        height: 1.428,
                                      ),
                                    ),
                                    const SizedBox(height: 7.985),
                                    InkWell(
                                      onTap: _selectDate,
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F3F5),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${_effectiveDate.day}/${_effectiveDate.month}/${_effectiveDate.year}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15.987),
                          // Content field
                          const Text(
                            'Content',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.428,
                            ),
                          ),
                          const SizedBox(height: 7.985),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextField(
                              controller: _contentController,
                              maxLines: 10,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter the full terms and conditions content...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Note: This will deactivate the previous version and make this the active version.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.99),
                  // Footer buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25.09, 0, 25.09, 25.09),
                    child: Column(
                      children: [
                        // Upload button
                        SizedBox(
                          width: double.infinity,
                          height: 37,
                          child: ElevatedButton(
                            onPressed: _isUploading ? null : _uploadTerms,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            child: _isUploading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                    ),
                                  )
                                : const Text(
                                    'Upload New Version',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.white,
                                      height: 1.428,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 7.985),
                        // Cancel button
                        SizedBox(
                          width: double.infinity,
                          height: 37,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              side: BorderSide(
                                color: Colors.black.withValues(alpha: 0.1),
                                width: 1.1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                                height: 1.428,
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
      ),
    );
  }
}

