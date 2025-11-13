import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import 'app_constants.dart';
import 'transaction_export_platform_stub.dart'
    if (dart.library.html) 'transaction_export_platform_web.dart'
    as platform;

class TransactionExportResult {
  final bool success;
  final String message;

  const TransactionExportResult({required this.success, required this.message});
}

class TransactionExportService {
  static Future<TransactionExportResult> exportToCsv(
    List<Transaction> transactions, {
    String? filterLabel,
  }) async {
    if (transactions.isEmpty) {
      return const TransactionExportResult(
        success: false,
        message: 'No transactions to export.',
      );
    }

    final csvContent = _buildCsv(transactions);
    final filename = _buildFilename(filterLabel);
    final bytes = utf8.encode(csvContent);

    final saved = await platform.saveFile(filename, bytes);

    if (saved) {
      return const TransactionExportResult(
        success: true,
        message: 'Transactions exported successfully.',
      );
    }

    return TransactionExportResult(
      success: false,
      message: kIsWeb
          ? 'Failed to download transactions. Please try again.'
          : 'Transaction export is currently available on web builds only.',
    );
  }

  static String _buildCsv(List<Transaction> transactions) {
    final buffer = StringBuffer();
    final headers = [
      'Transaction ID',
      'Business',
      'Customer',
      'Amount (${AppConstants.currencySymbol})',
      'Type',
      'Status',
      'Date',
      'Description',
      'Campaign ID',
      'Failure Reason',
    ];
    buffer.writeln(headers.join(','));

    final amountFormatter = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    );
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (final transaction in transactions) {
      final row = [
        transaction.id,
        transaction.businessName,
        transaction.customerName,
        amountFormatter.format(transaction.amount),
        _titleCase(transaction.type),
        _titleCase(transaction.status),
        dateFormatter.format(transaction.createdAt.toLocal()),
        transaction.description,
        transaction.campaignId ?? '',
        transaction.failureReason ?? '',
      ].map(_escapeCsv).join(',');

      buffer.writeln(row);
    }

    return buffer.toString();
  }

  static String _buildFilename(String? filterLabel) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final sanitizedFilter = (filterLabel ?? 'all')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return 'transactions_${sanitizedFilter}_$timestamp.csv';
  }

  static String _escapeCsv(String value) {
    var processed = value;
    final needsQuoting =
        processed.contains(',') ||
        processed.contains('"') ||
        processed.contains('\n') ||
        processed.contains('\r');

    if (processed.contains('"')) {
      processed = processed.replaceAll('"', '""');
    }

    return needsQuoting ? '"$processed"' : processed;
  }

  static String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
