import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_colors.dart';
import '../blocs/users_bloc.dart';
import '../models/user.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  String _selectedTab = 'All';
  final TextEditingController _rejectReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load users when the tab is initialized
    context.read<UsersBloc>().add(const LoadUsers());
  }

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }

  void _showApproveDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: 362.29,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.1),
              width: 1.1,
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
          padding: const EdgeInsets.all(25.09),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Approve User',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A),
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
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
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to approve $userName?',
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF717182),
                  height: 1.4285714285714286,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      // Find the user by name and approve
                      final usersState = context.read<UsersBloc>().state;
                      if (usersState is UsersLoaded) {
                        final user = usersState.users.firstWhere(
                          (u) => u.name == userName,
                          orElse: () => throw Exception('User not found'),
                        );
                        context.read<UsersBloc>().add(ApproveUser(user.id));
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      height: 37,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A63E),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: const Center(
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFFFFF),
                            height: 1.4285714285714286,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7.985),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      height: 37,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.1),
                          width: 1.1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0A0A0A),
                            height: 1.4285714285714286,
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
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String userName) {
    _rejectReasonController.clear();
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: 362.29,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.1),
              width: 1.1,
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
          padding: const EdgeInsets.all(25.09),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Reject User',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A),
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
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
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Please provide a reason for rejecting $userName:',
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF717182),
                  height: 1.4285714285714286,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 15.987),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 1.1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  controller: _rejectReasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Enter reason here...',
                    hintStyle: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF717182),
                      height: 1.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF0A0A0A),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      if (_rejectReasonController.text.trim().isEmpty) {
                        return;
                      }
                      Navigator.of(context).pop();
                      // Find the user by name and reject
                      final usersState = context.read<UsersBloc>().state;
                      if (usersState is UsersLoaded) {
                        final user = usersState.users.firstWhere(
                          (u) => u.name == userName,
                          orElse: () => throw Exception('User not found'),
                        );
                        context.read<UsersBloc>().add(
                          RejectUser(user.id, _rejectReasonController.text.trim()),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      height: 37,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A200),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: const Center(
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFFFFF),
                            height: 1.4285714285714286,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7.985),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      height: 37,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.1),
                          width: 1.1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0A0A0A),
                            height: 1.4285714285714286,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocConsumer<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UsersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UserActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildTabList(state),
              Expanded(
                child: _buildUsersList(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabList(UsersState state) {
    int pendingCount = 0;
    if (state is UsersLoaded) {
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
          _buildTab('Suspended'),
        ],
      ),
    );
  }

  Widget _buildUsersList(UsersState state) {
    if (state is UsersLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is UsersError) {
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
            Text(
              'Error loading users',
              style: const TextStyle(
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
                context.read<UsersBloc>().add(const LoadUsers());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is UsersLoaded) {
      final filteredUsers = _getFilteredUsers(state);
      
      if (filteredUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No ${_selectedTab.toLowerCase()} users found',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<UsersBloc>().add(const LoadUsers());
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            return _buildUserCard(filteredUsers[index]);
          },
        ),
      );
    }

    return const Center(
      child: Text('Loading users...'),
    );
  }

  List<AdminUser> _getFilteredUsers(UsersLoaded state) {
    switch (_selectedTab) {
      case 'All':
        return state.allUsers;
      case 'Pending':
        return state.pendingUsers;
      case 'Approved':
        return state.approvedUsers;
      case 'Suspended':
        return state.suspendedUsers;
      default:
        return state.allUsers;
    }
  }

  Widget _buildTab(String label, {int? badge}) {
    final isSelected = _selectedTab == label;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = label;
          });
          // Load users with the selected filter
          final statusFilter = label == 'All' ? null : label.toLowerCase();
          context.read<UsersBloc>().add(LoadUsers(statusFilter: statusFilter));
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
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.badgeTabYellow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    badge.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                      height: 1.33,
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

  Widget _buildUserCard(AdminUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar('assets/images/user_avatar_${user.id.hashCode % 5 + 1}.png'),
          const SizedBox(width: 10),
          Expanded(
            child: _buildUserInfo(user),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatarPath) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Image.asset(
        avatarPath,
        width: 20,
        height: 20,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.person,
            color: Colors.white,
            size: 20,
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(AdminUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.company != null)
                    Text(
                      user.company!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(user.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'Joined: ${_formatDate(user.joinDate)}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (user.status == 'pending' || user.status == 'approved') ...[
          const SizedBox(height: 8),
          _buildActionButtons(user.status, user.name, user.id),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = AppColors.badgeYellow;
        textColor = AppColors.badgeYellowText;
        label = 'pending';
        break;
      case 'approved':
        bgColor = AppColors.badgeGreen;
        textColor = AppColors.badgeGreenText;
        label = 'approved';
        break;
      case 'suspended':
        bgColor = AppColors.badgeOrange;
        textColor = AppColors.badgeOrangeText;
        label = 'suspended';
        break;
      default:
        bgColor = AppColors.badgeGray;
        textColor = AppColors.badgeGrayText;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildActionButtons(String status, String userName, String userId) {
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'Approve',
              iconPath: 'assets/images/approve_icon.png',
              backgroundColor: AppColors.buttonApprove,
              onTap: () {
                _showApproveDialog(context, userName);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              label: 'Reject',
              iconPath: 'assets/images/reject_icon.png',
              backgroundColor: AppColors.buttonReject,
              onTap: () {
                _showRejectDialog(context, userName);
              },
            ),
          ),
        ],
      );
    } else if (status == 'approved') {
      return _buildActionButton(
        label: 'Suspend',
        iconPath: 'assets/images/suspend_icon.png',
        backgroundColor: AppColors.white,
        textColor: AppColors.textPrimary,
        borderColor: Colors.black.withValues(alpha: 0.1),
        onTap: () {
          context.read<UsersBloc>().add(SuspendUser(userId));
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required String label,
    required String iconPath,
    required Color backgroundColor,
    Color textColor = AppColors.white,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.1)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              color: textColor,
              colorBlendMode: BlendMode.srcIn,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.check,
                  size: 16,
                  color: textColor,
                );
              },
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
