import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/notification_recipients_bloc.dart';
import '../../constants/web_design_constants.dart';
import '../../models/faq.dart';
import '../../models/notification.dart';
import '../../models/terms.dart';
import '../../repositories/content_repository.dart';
import '../../repositories/notifications_repository.dart';
import '../../widgets/faq/add_faq_dialog.dart';
import '../../widgets/faq/delete_confirmation_dialog.dart';
import '../../widgets/faq/edit_faq_dialog.dart';
import '../../widgets/send_notification_dialog.dart';
import '../../widgets/terms/preview_terms_dialog.dart';
import '../../widgets/terms/upload_terms_dialog.dart';

class WebContentScreen extends StatefulWidget {
  final int initialTabIndex;
  final VoidCallback? onNotificationsViewed;
  
  const WebContentScreen({
    super.key, 
    this.initialTabIndex = 0,
    this.onNotificationsViewed,
  });

  @override
  State<WebContentScreen> createState() => _WebContentScreenState();
}

class _WebContentScreenState extends State<WebContentScreen> {
  late int _selectedTabIndex;
  final ContentRepository _contentRepository = ContentRepository();
  final NotificationsRepository _notificationsRepository =
      NotificationsRepository();

  List<FAQ> _faqs = [];
  bool _isLoadingFAQs = false;
  Terms? _terms;
  bool _isLoadingTerms = false;
  List<NotificationModel> _notifications = [];
  bool _isLoadingNotifications = false;
  Map<String, dynamic> _analytics = {};
  bool _isLoadingAnalytics = false;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _loadFAQs();
    _loadTerms();
    _loadNotifications();
    _loadAnalytics();
  }

  @override
  void didUpdateWidget(WebContentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected tab index when initialTabIndex changes
    if (widget.initialTabIndex != oldWidget.initialTabIndex) {
      setState(() {
        _selectedTabIndex = widget.initialTabIndex;
      });
      // If switching to Notifications tab, reload notifications
      // This will trigger markAllAsOpened() and update the badge count
      if (widget.initialTabIndex == 1) {
        _loadNotifications();
      }
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoadingNotifications = true);
    try {
      print('📬 [WEB] Loading notifications...');

      // Fetch both sent and received notifications
      final sentNotificationsFuture = _notificationsRepository
          .getSentNotificationsWithStats(limit: 10);
      final receivedNotificationsFuture = _notificationsRepository
          .getNotifications(limit: 10);

      final results = await Future.wait([
        sentNotificationsFuture,
        receivedNotificationsFuture,
      ]);
      final sentNotifications = results[0] as List<Map<String, dynamic>>;
      final receivedNotifications = results[1] as List<NotificationModel>;

      print('📤 [WEB] Sent notifications: ${sentNotifications.length}');
      print('📥 [WEB] Received notifications: ${receivedNotifications.length}');

      // Mark all admin notifications as opened/viewed when admin views the list
      // Only marks notifications RECEIVED by admin (not sent by admin)
      // This updates the badge count to show only truly unseen admin notifications
      try {
        print('🔄 [WEB] Calling markAllAsOpened()...');
        await _notificationsRepository.markAllAsOpened();
        print('✅ [WEB] Marked all admin notifications as opened');
        // Wait a bit to ensure database update has propagated
        await Future.delayed(const Duration(milliseconds: 200));
        // Notify parent to refresh badge count
        print('🔄 [WEB] Calling onNotificationsViewed callback...');
        widget.onNotificationsViewed?.call();
        print('✅ [WEB] Callback called');
      } catch (e) {
        print('⚠️ [WEB] Failed to mark admin notifications as opened: $e');
        // Don't fail the entire load if this fails
      }

      // Convert sent notifications to NotificationModel
      final sentNotificationModels = sentNotifications.map((notifMap) {
        return NotificationModel(
          id: notifMap['id'] as String,
          type: notifMap['type'] as String? ?? 'in_app',
          title: notifMap['subject'] as String,
          message: notifMap['message'] as String,
          status: 'sent',
          readAt: null,
          createdAt: DateTime.parse(notifMap['created_at'] as String),
          sentAt: notifMap['sent_at'] != null
              ? DateTime.parse(notifMap['sent_at'] as String)
              : null,
          metadata: null,
          readCountFromBackend: notifMap['total_read'] as int?,
        );
      }).toList();

      // Merge and sort
      final allNotifications = <NotificationModel>[
        ...sentNotificationModels,
        ...receivedNotifications,
      ];
      allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('✅ [WEB] Total notifications: ${allNotifications.length}');

      if (mounted) {
        setState(() {
          _notifications = allNotifications.take(10).toList();
          _isLoadingNotifications = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ [WEB] Failed to load notifications: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoadingNotifications = false);
      }
    }
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoadingAnalytics = true);
    try {
      final analytics = await _notificationsRepository.getAnalytics();
      if (mounted) {
        setState(() {
          _analytics = analytics;
          _isLoadingAnalytics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAnalytics = false);
      }
      print('Failed to load analytics: $e');
    }
  }

  Future<void> _loadFAQs() async {
    setState(() => _isLoadingFAQs = true);
    try {
      final faqs = await _contentRepository.getFAQs();
      if (mounted) {
        setState(() {
          _faqs = faqs;
          _isLoadingFAQs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFAQs = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load FAQs: $e')));
      }
    }
  }

  Future<void> _loadTerms() async {
    setState(() => _isLoadingTerms = true);
    try {
      final terms = await _contentRepository.getTerms();
      if (mounted) {
        setState(() {
          _terms = terms;
          _isLoadingTerms = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTerms = false);
      }
    }
  }

  @override
  void dispose() {
    _contentRepository.dispose();
    _notificationsRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          _buildTabs(),
          const SizedBox(height: 24),

          // Tab Content
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFECECF0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTab('FAQs', 0),
          _buildTab('Notifications', 1),
          _buildTab('Analytics', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedTabIndex = index);
          // When switching to Notifications tab, reload notifications
          // This will trigger markAllAsOpened() and update the badge count
          if (index == 1) {
            _loadNotifications();
          }
        },
        borderRadius: BorderRadius.circular(20),
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
    switch (_selectedTabIndex) {
      case 0:
        return _buildFAQsContent();
      case 1:
        return _buildNotificationsContent();
      case 2:
        return _buildAnalyticsContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildFAQsContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Manage FAQs Section
        Expanded(flex: 2, child: _buildManageFAQsCard()),
        const SizedBox(width: 24),

        // Terms & Conditions Section
        Expanded(flex: 1, child: _buildTermsCard()),
      ],
    );
  }

  Widget _buildManageFAQsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/faq_icon.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.help_outline,
                        color: WebDesignConstants.gradientStart,
                        size: 20,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Manage FAQs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () async {
                  final result = await showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (context) => const AddFAQDialog(),
                  );

                  if (result == true && mounted) {
                    _loadFAQs();
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
                          child: CustomPaint(painter: _PlusIconPainter()),
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
          const SizedBox(height: 24),

          // FAQ List
          if (_isLoadingFAQs)
            const Center(child: CircularProgressIndicator())
          else if (_faqs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No FAQs available',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            )
          else
            SizedBox(
              height: _faqs.length > 5 ? 600 : null, // Max height for 5 items
              child: ListView.builder(
                shrinkWrap: _faqs.length <= 5,
                physics: _faqs.length > 5
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: _faqs.length,
                itemBuilder: (context, index) => _buildFAQItem(_faqs[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQ faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Badge
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
              // Edit and Delete Icons
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
                        _loadFAQs();
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
                        _loadFAQs();
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
          const SizedBox(height: 12),
          Text(
            faq.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            faq.answer,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: WebDesignConstants.gradientStart,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Terms File
          if (_isLoadingTerms)
            const Center(child: CircularProgressIndicator())
          else if (_terms == null)
            const Text(
              'No terms available',
              style: TextStyle(color: Color(0xFF6B7280)),
            )
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terms_v${_terms!.version}.pdf',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last updated: ${_formatDate(_terms!.effectiveDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '2.4 MB',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _terms!.isActive
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _terms!.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _terms!.isActive
                                ? const Color(0xFF008236)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Upload Button
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () async {
                      final result = await showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (context) => const UploadTermsDialog(),
                      );

                      if (result == true && mounted) {
                        _loadTerms();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.upload_outlined,
                            size: 18,
                            color: Color(0xFF111827),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Upload New Version',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Preview Button
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: _terms == null
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              builder: (context) =>
                                  PreviewTermsDialog(terms: _terms!),
                            );
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.visibility_outlined,
                            size: 18,
                            color: Color(0xFF111827),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Preview Current Version',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Send notifications to all users or specific groups',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            InkWell(
              onTap: () async {
                final result = await showDialog(
                  context: context,
                  barrierColor: Colors.transparent,
                  builder: (dialogContext) => BlocProvider(
                    create: (context) => NotificationRecipientsBloc(),
                    child: const SendNotificationDialog(),
                  ),
                );

                if (result == true && mounted) {
                  _loadNotifications();
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFD4A200), Color(0xFFC48828)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.notifications,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
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
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Stats Cards Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Sent',
                value: _analytics['totalSent']?.toString() ?? '0',
                icon: Icons.send,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Open Rate',
                value: _analytics['openRate'] != null
                    ? '${_analytics['openRate']}%'
                    : '0%',
                icon: Icons.visibility_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Scheduled',
                value: _analytics['scheduled']?.toString() ?? '0',
                icon: Icons.calendar_today,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Recent Notifications Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),

              if (_isLoadingNotifications)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_notifications.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No notifications yet',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: _notifications.length > 5
                      ? 550
                      : null, // Max height for 5 items
                  child: ListView.separated(
                    shrinkWrap: _notifications.length <= 5,
                    physics: _notifications.length > 5
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildNotificationCard(_notifications[index]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    // Determine status based on notification status field or sentAt
    final status =
        notification.status ??
        (notification.sentAt != null ? 'sent' : 'scheduled');
    final statusColor = status == 'sent'
        ? const Color(0xFF008236)
        : const Color(0xFFA65F00);
    final statusBgColor = status == 'sent'
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEF9C2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: statusColor,
                    height: 1.333,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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

  Widget _buildAnalyticsContent() {
    return SizedBox(
      height: 400,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Weekly Notifications Chart
          Expanded(flex: 2, child: _buildWeeklyNotificationsCard()),
          const SizedBox(width: 24),
          // User Engagement Chart
          Expanded(flex: 1, child: _buildUserEngagementCard()),
        ],
      ),
    );
  }

  Widget _buildWeeklyNotificationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: WebDesignConstants.gradientStart,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Weekly Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart
          Expanded(
            child: _isLoadingAnalytics
                ? const Center(child: CircularProgressIndicator())
                : _buildWeeklyChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final weekly = _analytics['weekly'] as List?;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Always create 7 days of data (Mon-Sun)
    final weeklyData = List<double>.filled(7, 0.0);

    // Calculate current week boundaries (Monday to Sunday)
    final now = DateTime.now();
    // Get Monday of current week (weekday 1 = Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    // Get Sunday of current week (6 days after Monday)
    final endOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + 6, 23, 59, 59);

    print('📅 [WEEKLY CHART] Current week: ${startOfWeekDate.toString().split(' ')[0]} to ${endOfWeekDate.toString().split(' ')[0]}');
    print('   Today is: ${now.toString().split(' ')[0]} (${days[now.weekday - 1]})');

    // Fill in the data from backend if available
    if (weekly != null && weekly.isNotEmpty) {
      for (var item in weekly) {
        try {
          // Parse the date from backend (format: 'YYYY-MM-DD')
          final date = DateTime.parse(item['date'].toString());
          
          // FILTER: Only include dates from current week (Monday to Sunday)
          // Use date comparison at day level (ignore time)
          final dateOnly = DateTime(date.year, date.month, date.day);
          if (dateOnly.isBefore(startOfWeekDate) || dateOnly.isAfter(endOfWeekDate)) {
            print('   ⏭️  Skipping ${item['date']} (not in current week: ${startOfWeekDate.toString().split(' ')[0]} to ${endOfWeekDate.toString().split(' ')[0]})');
            continue; // Skip dates outside current week
          }
          
          // Get day of week: 1=Mon, 2=Tue, ..., 7=Sun
          final dayOfWeek = date.weekday;
          // Convert to array index: 0=Mon, 1=Tue, ..., 6=Sun
          final index = dayOfWeek - 1;
          
          final count = int.tryParse(item['count'].toString()) ?? 0;
          weeklyData[index] = count.toDouble();
          
          print('   ✓ ${days[index]}: $count notifications');
        } catch (e) {
          // Skip items with invalid dates
          print('❌ Error parsing weekly notification date: $e');
        }
      }
    }
    
    print('📊 [WEEKLY CHART] Final data: $weeklyData');

    // Create bar groups for all 7 days
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < 7; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: weeklyData[i],
              color: WebDesignConstants.gradientStart,
              width: 40,
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
                      fontSize: 12,
                      color: Color(0xFF6B7280),
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
                        fontSize: 12,
                        color: Color(0xFF6B7280),
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
            return FlLine(color: const Color(0xFFE5E7EB), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildUserEngagementCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'User Engagement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 24),
          // Pie Chart
          Expanded(
            child: _isLoadingAnalytics
                ? const Center(child: CircularProgressIndicator())
                : _buildEngagementPieChart(),
          ),
          const SizedBox(height: 24),
          // Metrics
          _buildEngagementMetrics(),
        ],
      ),
    );
  }

  Widget _buildEngagementPieChart() {
    final engagement = _analytics['engagement'] as Map?;
    if (engagement == null) {
      return const Center(
        child: Text(
          'No engagement data',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    final opened = int.tryParse(engagement['opened'].toString()) ?? 0;
    final clicked = int.tryParse(engagement['clicked'].toString()) ?? 0;
    final dismissed = int.tryParse(engagement['dismissed'].toString()) ?? 0;
    final total = int.tryParse(engagement['total'].toString()) ?? 0;

    if (total == 0) {
      return const Center(
        child: Text(
          'No engagement data',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    final sections = <PieChartSectionData>[
      PieChartSectionData(
        value: opened.toDouble(),
        title: '${((opened / total) * 100).toStringAsFixed(0)}%',
        color: WebDesignConstants.gradientStart,
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: clicked.toDouble(),
        title: '${((clicked / total) * 100).toStringAsFixed(0)}%',
        color: const Color(0xFFA67C00),
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: dismissed.toDouble(),
        title: '${((dismissed / total) * 100).toStringAsFixed(0)}%',
        color: const Color(0xFFE8D7A0),
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 0,
        sections: sections,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildEngagementMetrics() {
    final engagement = _analytics['engagement'] as Map?;
    final opened = int.tryParse(engagement?['opened']?.toString() ?? '0') ?? 0;
    final clicked =
        int.tryParse(engagement?['clicked']?.toString() ?? '0') ?? 0;
    final dismissed =
        int.tryParse(engagement?['dismissed']?.toString() ?? '0') ?? 0;

    return Column(
      children: [
        _buildMetricRow('Opened', opened, WebDesignConstants.gradientStart),
        const SizedBox(height: 12),
        _buildMetricRow('Clicked', clicked, const Color(0xFFA67C00)),
        const SizedBox(height: 12),
        _buildMetricRow('Dismissed', dismissed, const Color(0xFFE8D7A0)),
      ],
    );
  }

  Widget _buildMetricRow(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ],
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

Widget _buildStatCard({
  required String title,
  required String value,
  required IconData icon,
}) {
  return Container(
    height: 108,
    padding: const EdgeInsets.only(left: 24, top: 24, bottom: 24, right: 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF717182),
                  height: 1.4285714285714286,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF0A0A0A),
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD4A200), Color(0xFFC48828)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 24, color: Colors.white),
        ),
      ],
    ),
  );
}
