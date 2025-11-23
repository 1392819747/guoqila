import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../../l10n/generated/app_localizations.dart';

class ExpirationSummaryCard extends StatelessWidget {
  final int expiringSoonCount;
  final int expiredCount;
  final int totalCount;
  final VoidCallback? onReviewTap;
  final bool isExpanded;

  const ExpirationSummaryCard({
    super.key,
    required this.expiringSoonCount,
    required this.expiredCount,
    required this.totalCount,
    this.onReviewTap,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine state
    final hasExpired = expiredCount > 0;
    final hasExpiringSoon = expiringSoonCount > 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Color backgroundColor;
    Color textColor;
    String title;
    String subtitle;
    IconData icon;

    final l10n = AppLocalizations.of(context)!;

    if (hasExpired) {
      backgroundColor = isDark ? Colors.red[900]! : Colors.black;
      textColor = Colors.white;
      title = l10n.actionNeeded;
      subtitle = l10n.expiredItemsCount(expiredCount);
      icon = Icons.warning_amber_rounded;
    } else if (hasExpiringSoon) {
      backgroundColor = AppColors.primary; // Yellow
      textColor = Colors.black;
      title = l10n.expiringSoonTitle;
      subtitle = l10n.expiringSoonItemsCount(expiringSoonCount);
      icon = Icons.access_time_filled;
    } else {
      backgroundColor = AppColors.secondary; // Green
      textColor = Colors.black;
      title = l10n.allFresh;
      subtitle = l10n.allFreshSubtitle(totalCount);
      icon = Icons.check_circle;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: isDark && hasExpired ? Border.all(color: Colors.white24, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: textColor, size: 24),
              ),
              if (hasExpiringSoon || hasExpired)
                GestureDetector(
                  onTap: onReviewTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.review,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.displayMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
