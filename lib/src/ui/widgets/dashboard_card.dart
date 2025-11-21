import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'neumorphic_container.dart';
import 'neumorphic_button.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String count;
  final String total;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NeumorphicContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.inventory_2_outlined, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.aiAssistant,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              NeumorphicContainer(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                borderRadius: 20,
                isPressed: true, // Inset look for the counter
                child: const Text('30+', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.displayMedium.copyWith(
                      height: 1.1,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.displayMedium.copyWith(
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Wavy line decoration
                  SizedBox(
                    width: 40,
                    child: CustomPaint(
                      painter: WavyLinePainter(),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$count%',
                    style: AppTextStyles.displayLarge,
                  ),
                  Text(
                    l10n.itemsCount(count, total),
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.keyboard_arrow_up_rounded),
              NeumorphicButton(
                onPressed: onTap,
                width: 56,
                height: 56,
                borderRadius: 28, // Circle
                padding: EdgeInsets.zero,
                color: AppColors.secondary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 4, -5, size.width / 2, 0);
    path.quadraticBezierTo(3 * size.width / 4, 5, size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
