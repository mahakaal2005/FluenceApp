import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/send_notification_dialog.dart';

class ContentTab extends StatefulWidget {
  const ContentTab({super.key});

  @override
  State<ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends State<ContentTab> {
  int _selectedTabIndex = 0;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I reset my password?',
      'answer': 'Navigate to Settings > Security > Reset Password',
    },
    {
      'question': 'How to verify my merchant account?',
      'answer': 'Upload business documents in Profile > Verification section',
    },
    {
      'question': 'What are the payment settlement timelines?',
      'answer': 'Settlements are processed within 2-3 business days',
    },
  ];

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'System Maintenance',
      'description': 'Scheduled maintenance on',
      'status': 'scheduled',
      'statusColor': AppColors.badgeYellow,
      'statusTextColor': AppColors.badgeYellowText,
      'date': '10/20/2025',
      'recipients': '2,450 recipients',
    },
    {
      'title': 'New Features Released',
      'description': 'Check out our latest updates!',
      'status': 'sent',
      'statusColor': AppColors.badgeGreen,
      'statusTextColor': AppColors.badgeGreenText,
      'date': '10/15/2025',
      'recipients': '12,458 recipients',
    },
  ];

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
            child: Column(
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

  Widget _buildFAQItem(Map<String, String> faq) {
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
            faq['question']!,
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
              faq['answer']!,
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
                        children: const [
                          Text(
                            'Terms_v2.3.pdf',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                          Text(
                            'Last updated: Oct 1, 2025',
                            style: TextStyle(
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
                          color: AppColors.badgeGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.badgeGreenText,
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
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) => const SendNotificationDialog(),
            );
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
            child: Column(
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

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
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
                      notification['title'],
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      notification['description'],
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
                  color: notification['statusColor'],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    notification['status'],
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: notification['statusTextColor'],
                      height: 1.333,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7.985),
          // Bottom section: Date and Recipients
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/calendar_icon.png',
                    width: 11.99,
                    height: 11.99,
                    color: AppColors.textSecondary,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.calendar_today,
                        size: 11.99,
                        color: AppColors.textSecondary,
                      );
                    },
                  ),
                  const SizedBox(width: 3.992),
                  Text(
                    notification['date'],
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
                  Image.asset(
                    'assets/images/recipients_icon.png',
                    width: 11.99,
                    height: 11.99,
                    color: AppColors.textSecondary,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.people,
                        size: 11.99,
                        color: AppColors.textSecondary,
                      );
                    },
                  ),
                  const SizedBox(width: 3.992),
                  Text(
                    notification['recipients'],
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
          // Chart placeholder
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 23.99),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Weekly Chart',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
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
          // Chart placeholder
          Positioned(
            left: 23.99,
            top: 82.15,
            right: 23.99,
            child: SizedBox(
              height: 199.99,
              child: const Center(
                child: Text(
                  'Engagement Chart',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
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
                children: [
                  _buildMetricCard('Opened', '8,540', AppColors.primary),
                  _buildMetricCard('Clicked', '3,420', AppColors.primaryDark),
                  _buildMetricCard('Dismissed', '1,280', const Color(0xFFD4AF37)),
                ],
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
