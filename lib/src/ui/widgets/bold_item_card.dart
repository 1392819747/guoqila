import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/item.dart';
import '../../models/category.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BoldItemCard extends StatelessWidget {
  final Item item;
  final int index;
  final VoidCallback? onTap;

  const BoldItemCard({
    super.key,
    required this.item,
    required this.index,
    this.onTap,
  });

  // Get category icon from lucide_icons
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Dairy':
        return LucideIcons.milk;
      case 'Beverages':
        return LucideIcons.cupSoda;
      case 'Snacks':
        return LucideIcons.cookie;
      case 'Meat':
        return LucideIcons.beef;
      case 'Food':
      default:
        return LucideIcons.utensils;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine color based on index or status
    final isExpiringSoon = item.daysUntilExpiry <= 3 && item.daysUntilExpiry >= 0;
    final isExpired = item.isExpired;
    
    Color backgroundColor;
    Color textColor = Colors.black;
    
    if (isExpired) {
      backgroundColor = AppColors.grey300;
      textColor = AppColors.textSecondary;
    } else if (isExpiringSoon) {
      backgroundColor = AppColors.primary; // Yellow for warning
    } else {
      backgroundColor = Colors.white; // White for fresh items
    }

    // Border color
    final borderColor = isExpired ? Colors.transparent : Colors.black;
    final borderWidth = isExpired ? 0.0 : 2.0;
    
    // Format expiry date
    final expiryDateStr = '${item.expiryDate.year}/${item.expiryDate.month.toString().padLeft(2, '0')}/${item.expiryDate.day.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: isExpired ? [] : [
            const BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image or Category Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: item.imagePath == null 
                    ? (isExpired ? Colors.black : (isExpiringSoon ? Colors.white : Colors.black))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: item.imagePath != null ? Border.all(color: Colors.black, width: 2) : null,
              ),
              child: item.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(item.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image fails to load
                          return Icon(
                            _getCategoryIcon(item.category),
                            color: isExpired ? Colors.white : (isExpiringSoon ? Colors.black : Colors.white),
                            size: 36,
                          );
                        },
                      ),
                    )
                  : Icon(
                      _getCategoryIcon(item.category),
                      color: isExpired ? Colors.white : (isExpiringSoon ? Colors.black : Colors.white),
                      size: 36,
                    ),
            ),
            const SizedBox(width: 16),
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Name
                  Text(
                    item.name,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: textColor,
                      decoration: isExpired ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Category and Expiry Date (on same line)
                  Row(
                    children: [
                      Text(
                        Category.getLocalizedName(context, item.category),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: textColor.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        expiryDateStr,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Days Until Expiry Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired ? Colors.black : (isExpiringSoon ? Colors.black : AppColors.secondary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.isExpired ? '已过期' : '${item.daysUntilExpiry} 天',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
