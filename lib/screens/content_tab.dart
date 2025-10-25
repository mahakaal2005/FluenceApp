import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_colors.dart';
import '../widgets/send_notification_dialog.dart';
import '../repositories/notifications_repository.dart';
import '../repositories/content_repository.dart';
import '../models/notification.dart';
import '../models/faq.dart';
import '../models/terms.dart';

class ContentTab extends StatefulWidget {
  final int initialTabIndex;
  
  const ContentTab({super.key, this.initialTabIndex = 0});

  @override
  State<ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends State<ContentTab> {
  late int _selectedTabIndex;
  final NotificationsRepository _notificationsRepository = NotificationsRepository();
  final ContentRepository _contentRepository = ContentRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoadingNotifications = false;
  Map<String, dynamic> _analytics = {};
  bool _isLoadingAnalytics = false;
  
  // FAQ and Terms data
  List<FAQ> _faqs = [];
  bool _isLoadingFAQs = false;
  Terms? _terms;
  bool _isLoadingTerms = false;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _loadNotifications();
    _loadAnalytics();
    _loadFAQs();
    _loadTerms();
  }

  Future<void> _loadAnalytics() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingAnalytics = true;
    });

    try {
      final analytics = await _notificationsRepository.getAnalytics();
      print('📊 Analytics loaded: $analytics');
      
      if (!mounted) return;
      
      setState(() {
        _analytics = analytics;
        _isLoadingAnalytics = false;
      });
    } catch (e) {
      print('❌ Analytics error: $e');
      
      if (!mounted) return;
      
      setState(() {
        _isLoadingAnalytics = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load analytics: $e')),
        );
      }
    }
  }

  Future<void> _loadFAQs() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingFAQs = true;
    });

    try {
      final faqs = await _contentRepository.getFAQs();
      
      if (!mounted) return;
      
      setState(() {
        _faqs = faqs;
        _isLoadingFAQs = false;
      });
    } catch (e) {
      print('❌ FAQs error: $e');
      
      if (!mounted) return;
      
      setState(() {
        _isLoadingFAQs = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load FAQs: $e')),
        );
      }
    }
  }

  Future<void> _loadTerms() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingTerms = true;
    });

    try {
      final terms = await _contentRepository.getTerms();
      
      if (!mounted) return;
      setState(() {
        _terms = terms;
        _isLoadingTerms = false;
      });
    } catch (e) {
      print('❌ Terms error: $e');
      
      if (!mounted) return;
      
      setState(() {
        _isLoadingTerms = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load Terms: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _notificationsRepository.dispose();
    _contentRepository.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingNotifications = true;
    });

    try {
      final notifications = await _notificationsRepository.getNotifications(
        page: 1,
        limit: 10,
      );
      
      if (!mounted) return;
      
      setState(() {
        _notifications = notifications;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoadingNotifications = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: $e')),
        );
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
      width: 341.39,
      height: 35.98,
      decoration: BoxDecoration(
        color: AppColors.tabBackground,
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
        },
        child: Container(
          margin: const EdgeInsets.all(2.99),
          height: 29.17,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            border: Border.all(
              color: Colors.transparent,
              width: 1.1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
                height: 1.428,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    const SizedBox(width: 7.98),
                    const Text(
                      'Manage FAQs',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 70.37,
                  height: 31.99,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/edit_icon.png',
                        width: 15.99,
                        height: 15.99,
                        color: AppColors.white,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.edit,
                            size: 15.99,
                            color: AppColors.white,
                          );
                        },
                      ),
                      const SizedBox(width: 9.98),
                      const Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white,
                          height: 1.428,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // FAQ Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.989),
            child: _isLoadingFAQs
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _faqs.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No FAQs available',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (int i = 0; i < _faqs.length; i++) ...[
                            _buildFAQItem(_faqs[i]),
                            if (i < _faqs.length - 1) const SizedBox(height: 11.994),
                          ],
                        ],
                      ),
          ),
          const SizedBox(height: 23.99),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQ faq) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(11.994, 11.994, 11.994, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faq.question,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 3.992),
          Container(
            height: 39.99,
            alignment: Alignment.topLeft,
            child: Text(
              faq.answer,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.428,
              ),
            ),
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
                    fontFamily: 'Arial',
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
            child: Column(
              children: [
                _isLoadingTerms
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _terms == null
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No Terms & Conditions available',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        : Container(
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
                                      'Terms_v${_terms!.version}.pdf',
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textPrimary,
                                        height: 1.5,
                                      ),
                                    ),
                                    Text(
                                      'Last updated: ${_formatDate(_terms!.effectiveDate)}',
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
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
                                    color: _terms!.isActive ? AppColors.badgeGreen : Colors.grey,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _terms!.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: _terms!.isActive ? AppColors.badgeGreenText : Colors.white,
                                        height: 1.333,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                const SizedBox(height: 11.994),
                Container(
                  height: 35.98,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1),
                      width: 1.1,
                    ),
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
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                          height: 1.428,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    return Container(
      width: 362.32,
      height: 35.98,
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) => const SendNotificationDialog(),
            );
            
            if (result == true && mounted) {
              _loadNotifications();
              _loadAnalytics();
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/notification_bell.png',
                width: 15.99,
                height: 15.99,
                color: AppColors.white,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.notifications,
                    size: 15.99,
                    color: AppColors.white,
                  );
                },
              ),
              const SizedBox(width: 16),
              const Text(
                'Send New Notification',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white,
                  height: 1.428,
                ),
              ),
            ],
          ),
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
                fontFamily: 'Arial',
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
            child: _isLoadingNotifications
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _notifications.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (int i = 0; i < _notifications.length; i++) ...[
                            _buildNotificationItem(_notifications[i]),
                            if (i < _notifications.length - 1) const SizedBox(height: 11.994),
                          ],
                        ],
                      ),
          ),
          const SizedBox(height: 23.99),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final statusColor = notification.isRead ? AppColors.badgeGreen : AppColors.badgeYellow;
    final statusTextColor = notification.isRead ? AppColors.badgeGreenText : AppColors.badgeYellowText;
    final status = notification.isRead ? 'read' : 'unread';
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(15.987, 15.987, 15.987, 0),
      child: Column(
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
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.428,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7.985),
              Container(
                height: 19.98,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: statusTextColor,
                      height: 1.333,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7.985),
          // Bottom section: Date and Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 11.99,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 3.992),
                  Text(
                    _formatDate(notification.createdAt),
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.333,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.label,
                    size: 11.99,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 3.992),
                  Text(
                    notification.type,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.333,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15.987),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildEngagementPieChart() {
    final engagement = _analytics['engagement'] as Map?;
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
    
    sections.add(PieChartSectionData(
      value: opened.toDouble(),
      title: '',
      color: const Color(0xFFD4AF37),
      radius: 95,
    ));
    
    sections.add(PieChartSectionData(
      value: clicked.toDouble(),
      title: '',
      color: const Color(0xFFA67C00),
      radius: 95,
    ));
    
    sections.add(PieChartSectionData(
      value: dismissed.toDouble(),
      title: '',
      color: const Color(0xFFE8D7A0),
      radius: 95,
    ));

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
              fontFamily: 'Arial',
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
              fontFamily: 'Arial',
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
              fontFamily: 'Arial',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD4AF37),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    final weekly = _analytics['weekly'] as List?;
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
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                    fontFamily: 'Arial',
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
            child: _isLoadingAnalytics
                ? const Center(child: CircularProgressIndicator())
                : _buildWeeklyChart(),
          ),
          const SizedBox(height: 23.99),
        ],
      ),
    );
  }

  Widget _buildUserEngagementCard() {
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
                fontFamily: 'Arial',
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
              child: _isLoadingAnalytics
                  ? const Center(child: CircularProgressIndicator())
                  : _buildEngagementPieChart(),
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
                children: _isLoadingAnalytics
                    ? [
                        const Center(child: CircularProgressIndicator()),
                      ]
                    : () {
                        final engagement = _analytics['engagement'] as Map?;
                        final opened = int.tryParse(engagement?['opened']?.toString() ?? '0') ?? 0;
                        final clicked = int.tryParse(engagement?['clicked']?.toString() ?? '0') ?? 0;
                        final dismissed = int.tryParse(engagement?['dismissed']?.toString() ?? '0') ?? 0;
                        
                        return [
                          _buildMetricCard('Opened', opened.toString(), const Color(0xFFD4AF37)),
                          _buildMetricCard('Clicked', clicked.toString(), const Color(0xFFA67C00)),
                          _buildMetricCard('Dismissed', dismissed.toString(), const Color(0xFFE8D7A0)),
                        ];
                      }(),
              ),
            ),
          ),
        ],
      ),
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
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Arial',
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
                fontFamily: 'Arial',
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
