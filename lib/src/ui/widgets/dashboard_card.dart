import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';


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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
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
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.inventory_2_outlined, size: 20, color: AppColors.primary),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
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
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
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
