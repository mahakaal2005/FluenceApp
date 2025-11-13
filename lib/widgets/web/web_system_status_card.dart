import 'package:flutter/material.dart';
import '../../constants/web_design_constants.dart';

class WebSystemStatusCard extends StatelessWidget {
  const WebSystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WebDesignConstants.webCardBackground,
        borderRadius: BorderRadius.circular(WebDesignConstants.radiusLarge),
        boxShadow: WebDesignConstants.cardShadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title with icon
          Row(
            children: [
              // Icon - 20x20 from Figma
              Image.asset(
                'assets/images/system_status_icon.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.info_outline,
                    size: 16.67,
                    color: WebDesignConstants.webTextPrimary,
                  );
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'System Status',
                style: TextStyle(
                  fontSize: WebDesignConstants.fontSizeMedium,
                  fontWeight: FontWeight.w400,
                  color: WebDesignConstants.webTextPrimary,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 46),
          
          // Status items in a row - evenly spaced
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStatusItem(
                  label: 'API Status',
                  status: 'Operational',
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  label: 'Database',
                  status: 'Healthy',
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  label: 'Payment Gateway',
                  status: 'Online',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String label,
    required String status,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status indicator dot - 12x12 with opacity 0.69
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: WebDesignConstants.successGreen.withOpacity(0.69),
            borderRadius: BorderRadius.circular(WebDesignConstants.radiusCircle),
          ),
        ),
        const SizedBox(width: 12),
        
        // Label and status text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: WebDesignConstants.fontSizeBody,
                fontWeight: FontWeight.w400,
                color: WebDesignConstants.webTextPrimary,
                height: 1.43,
              ),
            ),
            Text(
              status,
              style: const TextStyle(
                fontSize: WebDesignConstants.fontSizeSmall,
                fontWeight: FontWeight.w400,
                color: WebDesignConstants.webTextSecondary,
                height: 1.33,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
