import 'package:flutter/material.dart';

/// Web-specific design constants matching Figma design
class WebDesignConstants {
  // Layout dimensions
  static const double sidebarWidth = 256.0;
  static const double topBarHeight = 64.0;
  static const double contentMaxWidth = 1200.0;
  
  // Breakpoints
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
  
  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing46 = 46.0;
  
  // Border radius
  static const double radiusSmall = 14.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusCircle = 26843500.0;
  
  // Typography sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeH3 = 18.0;
  static const double fontSizeH2 = 24.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 30.0;
  static const double fontSizeStatValue = 36.0; // Stat card primary value
  
  // Icon container dimensions
  static const double iconContainerSize = 68.0;
  static const double iconContainerRadius = 16.0;
  static const double iconSize = 36.0;
  
  // Card padding
  static const double statCardPadding = 24.0;
  static const double metricCardPadding = 20.0;
  
  // Colors (Web-specific)
  static const Color webBackground = Color(0xFFF9FAFB);
  static const Color webCardBackground = Color(0xFFFFFFFF);
  static const Color webTextPrimary = Color(0xFF0A0A0A);
  static const Color webTextSecondary = Color(0xFF717182);
  static const Color webBorder = Color(0x1A000000); // rgba(0, 0, 0, 0.1)
  
  // Gradient colors
  static const Color gradientStart = Color(0xFFD4A200);
  static const Color gradientEnd = Color(0xFFC48828);
  
  // Status colors
  static const Color successGreen = Color(0xFF00C950);
  static const Color successGreenLight = Color(0xFFDCFCE7);
  static const Color successGreenDark = Color(0xFF008236);
  
  static const Color infoBlue = Color(0xFF2B7FFF);
  static const Color warningOrange = Color(0xFFFF6900);
  static const Color errorRed = Color(0xFFE7000B);
  static const Color errorRedLight = Color(0xFFFFE2E2);
  
  static const Color badgeYellow = Color(0xFFFEF9C2);
  static const Color badgeYellowText = Color(0xFFA65F00);
  
  static const Color notificationRed = Color(0xFFFB2C36);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment(0, -1),
    end: Alignment(0, 1),
    colors: [gradientStart, gradientEnd],
  );
  
  static const LinearGradient sidebarGradient = LinearGradient(
    begin: Alignment(0, -1),
    end: Alignment(0, 1),
    colors: [gradientStart, gradientEnd],
  );
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 3,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 2,
      offset: const Offset(0, 1),
      spreadRadius: -1,
    ),
  ];
  
  static List<BoxShadow> get sidebarShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];
  
  // Grid settings
  static const int statsGridColumns = 4;
  static const int quickActionsGridColumns = 2;
  static const double statsCardAspectRatio = 1.13; // 193.8 / 172
  static const double metricCardAspectRatio = 2.27; // 199.8 / 87.99
}
