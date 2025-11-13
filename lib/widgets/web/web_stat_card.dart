import 'package:flutter/material.dart';
import '../../constants/web_design_constants.dart';

class WebStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final String iconPath;
  
  const WebStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on card width
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        
        // Scale icon based on card size
        final iconContainerSize = (cardWidth * 0.35).clamp(48.0, 68.0);
        final iconSize = iconContainerSize * 0.53; // ~36px at 68px container
        final iconPadding = iconContainerSize * 0.235; // ~16px at 68px container
        
        // Scale padding based on card size
        final cardPadding = (cardWidth * 0.12).clamp(16.0, 24.0);
        
        // Scale font sizes
        final titleFontSize = (cardWidth * 0.072).clamp(12.0, 14.0);
        final valueFontSize = (cardWidth * 0.186).clamp(24.0, 36.0);
        final badgeFontSize = (cardWidth * 0.062).clamp(10.0, 12.0);
        
        // Strip currency symbols when card is narrow to prevent overlap
        // Threshold increased to handle longer currency codes like "AED"
        final isNarrow = cardWidth < 180;
        String displayValue = value;
        
        if (isNarrow) {
          // Remove currency codes (3-letter codes like AED, USD, etc.)
          displayValue = displayValue.replaceAll(RegExp(r'^[A-Z]{3}\s*'), '');
          // Remove currency symbols
          displayValue = displayValue.replaceAll(RegExp(r'^[₹\$€£¥₩]\s*'), '');
          displayValue = displayValue.trim();
        }
        
        // Debug output
        debugPrint('Card width: $cardWidth, isNarrow: $isNarrow, original: $value, display: $displayValue');
        
        return Container(
          decoration: BoxDecoration(
            color: WebDesignConstants.webCardBackground,
            borderRadius: BorderRadius.circular(WebDesignConstants.radiusLarge),
            boxShadow: WebDesignConstants.cardShadow,
          ),
          padding: EdgeInsets.all(cardPadding),
          child: Stack(
            children: [
              // Left side content - use Flexible widgets only
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title - increased flex to prevent clipping
                  Flexible(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(right: iconContainerSize + 4),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w400,
                            color: WebDesignConstants.webTextSecondary,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  
                  // Flexible spacer - reduced
                  const Spacer(flex: 1),
                  
                  // Value - flexible with conditional currency display
                  Flexible(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          displayValue,
                          style: TextStyle(
                            fontSize: valueFontSize,
                            fontWeight: FontWeight.w600,
                            color: WebDesignConstants.webTextPrimary,
                            height: 1.0,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  
                  // Small flexible gap
                  const Spacer(flex: 1),
                  
                  // Badge - flexible
                  Flexible(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: cardPadding * 0.33,
                            vertical: cardPadding * 0.08,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(WebDesignConstants.radiusSmall),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: badgeFontSize,
                              fontWeight: FontWeight.w500,
                              color: badgeTextColor,
                              height: 1.0,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Bottom spacer
                  const Spacer(flex: 1),
                ],
              ),
              
              // Icon - always shown for consistency
              Positioned(
                top: 0,
                right: 0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: cardWidth * 0.4,
                    maxHeight: cardHeight * 0.5,
                  ),
                  child: Container(
                    width: iconContainerSize,
                    height: iconContainerSize,
                    decoration: BoxDecoration(
                      gradient: WebDesignConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(WebDesignConstants.iconContainerRadius),
                    ),
                    padding: EdgeInsets.all(iconPadding),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        iconPath,
                        width: iconSize,
                        height: iconSize,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.bar_chart,
                            color: Colors.white,
                            size: iconSize,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
