import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/transaction.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/transaction_export.dart';
import '../widgets/manage_dispute_dialog.dart';
import '../blocs/transactions_bloc.dart';

class PaymentsTab extends StatefulWidget {
  const PaymentsTab({super.key});

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All Transactions';
  bool _isDownloading = false;

  final List<String> _filterOptions = [
    'All Transactions',
    'Success',
    'Pending',
    'Disputed',
    'Failed',
  ];

  @override
  void initState() {
    super.initState();
    // Load transactions when the tab is initialized
    context.read<TransactionsBloc>().add(const LoadTransactions());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 16),
            _buildSearchAndFilter(),
            const SizedBox(height: 16),
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDownloadTransactions() async {
    final bloc = context.read<TransactionsBloc>();
    final currentState = bloc.state;

    if (currentState is! TransactionsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transactions are still loading. Please try again shortly.',
          ),
        ),
      );
      return;
    }

    final transactions = currentState.filteredTransactions;

    setState(() {
      _isDownloading = true;
    });

    try {
      final result = await TransactionExportService.exportToCsv(
        transactions,
        filterLabel: _selectedFilter,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Widget _buildStatsGrid() {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        // Default values
        String totalVolume = '${AppConstants.currencySymbol} 0';
        String successRate = '0%';
        String pending = '0';
        String disputes = '0';

        if (state is TransactionsLoaded && state.analytics != null) {
          final analytics = state.analytics!;
          final volumeValue = analytics['totalVolume'];
          final volume = volumeValue is int
              ? volumeValue.toDouble()
              : (volumeValue ?? 0.0);
          totalVolume =
              '${AppConstants.currencySymbol} ${_formatAmount(volume)}';
          successRate = '${analytics['successRate'] ?? 0}%';
          pending = '${analytics['pending'] ?? 0}';
          disputes = '${analytics['disputed'] ?? 0}';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Volume',
                  totalVolume,
                  'assets/images/payment_total_volume_icon.png',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Success Rate',
                  successRate,
                  'assets/images/payment_success_rate_icon.png',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  pending,
                  'assets/images/payment_pending_icon.png',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Disputes',
                  disputes,
                  'assets/images/payment_disputes_icon.png',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, String iconPath) {
    return Container(
      height: 76,
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
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              iconPath,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              color: AppColors.white,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.error,
                  color: AppColors.white,
                  size: 16,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF717182),
                    height: 1.33,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0A0A),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<TransactionsBloc>().add(
                    SearchTransactions(value),
                  );
                },
                decoration: const InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF717182),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF717182),
                    size: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  isDense: true,
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => _showFilterMenu(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedFilter,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF717182),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    )
                  : const Icon(
                      Icons.download_outlined,
                      size: 20,
                      color: Color(0xFF717182),
                    ),
              onPressed: _isDownloading ? null : _handleDownloadTransactions,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF717182).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Filter Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ..._filterOptions.map((option) {
                final isSelected = _selectedFilter == option;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedFilter = option;
                    });
                    Navigator.pop(context);
                    // Load transactions with the selected filter
                    String? statusFilter;
                    if (option == 'All Transactions') {
                      statusFilter = null;
                    } else if (option == 'Success') {
                      statusFilter =
                          'processed'; // Backend uses 'processed' not 'success'
                    } else {
                      statusFilter = option.toLowerCase();
                    }
                    context.read<TransactionsBloc>().add(
                      LoadTransactions(statusFilter: statusFilter),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF9FAFB)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFF0A0A0A)
                                : const Color(0xFF717182),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: AppColors.buttonGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.white,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList() {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        if (state is TransactionsLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
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
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TransactionsError) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
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
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error loading transactions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF717182),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF717182),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<TransactionsBloc>().add(
                      const LoadTransactions(),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is TransactionsLoaded) {
          final filteredTransactions = state.filteredTransactions;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 16),
                if (filteredTransactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: const Color(0xFF717182).withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF717182),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try adjusting your filters or search',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF717182),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredTransactions.map((transaction) {
                    return _buildTransactionRow(transaction);
                  }),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTransactionRow(Transaction transaction) {
    final statusConfig = _getStatusConfig(transaction.transactionStatus);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusConfig['bgColor'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/payment_transaction_icon.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                color: statusConfig['iconColor'],
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.receipt,
                    color: statusConfig['iconColor'],
                    size: 20,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Business + ID column
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  transaction.businessName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF0A0A0A),
                    height: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID: ${transaction.id}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF717182),
                    height: 1.43,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Customer column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Customer',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF717182),
                    height: 1.43,
                  ),
                ),
                Text(
                  transaction.customerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF0A0A0A),
                    height: 1.43,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Amount column
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Cashback',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF717182),
                    height: 1.43,
                  ),
                ),
                Text(
                  '${AppConstants.currencySymbol} ${_formatAmount(transaction.amount)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0A0A),
                    height: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Date + Status section
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Date column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF717182),
                          height: 1.43,
                        ),
                      ),
                      Text(
                        _formatDate(transaction.createdAt),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF0A0A0A),
                          height: 1.43,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusConfig['bgColor'],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      statusConfig['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: statusConfig['textColor'],
                        height: 1.33,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Manage button - Only show for disputed transactions
          if (transaction.transactionStatus == TransactionStatus.disputed)
            Container(
              width: 99,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.1),
                  width: 0.8,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          ManageDisputeDialog(transaction: transaction),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.settings_outlined,
                        size: 16,
                        color: Color(0xFF0A0A0A),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Manage',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF0A0A0A),
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const SizedBox(
              width: 99,
            ), // Placeholder to maintain layout alignment
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.success:
        return {
          'label': 'success',
          'bgColor': const Color(0xFFDCFCE7),
          'textColor': const Color(0xFF008236),
          'iconColor': const Color(0xFF008236),
        };
      case TransactionStatus.pending:
        return {
          'label': 'pending',
          'bgColor': const Color(0xFFFEF9C2),
          'textColor': const Color(0xFFA65F00),
          'iconColor': const Color(0xFFA65F00),
        };
      case TransactionStatus.disputed:
        return {
          'label': 'disputed',
          'bgColor': const Color(0xFFFFEDD4),
          'textColor': const Color(0xFFCA3500),
          'iconColor': const Color(0xFFCA3500),
        };
      case TransactionStatus.failed:
        return {
          'label': 'failed',
          'bgColor': const Color(0xFFFFE2E2),
          'textColor': const Color(0xFFC10007),
          'iconColor': const Color(0xFFC10007),
        };
    }
  }

  String _formatAmount(double amount) {
    // Format to 2 decimal places
    final formatted = amount.toStringAsFixed(2);
    
    // Add comma separators for thousands if amount >= 1000
    if (amount >= 1000) {
      final parts = formatted.split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '00';
      
      final formattedInteger = integerPart.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      
      return '$formattedInteger.$decimalPart';
    }
    
    return formatted;
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
