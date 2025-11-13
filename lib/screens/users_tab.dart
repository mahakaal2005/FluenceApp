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
  String _selectedUserType = 'All'; // 'All', 'Users', 'Merchants'
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
                        final user = usersState.allUsers.firstWhere(
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
                        final user = usersState.allUsers.firstWhere(
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

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFFF5F5F5), // Light grayish background
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
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
                  hintText: 'Search users...',
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
                    vertical: 0, // Remove vertical padding for better centering
                  ),
                  isDense: true, // Makes the text field more compact
                ),
                textAlignVertical: TextAlignVertical.center, // Center text vertically
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _selectedUserType != 'All' ? const Color(0xFFFEBB2C) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedUserType != 'All' ? const Color(0xFFFEBB2C) : const Color(0xFFE5E7EB),
                  width: 0.8,
                ),
              ),
              child: Icon(
                Icons.filter_list,
                size: 18,
                color: _selectedUserType != 'All' ? Colors.white : const Color(0xFF717182),
              ),
            ),
            onSelected: (String value) {
              setState(() {
                _selectedUserType = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'All',
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 18,
                      color: _selectedUserType == 'All' ? const Color(0xFFFEBB2C) : const Color(0xFF717182),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'All Users',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _selectedUserType == 'All' ? FontWeight.w600 : FontWeight.w400,
                        color: _selectedUserType == 'All' ? const Color(0xFFFEBB2C) : const Color(0xFF0A0A0A),
                      ),
                    ),
                    if (_selectedUserType == 'All') ...[
                      const Spacer(),
                      const Icon(
                        Icons.check,
                        size: 18,
                        color: Color(0xFFFEBB2C),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'Users',
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 18,
                      color: _selectedUserType == 'Users' ? const Color(0xFFFEBB2C) : const Color(0xFF717182),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Users Only',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _selectedUserType == 'Users' ? FontWeight.w600 : FontWeight.w400,
                        color: _selectedUserType == 'Users' ? const Color(0xFFFEBB2C) : const Color(0xFF0A0A0A),
                      ),
                    ),
                    if (_selectedUserType == 'Users') ...[
                      const Spacer(),
                      const Icon(
                        Icons.check,
                        size: 18,
                        color: Color(0xFFFEBB2C),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'Merchants',
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 18,
                      color: _selectedUserType == 'Merchants' ? const Color(0xFFFEBB2C) : const Color(0xFF717182),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Merchants Only',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _selectedUserType == 'Merchants' ? FontWeight.w600 : FontWeight.w400,
                        color: _selectedUserType == 'Merchants' ? const Color(0xFFFEBB2C) : const Color(0xFF0A0A0A),
                      ),
                    ),
                    if (_selectedUserType == 'Merchants') ...[
                      const Spacer(),
                      const Icon(
                        Icons.check,
                        size: 18,
                        color: Color(0xFFFEBB2C),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(UsersState state) {
    int totalUsers = 0;
    int pendingCount = 0;
    int approvedCount = 0;
    int suspendedCount = 0;

    if (state is UsersLoaded) {
      // Always calculate from ALL users, not filtered list
      totalUsers = state.allUsers.length;
      pendingCount = state.pendingUsers.length;
      approvedCount = state.approvedUsers.length;
      suspendedCount = state.suspendedUsers.length;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Users', totalUsers.toString(), const Color(0xFF0A0A0A))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('Pending', pendingCount.toString(), const Color(0xFFD4A200))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('Approved', approvedCount.toString(), const Color(0xFF00C950))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('Suspended', suspendedCount.toString(), const Color(0xFFE7000B))),
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
              // Search bar with filter icon
              _buildSearchBar(),
              const SizedBox(height: 16),
              // Stats cards
              _buildStatsCards(state),
              const SizedBox(height: 16),
              // Tab list
              _buildTabList(state),
              // Users list
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive grid
            int crossAxisCount;
            double childAspectRatio;
            
            if (constraints.maxWidth > 1400) {
              crossAxisCount = 4;
              childAspectRatio = 2.3;
            } else if (constraints.maxWidth > 1000) {
              crossAxisCount = 3;
              childAspectRatio = 2.1;
            } else if (constraints.maxWidth > 700) {
              crossAxisCount = 2;
              childAspectRatio = 1.9;
            } else {
              crossAxisCount = 1;
              childAspectRatio = 1.8;
            }
            
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return _buildUserCard(filteredUsers[index]);
              },
            );
          },
        ),
      );
    }

    return const Center(
      child: Text('Loading users...'),
    );
  }

  List<AdminUser> _getFilteredUsers(UsersLoaded state) {
    List<AdminUser> users;
    
    // First filter by status tab
    switch (_selectedTab) {
      case 'All':
        users = state.allUsers;
        break;
      case 'Pending':
        users = state.pendingUsers;
        break;
      case 'Approved':
        users = state.approvedUsers;
        break;
      case 'Suspended':
        users = state.suspendedUsers;
        break;
      default:
        users = state.allUsers;
    }
    
    // Then filter by user type
    switch (_selectedUserType) {
      case 'Users':
        return users.where((u) => u.userType == 'user').toList();
      case 'Merchants':
        return users.where((u) => u.userType == 'merchant').toList();
      case 'All':
      default:
        return users;
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
          // No need to reload - filtering happens on frontend via _getFilteredUsers
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
                    color: const Color(0xFFD4A200), // Golden badge color
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

  Widget _buildUserCard(AdminUser user) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine if we need compact layout
            final isCompact = constraints.maxWidth < 300;
            
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: isCompact ? 10 : 14,
                right: isCompact ? 10 : 14,
                top: isCompact ? 10 : 14,
                bottom: isCompact ? 8 : 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top section: Avatar, Name, and Badges
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(
                        'assets/images/user_avatar_${user.id.hashCode % 5 + 1}.png',
                        size: isCompact ? 40 : 50,
                      ),
                      SizedBox(width: isCompact ? 8 : 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: isCompact ? 13 : 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (user.company != null && user.company!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                user.company!,
                                style: TextStyle(
                                  fontSize: isCompact ? 10 : 11,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Badges aligned to the right
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusBadge(user.status, isCompact: isCompact),
                          const SizedBox(height: 3),
                          _buildUserTypeBadge(user.userType, isCompact: isCompact),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 8 : 10),
                  // Contact information
                  _buildContactInfo(user, isCompact: isCompact),
                  // Action buttons at the bottom
                  if (user.status == 'pending' || user.status == 'approved') ...[
                    SizedBox(height: isCompact ? 6 : 8),
                    _buildActionButtons(user.status, user.name, user.id, isCompact: isCompact),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContactInfo(AdminUser user, {bool isCompact = false}) {
    final iconSize = isCompact ? 10.0 : 12.0;
    final fontSize = isCompact ? 10.0 : 11.0;
    final spacing = isCompact ? 2.0 : 3.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Email
        Row(
          children: [
            Icon(Icons.email_outlined, size: iconSize, color: AppColors.textSecondary),
            SizedBox(width: spacing + 1),
            Expanded(
              child: Text(
                user.email,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Phone
        if (user.phone.isNotEmpty) ...[
          SizedBox(height: spacing),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: iconSize, color: AppColors.textSecondary),
              SizedBox(width: spacing + 1),
              Flexible(
                child: Text(
                  user.phone,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        // Location
        if (user.location != null && user.location!.isNotEmpty) ...[
          SizedBox(height: spacing),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: iconSize, color: AppColors.textSecondary),
              SizedBox(width: spacing + 1),
              Expanded(
                child: Text(
                  user.location!,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        // Joined date
        SizedBox(height: spacing),
        Row(
          children: [
            Icon(Icons.access_time, size: iconSize, color: AppColors.textSecondary),
            SizedBox(width: spacing + 1),
            Text(
              'Joined: ${_formatDate(user.joinDate)}',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(String avatarPath, {double size = 50}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD4A200), Color(0xFFC48828)],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: size * 0.52,
        ),
      ),
    );
  }



  Widget _buildStatusBadge(String status, {bool isCompact = false}) {
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
      case 'rejected':
        bgColor = AppColors.badgeRed;
        textColor = AppColors.badgeRedText;
        label = 'rejected';
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
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 4 : 6,
        vertical: isCompact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isCompact ? 9 : 10,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildUserTypeBadge(String userType, {bool isCompact = false}) {
    final isUser = userType.toLowerCase() == 'user';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: isUser ? AppColors.badgeBlue : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUser ? Icons.person_outline : Icons.store_outlined,
            size: isCompact ? 10 : 12,
            color: isUser ? AppColors.badgeBlueText : const Color(0xFF92400E),
          ),
          SizedBox(width: isCompact ? 3 : 4),
          Text(
            isUser ? 'User' : 'Merchant',
            style: TextStyle(
              fontSize: isCompact ? 10 : 12,
              fontWeight: FontWeight.w400,
              color: isUser ? AppColors.badgeBlueText : const Color(0xFF92400E),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status, String userName, String userId, {bool isCompact = false}) {
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'Approve',
              icon: Icons.check_circle_outline,
              backgroundColor: AppColors.buttonApprove,
              textColor: AppColors.white,
              isCompact: isCompact,
              onTap: () {
                _showApproveDialog(context, userName);
              },
            ),
          ),
          SizedBox(width: isCompact ? 8 : 12),
          Expanded(
            child: _buildActionButton(
              label: 'Reject',
              icon: Icons.cancel_outlined,
              backgroundColor: AppColors.buttonReject,
              textColor: AppColors.white,
              isCompact: isCompact,
              onTap: () {
                _showRejectDialog(context, userName);
              },
            ),
          ),
        ],
      );
    } else if (status == 'approved') {
      return SizedBox(
        width: double.infinity,
        child: _buildActionButton(
          label: 'Suspend',
          icon: Icons.block_outlined,
          backgroundColor: AppColors.white,
          textColor: AppColors.textPrimary,
          borderColor: Colors.black.withValues(alpha: 0.1),
          isCompact: isCompact,
          onTap: () {
            context.read<UsersBloc>().add(SuspendUser(userId));
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    bool isCompact = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: isCompact ? 32 : 36,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12,
          vertical: isCompact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.1)
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: borderColor == null ? [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isCompact ? 14 : 16,
              color: textColor,
            ),
            SizedBox(width: isCompact ? 4 : 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isCompact ? 11 : 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.0,
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
