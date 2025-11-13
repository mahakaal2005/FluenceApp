import 'package:flutter/material.dart';
import '../../constants/web_design_constants.dart';

class WebActivityFilterBar extends StatelessWidget {
  final String? entityTypeFilter;
  final String? statusFilter;
  final String? searchQuery;
  final String sortOrder;
  final Function(String?, String?) onFilterChanged;
  final Function(String?) onSearchChanged;
  final Function(String) onSortChanged;

  const WebActivityFilterBar({
    super.key,
    this.entityTypeFilter,
    this.statusFilter,
    this.searchQuery,
    this.sortOrder = 'newest',
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WebDesignConstants.webCardBackground,
          borderRadius: BorderRadius.circular(WebDesignConstants.radiusMedium),
          boxShadow: WebDesignConstants.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: TextField(
                    onChanged: (value) {
                      onSearchChanged(value.isEmpty ? null : value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search activities...',
                      hintStyle: TextStyle(
                        color: WebDesignConstants.webTextSecondary,
                        fontSize: WebDesignConstants.fontSizeBody,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: WebDesignConstants.webTextSecondary,
                      ),
                      filled: true,
                      fillColor: WebDesignConstants.webBackground,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(WebDesignConstants.radiusSmall),
                        borderSide: const BorderSide(
                          color: WebDesignConstants.webBorder,
                          width: 0.8,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(WebDesignConstants.radiusSmall),
                        borderSide: const BorderSide(
                          color: WebDesignConstants.webBorder,
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(WebDesignConstants.radiusSmall),
                        borderSide: const BorderSide(
                          color: WebDesignConstants.webBorder,
                          width: 0.8,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: WebDesignConstants.fontSizeBody,
                      color: WebDesignConstants.webTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: WebDesignConstants.webBackground,
                      borderRadius:
                          BorderRadius.circular(WebDesignConstants.radiusSmall),
                      border: Border.all(
                        color: WebDesignConstants.webBorder,
                        width: 0.8,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: sortOrder,
                      onChanged: (value) {
                        if (value != null) {
                          onSortChanged(value);
                        }
                      },
                      underline: const SizedBox.shrink(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: WebDesignConstants.webTextSecondary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text(
                            'Newest First',
                            style: TextStyle(
                              fontSize: WebDesignConstants.fontSizeBody,
                              color: WebDesignConstants.webTextPrimary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'oldest',
                          child: Text(
                            'Oldest First',
                            style: TextStyle(
                              fontSize: WebDesignConstants.fontSizeBody,
                              color: WebDesignConstants.webTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Type',
              style: TextStyle(
                fontSize: WebDesignConstants.fontSizeBody,
                color: WebDesignConstants.webTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildToggleWrap(
              buttons: [
                _ToggleButtonConfig(
                  label: 'All Types',
                  isSelected: entityTypeFilter == null,
                  onTap: () => onFilterChanged(null, statusFilter),
                ),
                _ToggleButtonConfig(
                  label: 'Posts',
                  isSelected: entityTypeFilter == 'post',
                  onTap: () => onFilterChanged('post', statusFilter),
                ),
                _ToggleButtonConfig(
                  label: 'Users',
                  isSelected: entityTypeFilter == 'user',
                  onTap: () => onFilterChanged('user', statusFilter),
                ),
                _ToggleButtonConfig(
                  label: 'Merchants',
                  isSelected: entityTypeFilter == 'merchant',
                  onTap: () => onFilterChanged('merchant', statusFilter),
                ),
                _ToggleButtonConfig(
                  label: 'Transactions',
                  isSelected: entityTypeFilter == 'transaction',
                  onTap: () => onFilterChanged('transaction', statusFilter),
                ),
                _ToggleButtonConfig(
                  label: 'Notifications',
                  isSelected: entityTypeFilter == 'notification',
                  onTap: () => onFilterChanged('notification', statusFilter),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Status',
              style: TextStyle(
                fontSize: WebDesignConstants.fontSizeBody,
                color: WebDesignConstants.webTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildToggleWrap(
              buttons: [
                _ToggleButtonConfig(
                  label: 'All Status',
                  isSelected: statusFilter == null,
                  onTap: () => onFilterChanged(entityTypeFilter, null),
                ),
                _ToggleButtonConfig(
                  label: 'Pending',
                  isSelected: statusFilter == 'pending',
                  onTap: () => onFilterChanged(entityTypeFilter, 'pending'),
                ),
                _ToggleButtonConfig(
                  label: 'Approved',
                  isSelected: statusFilter == 'approved',
                  onTap: () => onFilterChanged(entityTypeFilter, 'approved'),
                ),
                _ToggleButtonConfig(
                  label: 'Rejected',
                  isSelected: statusFilter == 'rejected',
                  onTap: () => onFilterChanged(entityTypeFilter, 'rejected'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleWrap({required List<_ToggleButtonConfig> buttons}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: buttons
          .map(
            (config) => GestureDetector(
              onTap: config.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: config.isSelected
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFD4A200), Color(0xFFC48828)],
                        )
                      : null,
                  color: config.isSelected ? null : const Color(0xFFF6F6F9),
                  borderRadius:
                      BorderRadius.circular(WebDesignConstants.radiusSmall),
                  border: config.isSelected
                      ? null
                      : Border.all(
                          color: const Color(0x26000000),
                          width: 0.8,
                        ),
                  boxShadow: config.isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  config.label,
                  style: TextStyle(
                    fontSize: WebDesignConstants.fontSizeBody,
                    fontWeight: FontWeight.w500,
                    color: config.isSelected
                        ? Colors.white
                        : WebDesignConstants.webTextPrimary,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ToggleButtonConfig {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  _ToggleButtonConfig({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
}
