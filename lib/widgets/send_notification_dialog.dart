import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../repositories/notifications_repository.dart';

class SendNotificationDialog extends StatefulWidget {
  const SendNotificationDialog({super.key});

  @override
  State<SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<SendNotificationDialog> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isSending = false;
  List<String> _selectedUserIds = []; // Empty means all users
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      // TODO: Load users from users repository
      // For now, using mock data
      _allUsers = [
        {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'},
        {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com'},
        {'id': '3', 'name': 'Bob Johnson', 'email': 'bob@example.com'},
        {'id': '4', 'name': 'Alice Williams', 'email': 'alice@example.com'},
        {'id': '5', 'name': 'Charlie Brown', 'email': 'charlie@example.com'},
      ];
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
      }
    }
  }

  String _getRecipientLabel() {
    if (_selectedUserIds.isEmpty) {
      return 'All Users (${_allUsers.length})';
    } else if (_selectedUserIds.length == 1) {
      final user = _allUsers.firstWhere((u) => u['id'] == _selectedUserIds[0]);
      return user['name'];
    } else {
      return '${_selectedUserIds.length} Users Selected';
    }
  }

  void _showRecipientSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final searchQuery = _searchController.text.toLowerCase();
            final filteredUsers = _allUsers.where((user) {
              final name = (user['name'] as String).toLowerCase();
              final email = (user['email'] as String).toLowerCase();
              return name.contains(searchQuery) || email.contains(searchQuery);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Recipients',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              if (_selectedUserIds.isEmpty) {
                                _selectedUserIds = _allUsers.map((u) => u['id'] as String).toList();
                              } else {
                                _selectedUserIds.clear();
                              }
                            });
                          },
                          child: Text(
                            _selectedUserIds.isEmpty ? 'Select All' : 'Clear All',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setModalState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search users...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // User list
                  Expanded(
                    child: _isLoadingUsers
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              final userId = user['id'] as String;
                              final isSelected = _selectedUserIds.contains(userId);

                              return InkWell(
                                onTap: () {
                                  setModalState(() {
                                    if (isSelected) {
                                      _selectedUserIds.remove(userId);
                                    } else {
                                      _selectedUserIds.add(userId);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFF9FAFB) : Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primary : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                color: AppColors.white,
                                                size: 14,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user['name'] as String,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              user['email'] as String,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // Done button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {}); // Update parent state
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _selectedUserIds.isEmpty
                              ? 'Send to All Users'
                              : 'Done (${_selectedUserIds.length} selected)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final repository = NotificationsRepository();
      // TODO: Update repository to support recipientType parameter
      await repository.sendNotification(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: 'in_app',
      );
      // Note: Currently sends to all users. Backend needs to support recipient filtering.

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send notification: $e'),
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
              width: 362.29,
              constraints: const BoxConstraints(maxHeight: 442.17),
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
                              'Send Push Notification',
                              style: TextStyle(
                                fontFamily: 'Arial',
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
                              fontFamily: 'Arial',
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
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Notification title...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Arial',
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
                          // Message field
                          const Text(
                            'Message',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.428,
                            ),
                          ),
                          const SizedBox(height: 7.985),
                          Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextField(
                              controller: _messageController,
                              maxLines: 3,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Notification message...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Arial',
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
                          // Recipients selector
                          const Text(
                            'Recipients',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.428,
                            ),
                          ),
                          const SizedBox(height: 7.985),
                          InkWell(
                            onTap: () => _showRecipientSelector(),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
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
                                    _getRecipientLabel(),
                                    style: const TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                                    size: 20,
                                  ),
                                ],
                              ),
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
                        // Send Now button
                        SizedBox(
                          width: double.infinity,
                          height: 37,
                          child: ElevatedButton(
                            onPressed: _isSending ? null : _sendNotification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            child: _isSending
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                    ),
                                  )
                                : const Text(
                                    'Send Now',
                                    style: TextStyle(
                                      fontFamily: 'Arial',
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
                                fontFamily: 'Arial',
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
