import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/content_bloc.dart';
import '../blocs/notification_recipients_bloc.dart';
import '../models/faq.dart';
import '../models/notification.dart';
import '../utils/app_colors.dart';
import '../widgets/faq/add_faq_dialog.dart';
import '../widgets/faq/delete_confirmation_dialog.dart';
import '../widgets/faq/edit_faq_dialog.dart';
import '../widgets/send_notification_dialog.dart';
import '../widgets/terms/preview_terms_dialog.dart';
import '../widgets/terms/upload_terms_dialog.dart';

class ContentTab extends StatefulWidget {
  final int initialTabIndex;

  const ContentTab({super.key, this.initialTabIndex = 0});

  @override
  State<ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends State<ContentTab> {
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  @override
  void didUpdateWidget(ContentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected tab index when initialTabIndex changes
    if (widget.initialTabIndex != oldWidget.initialTabIndex) {
      setState(() {
        _selectedTabIndex = widget.initialTabIndex;
      });
      // If switching to Notifications tab, reload notifications
      // This will trigger markAllAsOpened() and update the badge count
      if (widget.initialTabIndex == 1) {
        context.read<ContentBloc>().add(const LoadNotifications());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.99),
        child: Column(
          children: [
            const SizedBox(height: 23.97),
            _buildTabNavigation(),
            const SizedBox(height: 23.97),
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFECECF0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTabButton('FAQs', 0),
          _buildTabButton('Notifications', 1),
          _buildTabButton('Analytics', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          // When switching to Notifications tab, reload notifications
          // This will trigger markAllAsOpened() and update the badge count
          if (index == 1) {
            context.read<ContentBloc>().add(const LoadNotifications());
          }
        },
        child: Container(
          height: 29,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF0A0A0A),
                height: 1.4285714285714286,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTabIndex == 0) {
      return _buildFAQsContent();
    } else if (_selectedTabIndex == 1) {
      return _buildNotificationsContent();
    } else {
      return _buildAnalyticsContent();
    }
  }

  Widget _buildFAQsContent() {
    return Column(
      children: [
        _buildManageFAQsCard(),
        const SizedBox(height: 15.987),
        _buildTermsConditionsCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildManageFAQsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title with icon
                Row(
                  children: [
                    Image.asset(
                      'assets/images/faq_icon.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.help_outline,
                          size: 20,
                          color: AppColors.primary,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Manage FAQs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF0A0A0A),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                // Add FAQ Button
                InkWell(
                  onTap: () async {
                    final result = await showDialog(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (context) => const AddFAQDialog(),
                    );

                    if (result == true && mounted) {
                      context.read<ContentBloc>().add(const LoadFAQs());
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 102.3,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFD4A200), Color(0xFFC48828)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      children: [
                        // Icon positioned at x=10, y=8
                        Positioned(
                          left: 10,
                          top: 8,
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CustomPaint(
                              painter: _PlusIconPainter(),
                            ),
                          ),
                        ),
                        // Text positioned at x=26.1, y=6
                        const Positioned(
                          left: 26.1,
                          top: 6,
                          child: Text(
                            'Add FAQ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFFFFFFF),
                              height: 1.4285714285714286,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // FAQ Items
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
            child: BlocBuilder<ContentBloc, ContentState>(
              builder: (context, state) {
                if (state is ContentLoaded) {
                  if (state.isLoadingFAQs) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state.faqs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No FAQs available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF717182),
                          ),
                        ),
                      ),
                    );
                  }

                  // Calculate height: 5 items max visible
                  final itemHeight = 116.0; // Approximate height per FAQ item
                  final spacing = 12.0;
                  final maxVisibleItems = 5;
                  final maxHeight = (itemHeight * maxVisibleItems) + (spacing * (maxVisibleItems - 1));
                  final needsScroll = state.faqs.length > maxVisibleItems;

                  return SizedBox(
                    height: needsScroll ? maxHeight : null,
                    child: ListView.separated(
                      shrinkWrap: !needsScroll,
                      physics: needsScroll ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                      itemCount: state.faqs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildFAQItem(state.faqs[index]),
                    ),
                  );
                }

                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQ faq) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge and action icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  faq.category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1447E6),
                    height: 1.333,
                  ),
                ),
              ),
              // Edit and Delete icons
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      final result = await showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (context) => EditFAQDialog(faq: faq),
                      );

                      if (result == true && mounted) {
                        context.read<ContentBloc>().add(const LoadFAQs());
                      }
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () async {
                      final result = await showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (context) =>
                            DeleteConfirmationDialog(faq: faq),
                      );

                      if (result == true && mounted) {
                        context.read<ContentBloc>().add(const LoadFAQs());
                      }
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Question
          Text(
            faq.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF0A0A0A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          // Answer
          Text(
            faq.answer,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF717182),
              height: 1.4285714285714286,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsConditionsCard() {
    return Container(
      width: 341.39,
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
          // Header
          Padding(
            padding: const EdgeInsets.all(23.99),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/document_icon.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: AppColors.primary,
                    );
                  },
                ),
                const SizedBox(width: 7.98),
                const Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.989),
            child: BlocBuilder<ContentBloc, ContentState>(
              builder: (context, state) {
                if (state is! ContentLoaded) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state.isLoadingTerms) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state.terms == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No Terms & Conditions available',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                final terms = state.terms!;
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15.987),
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Terms_v${terms.version}.pdf',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                              Text(
                                'Last updated: ${_formatDate(terms.effectiveDate)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                  height: 1.428,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 49.49,
                            height: 19.98,
                            decoration: BoxDecoration(
                              color: terms.isActive
                                  ? AppColors.badgeGreen
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                terms.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: terms.isActive
                                      ? AppColors.badgeGreenText
                                      : Colors.white,
                                  height: 1.333,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11.994),
                    InkWell(
                      onTap: () async {
                        final result = await showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (context) => const UploadTermsDialog(),
                        );

                        if (result == true && mounted) {
                          context.read<ContentBloc>().add(const LoadTerms());
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 35.98,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/upload_icon.png',
                              width: 15.99,
                              height: 15.99,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.upload,
                                  size: 15.99,
                                  color: AppColors.textPrimary,
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Upload New Version',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                                height: 1.428,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 11.994),
                    // Preview button
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (context) =>
                              PreviewTermsDialog(terms: terms),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 35.98,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.visibility_outlined,
                              size: 15.99,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Preview Current Version',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                                height: 1.428,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 23.99),
        ],
      ),
    );
  }

  Widget _buildNotificationsContent() {
    return Column(
      children: [
        _buildSendNotificationButton(),
        const SizedBox(height: 15.987),
        _buildRecentNotificationsCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSendNotificationButton() {
    return InkWell(
      onTap: () async {
        final result = await showDialog(
          context: context,
          barrierColor: Colors.transparent,
          builder: (dialogContext) => BlocProvider.value(
            value: context.read<NotificationRecipientsBloc>(),
            child: const SendNotificationDialog(),
          ),
        );

        if (result == true && mounted) {
          context.read<ContentBloc>().add(const LoadNotifications());
          context.read<ContentBloc>().add(const LoadAnalytics());
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 362.32,
        height: 35.98,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4A200), Color(0xFFC48828)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            const Text(
              'Send New Notification',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFFFFFFF),
                height: 1.4285714285714286,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNotificationsCard() {
    return Container(
      width: 362.32,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.all(23.99),
            child: Text(
              'Recent Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
                height: 1.0,
              ),
            ),
          ),
          // Notification Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.989),
            child: BlocBuilder<ContentBloc, ContentState>(
              builder: (context, state) {
                if (state is! ContentLoaded) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state.isLoadingNotifications) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state.notifications.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                // Calculate height: 5 items max visible
                final itemHeight = 100.0; // Approximate height per notification item
                final spacing = 11.994;
                final maxVisibleItems = 5;
                final maxHeight = (itemHeight * maxVisibleItems) + (spacing * (maxVisibleItems - 1));
                final needsScroll = state.notifications.length > maxVisibleItems;

                return SizedBox(
                  height: needsScroll ? maxHeight : null,
                  child: ListView.separated(
                    shrinkWrap: !needsScroll,
                    physics: needsScroll ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                    itemCount: state.notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 11.994),
                    itemBuilder: (context, index) => _buildNotificationItem(state.notifications[index]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 23.99),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    // Determine status based on notification status field or sentAt
    final status = notification.status ?? (notification.sentAt != null ? 'sent' : 'scheduled');
    final statusColor = status == 'sent' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C2);
    final statusTextColor = status == 'sent' ? const Color(0xFF008236) : const Color(0xFFA65F00);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Title, Description, Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF0A0A0A),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF717182),
                        height: 1.428,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: statusTextColor,
                    height: 1.333,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bottom section: Date and Recipients
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: Color(0xFF717182),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(notification.sentAt ?? notification.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF717182),
                      height: 1.333,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 12,
                    color: Color(0xFF717182),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${notification.readCount} users read',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF717182),
                      height: 1.333,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildEngagementPieChart(Map<String, dynamic> analytics) {
    final engagement = analytics['engagement'] as Map?;
    if (engagement == null) {
      return const Center(child: Text('No data'));
    }

    final opened = int.tryParse(engagement['opened'].toString()) ?? 0;
    final clicked = int.tryParse(engagement['clicked'].toString()) ?? 0;
    final dismissed = int.tryParse(engagement['dismissed'].toString()) ?? 0;
    final total = int.tryParse(engagement['total'].toString()) ?? 0;

    if (total == 0) {
      return const Center(child: Text('No engagement data'));
    }

    final openedPercent = ((opened / total) * 100).toStringAsFixed(0);
    final clickedPercent = ((clicked / total) * 100).toStringAsFixed(0);
    final dismissedPercent = ((dismissed / total) * 100).toStringAsFixed(0);

    final sections = <PieChartSectionData>[];

    sections.add(
      PieChartSectionData(
        value: opened.toDouble(),
        title: '',
        color: const Color(0xFFD4AF37),
        radius: 95,
      ),
    );

    sections.add(
      PieChartSectionData(
        value: clicked.toDouble(),
        title: '',
        color: const Color(0xFFA67C00),
        radius: 95,
      ),
    );

    sections.add(
      PieChartSectionData(
        value: dismissed.toDouble(),
        title: '',
        color: const Color(0xFFE8D7A0),
        radius: 95,
      ),
    );

    return Stack(
      children: [
        // Pie Chart - MUCH LARGER
        Positioned.fill(
          child: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                  sections: sections,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
        ),
        // Clicked label - top left (swapped with opened)
        Positioned(
          left: 5,
          top: 0,
          child: Text(
            'Clicked: $clickedPercent%',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA67C00),
            ),
          ),
        ),
        // Dismissed label - top right
        Positioned(
          right: 5,
          top: 0,
          child: Text(
            'Dismissed: $dismissedPercent%',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE8D7A0),
            ),
          ),
        ),
        // Opened label - bottom right (swapped with clicked)
        Positioned(
          right: 20,
          bottom: 5,
          child: Text(
            'Opened: $openedPercent%',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD4AF37),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(Map<String, dynamic> analytics) {
    final weekly = analytics['weekly'] as List?;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Always create 7 days of data (Mon-Sun)
    final weeklyData = List<double>.filled(7, 0.0);

    // Fill in the data from backend if available
    if (weekly != null && weekly.isNotEmpty) {
      for (var item in weekly) {
        // Backend might return data with date, we need to map it to day index
        // For now, assume the data comes in order and fill sequentially
        final index = weekly.indexOf(item);
        if (index < 7) {
          final count = int.tryParse(item['count'].toString()) ?? 0;
          weeklyData[index] = count.toDouble();
        }
      }
    }

    // Create bar groups for all 7 days
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < 7; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: weeklyData[i],
              color: const Color(0xFFD4AF37),
              width: 30,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate maxY to be a multiple of 20, minimum 80
    final maxValue = weeklyData.reduce((a, b) => a > b ? a : b);
    final calculatedMaxY = ((maxValue / 20).ceil() * 20).toDouble();
    final maxY = calculatedMaxY < 80 ? 80.0 : calculatedMaxY;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        minY: 0,
        maxY: maxY,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < 7) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[index],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textSecondary.withOpacity(0.15),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3),
              width: 1.5,
            ),
            bottom: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return Column(
      children: [
        _buildWeeklyNotificationsCard(),
        const SizedBox(height: 15.987),
        _buildUserEngagementCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildWeeklyNotificationsCard() {
    return BlocBuilder<ContentBloc, ContentState>(
      builder: (context, state) {
        final isLoading = state is! ContentLoaded || state.isLoadingAnalytics;
        final analytics = state is ContentLoaded
            ? state.analytics
            : <String, dynamic>{};

        return Container(
          width: 341.39,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(23.99),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bar_chart,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 7.98),
                    const Text(
                      'Weekly Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              // Chart data
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 23.99),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildWeeklyChart(analytics),
              ),
              const SizedBox(height: 23.99),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserEngagementCard() {
    return BlocBuilder<ContentBloc, ContentState>(
      builder: (context, state) {
        final isLoading = state is! ContentLoaded || state.isLoadingAnalytics;
        final analytics = state is ContentLoaded
            ? state.analytics
            : <String, dynamic>{};

        return Container(
          width: 341.39,
          height: 393.88,
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
          child: Stack(
            children: [
              // Header
              const Positioned(
                left: 23.99,
                top: 23.99,
                child: Text(
                  'User Engagement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
                ),
              ),
              // Pie Chart
              Positioned(
                left: 10,
                top: 60,
                right: 10,
                child: SizedBox(
                  height: 220,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildEngagementPieChart(analytics),
                ),
              ),
              // Metrics
              Positioned(
                left: 23.99,
                top: 298.14,
                right: 23.99,
                child: SizedBox(
                  height: 71.95,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: isLoading
                        ? [const Center(child: CircularProgressIndicator())]
                        : () {
                            final engagement = analytics['engagement'] as Map?;
                            final opened =
                                int.tryParse(
                                  engagement?['opened']?.toString() ?? '0',
                                ) ??
                                0;
                            final clicked =
                                int.tryParse(
                                  engagement?['clicked']?.toString() ?? '0',
                                ) ??
                                0;
                            final dismissed =
                                int.tryParse(
                                  engagement?['dismissed']?.toString() ?? '0',
                                ) ??
                                0;

                            return [
                              _buildMetricCard(
                                'Opened',
                                opened.toString(),
                                const Color(0xFFD4AF37),
                              ),
                              _buildMetricCard(
                                'Clicked',
                                clicked.toString(),
                                const Color(0xFFA67C00),
                              ),
                              _buildMetricCard(
                                'Dismissed',
                                dismissed.toString(),
                                const Color(0xFFE8D7A0),
                              ),
                            ];
                          }(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      width: 92.48,
      height: 71.95,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 11.99,
              height: 11.99,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


// Custom painter for the plus icon in Add FAQ button
class _PlusIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 1.333
      ..strokeCap = StrokeCap.round;

    // Horizontal line: x=3.33, y=8, width=9.33
    canvas.drawLine(
      const Offset(3.33, 8),
      const Offset(12.66, 8), // 3.33 + 9.33
      paint,
    );

    // Vertical line: x=8, y=3.33, height=9.33
    canvas.drawLine(
      const Offset(8, 3.33),
      const Offset(8, 12.66), // 3.33 + 9.33
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
