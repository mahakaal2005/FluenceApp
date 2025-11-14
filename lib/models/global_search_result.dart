import 'package:flutter/material.dart';

/// Model for global search results across the app
class GlobalSearchResult {
  final String type; // 'user', 'post', 'transaction'
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int tabIndex; // Tab index to navigate to (0=Dashboard, 1=Users, 2=Posts, 3=Payments)

  const GlobalSearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tabIndex,
  });
}

