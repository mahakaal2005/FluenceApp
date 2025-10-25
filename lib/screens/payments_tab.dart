import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/transaction.dart';
import '../utils/app_colors.dart';
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

  Widget _buildStatsGrid() {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        // Default values
        String totalVolume = '₹0';
        String successRate = '0%';
        String pending = '0';
        String disputes = '0';

        if (state is TransactionsLoaded && state.analytics != null) {
          final analytics = state.analytics!;
          final volumeValue = analytics['totalVolume'];
          final volume = volumeValue is int ? volumeValue.toDouble() : (volumeValue ?? 0.0);
          totalVolume = '₹${_formatAmount(volume)}';
          successRate = '${analytics['successRate'] ?? 0}%';
          pending = '${analytics['pending'] ?? 0}';
          disputes = '${analytics['disputed'] ?? 0}';
        }

        return SizedBox(
          height: 164,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Volume', totalVolume, 'assets/images/payment_total_volume_icon.png')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Success Rate', successRate, 'assets/images/payment_success_rate_icon.png')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Pending', pending, 'assets/images/payment_pending_icon.png')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Disputes', disputes, 'assets/images/payment_disputes_icon.png')),
                ],
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<TransactionsBloc>().add(SearchTransactions(value));
              },
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF717182),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF717182),
                  size: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _showFilterMenu(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedFilter,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: const Color(0xFF717182).withValues(alpha: 0.5),
                    size: 16,
                  ),
                ],
              ),
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
                      statusFilter = 'processed'; // Backend uses 'processed' not 'success'
                    } else {
                      statusFilter = option.toLowerCase();
                    }
                    context.read<TransactionsBloc>().add(LoadTransactions(statusFilter: statusFilter));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF9FAFB) : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? const Color(0xFF0A0A0A) : const Color(0xFF717182),
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is TransactionsError) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
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
                    context.read<TransactionsBloc>().add(const LoadTransactions());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is TransactionsLoaded) {
          final filteredTransactions = state.filteredTransactions;
          
          if (filteredTransactions.isEmpty) {
            return Container(
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
            );
          }
          
          return Column(
            children: filteredTransactions.map((transaction) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTransactionCard(transaction),
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final statusConfig = _getStatusConfig(transaction.transactionStatus);
    
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
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.businessName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF0A0A0A),
                              height: 1.5,
                            ),
                          ),
                          Text(
                            'ID: ${transaction.id}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF717182),
                              height: 1.43,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${_formatAmount(transaction.amount)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A),
                        height: 1.56,
                      ),
                    ),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF717182),
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
                if (transaction.settlementDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Settlement: ${_formatDate(transaction.settlementDate!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF717182),
                      height: 1.33,
                    ),
                  ),
                ],
                if (transaction.transactionStatus == TransactionStatus.disputed) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ManageDisputeDialog(
                            transaction: transaction,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        side: BorderSide(
                          color: Colors.black.withValues(alpha: 0.1),
                          width: 1.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Manage Dispute',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF0A0A0A),
                          height: 1.43,
                        ),
                      ),
                    ),
                  ),
                ],
                if (transaction.failureReason != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFE7000B),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        transaction.failureReason!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFE7000B),
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
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
    if (amount >= 1000) {
      return amount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return amount.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
