import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.grid_view_rounded),
            _buildNavItem(1, Icons.swap_horiz_rounded),
            _buildNavItem(2, Icons.calendar_today_rounded, isMain: true),
            _buildNavItem(3, Icons.show_chart_rounded),
            _buildNavItem(4, Icons.person_outline_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, {bool isMain = false}) {
    final isSelected = currentIndex == index;
    
    if (isMain) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Text(
                  'Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return IconButton(
      onPressed: () => onTap(index),
      icon: Icon(
        icon,
        color: isSelected ? AppColors.secondary : AppColors.textSecondary,
        size: 28,
      ),
    );
  }
}
