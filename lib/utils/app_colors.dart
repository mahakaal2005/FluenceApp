import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFD4A200); // Gold gradient start
  static const Color primaryDark = Color(0xFFC48828); // Gold gradient end
  
  // Background colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF717182);
  
  // Badge colors
  static const Color badgeGreen = Color(0xFFDCFCE7);
  static const Color badgeGreenText = Color(0xFF008236);
  static const Color badgeGray = Color(0xFFF3F4F6);
  static const Color badgeGrayText = Color(0xFF364153);
  static const Color badgeRed = Color(0xFFFF0000); // Changed to proper red for notification badge
  static const Color badgeRedText = Color(0xFFFFFFFF); // Changed to white for better contrast
  static const Color badgeYellow = Color(0xFFFEF9C2);
  static const Color badgeYellowText = Color(0xFFA65F00);
  static const Color badgeOrange = Color(0xFFFFEDD4);
  static const Color badgeOrangeText = Color(0xFFCA3500);
  static const Color badgeTabYellow = Color(0xFFF0B100);
  
  // Button colors
  static const Color buttonApprove = Color(0xFF00A63E);
  static const Color buttonReject = Color(0xFFD4183D);
  
  // Tab colors
  static const Color tabBackground = Color(0xFFECECF0);
  
  // Activity icon backgrounds
  static const Color activityYellow = Color(0xFFFEF9C2);
  static const Color activityYellowBorder = Color(0xFFD08700);
  static const Color activityRed = Color(0xFFFFE2E2);
  static const Color activityRedBorder = Color(0xFFE7000B);
  static const Color activityGreen = Color(0xFFDCFCE7);
  static const Color activityGreenBorder = Color(0xFF00A63E);
  
  // Border colors
  static const Color border = Color(0x1A000000); // rgba(0, 0, 0, 0.1)
  
  // Alert colors
  static const Color alertErrorBackground = Color(0xFFFEF2F2);
  static const Color alertErrorBorder = Color(0xFFFFC9C9);
  static const Color alertErrorText = Color(0xFF9F0712);
  static const Color alertWarningBackground = Color(0xFFFEFCE8);
  static const Color alertWarningBorder = Color(0xFFFFF085);
  static const Color alertWarningText = Color(0xFF894B00);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment(0, -1),
    end: Alignment(0, 1),
    colors: [primary, primaryDark],
  );
}
