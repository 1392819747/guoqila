import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CalendarStrip extends StatelessWidget {
  const CalendarStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Find the Monday of this week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = monday.add(Duration(days: index));
          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
          
          return Column(
            children: [
              Text(
                DateFormat('E').format(date).substring(0, 2),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday ? Colors.black : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday ? null : Border.all(color: AppColors.grey300, width: 2),
                ),
                child: Center(
                  child: isToday 
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        date.day.toString(),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
