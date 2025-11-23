import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/item.dart';
import '../../models/category.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../providers/item_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'quantity_control.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine color based on index or status
    final isExpiringSoon = item.daysUntilExpiry <= 3 && item.daysUntilExpiry >= 0;
    final isExpired = item.isExpired;
    
    Color backgroundColor;
    Color textColor = theme.textTheme.titleLarge?.color ?? Colors.black;
    
    if (isExpired) {
      backgroundColor = isDark ? Colors.grey[800]! : AppColors.grey300;
      textColor = AppColors.textSecondary;
    } else if (isExpiringSoon) {
      backgroundColor = AppColors.primary; // Yellow for warning
      textColor = Colors.black; // Always black on yellow
    } else {
      backgroundColor = theme.colorScheme.surface; // Surface color for fresh items
    }

    // Border color
    final borderColor = isExpired 
        ? Colors.transparent 
        : (isDark ? Colors.white54 : Colors.black);
    final borderWidth = isExpired ? 0.0 : 2.0;
    
    // Format expiry date
    final expiryDateStr = '${item.expiryDate.year}/${item.expiryDate.month.toString().padLeft(2, '0')}/${item.expiryDate.day.toString().padLeft(2, '0')}';


    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: isExpired ? [] : [
             BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Slidable(
          key: ValueKey(item.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  context.read<ItemProvider>().togglePin(item.id);
                },
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                icon: item.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                label: item.isPinned ? '取消置顶' : '置顶',
              ),
              SlidableAction(
                onPressed: (context) {
                  // Show delete confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('确认删除'),
                      content: Text('确定要删除 "${item.name}" 吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<ItemProvider>().deleteItem(item.id);
                            Navigator.pop(context);
                          },
                          child: const Text('删除', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: '删除',
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: backgroundColor, // Ensure Slidable background matches
            child: Row(
              children: [
                // Product Image or Category Icon
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: item.imagePath == null 
                            ? (isExpired 
                                ? (isDark ? Colors.black : Colors.black) 
                                : (isExpiringSoon ? Colors.white : (isDark ? Colors.grey[800] : Colors.black)))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: item.imagePath != null 
                            ? Border.all(color: isDark ? Colors.white54 : Colors.black, width: 2) 
                            : null,
                      ),
                      child: item.imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(item.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Category.getByName(item.category).icon,
                                    color: isExpired 
                                        ? Colors.white 
                                        : (isExpiringSoon 
                                            ? Colors.black 
                                            : (isDark ? Colors.white : Colors.white)),
                                    size: 36,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Category.getByName(item.category).icon,
                              color: isExpired 
                                  ? Colors.white 
                                  : (isExpiringSoon 
                                      ? Colors.black 
                                      : (isDark ? Colors.white : Colors.white)),
                              size: 36,
                            ),
                    ),
                    if (item.isPinned)
                      Positioned(
                        top: -2,
                        left: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.push_pin,
                            size: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Quantity Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
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
                          ),
                          const SizedBox(width: 8),
                          QuantityControl(
                            quantity: item.quantity,
                            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                            textColor: isDark ? Colors.white : Colors.black,
                            onChanged: (newQuantity) {
                              final updatedItem = Item(
                                id: item.id,
                                name: item.name,
                                category: item.category,
                                expiryDate: item.expiryDate,
                                purchaseDate: item.purchaseDate,
                                note: item.note,
                                imagePath: item.imagePath,
                                quantity: newQuantity,
                                isPinned: item.isPinned,
                              );
                              context.read<ItemProvider>().updateItem(updatedItem);
                            },
                          ),
                        ],
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
                          color: isExpired 
                              ? Colors.black 
                              : (item.daysUntilExpiry == 0 
                                  ? AppColors.error 
                                  : (isExpiringSoon ? Colors.black : AppColors.secondary)),
                          borderRadius: BorderRadius.circular(12),
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
          ),
        ),
      ),
    );
  }
}
