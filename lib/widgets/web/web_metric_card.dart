import 'package:flutter/material.dart';
import '../../constants/web_design_constants.dart';

class WebMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color indicatorColor;
  
  const WebMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        
        // Responsive sizing
        final cardPadding = (cardWidth * 0.1).clamp(12.0, 20.0);
        final titleFontSize = (cardWidth * 0.06).clamp(10.0, 12.0);
        final valueFontSize = (cardWidth * 0.1).clamp(16.0, 20.0);
        final dotSize = (cardWidth * 0.06).clamp(8.0, 12.0);
        final spacing = (cardHeight * 0.09).clamp(4.0, 8.0);
        
        return Container(
          decoration: BoxDecoration(
            color: WebDesignConstants.webCardBackground,
            borderRadius: BorderRadius.circular(WebDesignConstants.radiusLarge),
            boxShadow: WebDesignConstants.cardShadow,
          ),
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text content - flexible
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w400,
                          color: WebDesignConstants.webTextSecondary,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: spacing),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: valueFontSize,
                            fontWeight: FontWeight.w600,
                            color: WebDesignConstants.webTextPrimary,
                            height: 1.2,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(width: cardPadding * 0.5),
              
              // Indicator dot - responsive
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(WebDesignConstants.radiusCircle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
