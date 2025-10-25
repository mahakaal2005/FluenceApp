import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/transaction.dart';
import '../repositories/transactions_repository.dart';
import '../blocs/transactions_bloc.dart';
import '../utils/app_colors.dart';
import 'dispute_resolved_dialog.dart';

class ManageDisputeDialog extends StatefulWidget {
  final Transaction transaction;

  const ManageDisputeDialog({
    super.key,
    required this.transaction,
  });

  @override
  State<ManageDisputeDialog> createState() => _ManageDisputeDialogState();
}

class _ManageDisputeDialogState extends State<ManageDisputeDialog> {
  final TextEditingController _notesController = TextEditingController();
  bool _isResolving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}, $hour:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')} $period';
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

  Map<String, dynamic> _getStatusConfig(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.disputed:
        return {
          'label': 'disputed',
          'bgColor': const Color(0xFFFFEDD4),
          'textColor': const Color(0xFFCA3500),
        };
      default:
        return {
          'label': 'unknown',
          'bgColor': const Color(0xFFF3F3F5),
          'textColor': const Color(0xFF717182),
        };
    }
  }

  Future<void> _resolveDispute() async {
    final resolution = _notesController.text.trim();
    
    if (resolution.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter resolution notes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isResolving = true);
    
    try {
      // Get dispute for this transaction
      final repository = TransactionsRepository();
      final disputes = await repository.getDisputes();
      final dispute = disputes.firstWhere(
        (d) => d.transactionId == widget.transaction.id && d.status == 'open',
        orElse: () => throw Exception('No open dispute found for this transaction'),
      );
      
      // Resolve the dispute
      await repository.resolveDispute(dispute.id, resolution);
      
      if (mounted) {
        // Close the current dialog
        Navigator.pop(context);
        
        // Refresh transactions with current filter preserved
        final bloc = context.read<TransactionsBloc>();
        final currentState = bloc.state;
        if (currentState is TransactionsLoaded) {
          // Preserve the current filter
          bloc.add(LoadTransactions(
            statusFilter: currentState.currentFilter,
          ));
        } else {
          // Fallback to no filter
          bloc.add(const LoadTransactions());
        }
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => DisputeResolvedDialog(
            transaction: widget.transaction,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResolving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resolve dispute: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(widget.transaction.transactionStatus);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.1),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A),
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(2),
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
                ],
              ),
            ),

              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(
                  25,
                  0,
                  25,
                  25 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction ID and Status Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Transaction ID',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF717182),
                                height: 1.43,
                              ),
                            ),
                            Text(
                              widget.transaction.id,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF0A0A0A),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF717182),
                                height: 1.43,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Merchant
                  const Text(
                    'Merchant',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF717182),
                      height: 1.43,
                    ),
                  ),
                  Text(
                    widget.transaction.businessName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0A0A0A),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  const Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF717182),
                      height: 1.43,
                    ),
                  ),
                  Text(
                    '₹${_formatAmount(widget.transaction.amount)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0A0A),
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transaction Date
                  const Text(
                    'Transaction Date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF717182),
                      height: 1.43,
                    ),
                  ),
                  Text(
                    _formatDate(widget.transaction.createdAt),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0A0A0A),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dispute Resolution Notes
                  Container(
                    padding: const EdgeInsets.only(top: 9),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.black.withValues(alpha: 0.1),
                          width: 1.1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dispute Resolution Notes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF717182),
                            height: 1.43,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F3F5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _notesController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Enter resolution notes...',
                              hintStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF717182),
                                height: 1.5,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF0A0A0A),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resolve Button
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _isResolving ? null : _resolveDispute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: _isResolving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            )
                          : const Text(
                              'Resolve Dispute',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.white,
                                height: 1.43,
                              ),
                            ),
                    ),
                  ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
