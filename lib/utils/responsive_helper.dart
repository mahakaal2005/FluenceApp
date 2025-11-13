import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/web_design_constants.dart';

/// Helper class for responsive design decisions
class ResponsiveHelper {
  /// Check if current platform is web
  static bool get isWeb => kIsWeb;
  
  /// Check if screen width is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < WebDesignConstants.mobileBreakpoint;
  }
  
  /// Check if screen width is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= WebDesignConstants.mobileBreakpoint && 
           width < WebDesignConstants.tabletBreakpoint;
  }
  
  /// Check if screen width is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= WebDesignConstants.tabletBreakpoint;
  }
  
  /// Check if we should show web layout (web platform + desktop size)
  static bool shouldShowWebLayout(BuildContext context) {
    return isWeb && isDesktop(context);
  }
  
  /// Check if we should show mobile layout
  static bool shouldShowMobileLayout(BuildContext context) {
    return !isWeb || isMobile(context);
  }
  
  /// Get responsive value based on screen size
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
  
  /// Get number of grid columns based on screen size
  static int getGridColumns(BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 4,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  /// Get horizontal padding based on screen size
  static double getHorizontalPadding(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 24.0,
    );
  }
}
