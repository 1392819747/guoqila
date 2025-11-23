import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../../models/category.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GridItemCard extends StatelessWidget {
  final Item item;
  final int index;
  final VoidCallback? onTap;

  const GridItemCard({
    super.key,
    required this.item,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color based on status
    final isExpiringSoon = item.daysUntilExpiry <= 7 && item.daysUntilExpiry >= 0;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Icon Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: item.imagePath == null 
                      ? (isExpired ? Colors.black : (isExpiringSoon ? Colors.white : Colors.black))
                      : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: item.imagePath != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                        child: Image.file(
                          File(item.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Category.getByName(item.category).icon,
                                color: isExpired ? Colors.white : (isExpiringSoon ? Colors.black : Colors.white),
                                size: 48,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Category.getByName(item.category).icon,
                          color: isExpired ? Colors.white : (isExpiringSoon ? Colors.black : Colors.white),
                          size: 48,
                        ),
                      ),
              ),
            ),
            // Content Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.quantity > 1)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'x${item.quantity}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            decoration: isExpired ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiryDateStr,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired 
                          ? Colors.black 
                          : (item.daysUntilExpiry == 0 
                              ? AppColors.error 
                              : (isExpiringSoon ? Colors.black : AppColors.secondary)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.isExpired 
                          ? '已过期' 
                          : (item.daysUntilExpiry == 0 
                              ? '今天过期！！' 
                              : '剩余 ${item.daysUntilExpiry} 天'),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
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
