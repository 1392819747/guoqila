import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/item_provider.dart';
import '../../models/category.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<ItemProvider>(
          builder: (context, provider, child) {
            final items = provider.items;
            if (items.isEmpty) {
              return Center(child: Text(l10n.noItems));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.statistics, style: AppTextStyles.displayMedium),
                  const SizedBox(height: 32),
                  _buildSummaryCards(context, items.length, provider.expiredItems.length),
                  const SizedBox(height: 32),
                  Text(l10n.categoryDistribution, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildPieChart(context, items),
                  ),
                  const SizedBox(height: 32),
                  Text(l10n.expiringSoon, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildBarChart(items),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, int total, int expired) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            l10n.totalItems,
            total.toString(),
            Icons.inventory_2_outlined,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            l10n.expired,
            expired.toString(),
            Icons.warning_amber_rounded,
            AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.displayLarge.copyWith(fontSize: 24),
          ),
          Text(
            title,
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, List<dynamic> items) {
    Map<String, int> categoryCounts = {};
    for (var item in items) {
      categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: categoryCounts.entries.map((entry) {
          final category = Category.getByName(entry.key);
          return PieChartSectionData(
            color: category.color,
            value: entry.value.toDouble(),
            title: '${entry.value}',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(List<dynamic> items) {
    // Group items by month of expiry
    Map<int, int> expiryByMonth = {};
    final now = DateTime.now();
    for (int i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month + i);
      expiryByMonth[month.month] = 0;
    }

    for (var item in items) {
      if (expiryByMonth.containsKey(item.expiryDate.month)) {
        expiryByMonth[item.expiryDate.month] = (expiryByMonth[item.expiryDate.month] ?? 0) + 1;
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (expiryByMonth.values.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    months[(value.toInt() - 1) % 12],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: expiryByMonth.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: AppColors.secondary,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
