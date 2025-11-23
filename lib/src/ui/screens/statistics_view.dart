import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../models/category.dart';
import '../../providers/item_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  bool _isWeeklyView = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ItemProvider>();
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.statistics,
                style: AppTextStyles.displayLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.displayLarge?.color,
                ),
              ),
              const SizedBox(height: 24),
              
              // Overview Cards
              _buildOverviewCards(provider, theme),
              const SizedBox(height: 32),
              
              // Expiry Status Chart
              _buildSectionTitle('库存状态', theme),
              const SizedBox(height: 16),
              _buildExpiryStatusChart(provider, theme),
              const SizedBox(height: 32),
              
              // Category Breakdown
              _buildSectionTitle('分类分布', theme),
              const SizedBox(height: 16),
              _buildCategoryBreakdown(provider, theme),
              const SizedBox(height: 32),
              
              // Timeline
              _buildSectionTitle('过期时间线', theme),
              const SizedBox(height: 16),
              _buildExpiryTimeline(provider, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(
        fontWeight: FontWeight.w900,
        color: theme.textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _buildOverviewCards(ItemProvider provider, ThemeData theme) {
    final totalItems = provider.items.fold(0, (sum, item) => sum + item.quantity);
    final expiredItems = provider.expiredItems.fold(0, (sum, item) => sum + item.quantity);
    final expiringSoonItems = provider.expiringSoonItems.fold(0, (sum, item) => sum + item.quantity);
    final freshItems = totalItems - expiredItems - expiringSoonItems;
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '总物品',
            totalItems.toString(),
            Icons.inventory_2_outlined,
            isDark ? Colors.blue[900]! : Colors.blue[100]!,
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '新鲜',
            freshItems.toString(),
            Icons.check_circle_outline,
            AppColors.secondary.withOpacity(isDark ? 0.2 : 0.3),
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color bgColor, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final contentColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white54 : Colors.black, 
          width: 2
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: contentColor),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: contentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryStatusChart(ItemProvider provider, ThemeData theme) {
    final totalItems = provider.items.fold(0, (sum, item) => sum + item.quantity);
    final isDark = theme.brightness == Brightness.dark;

    if (totalItems == 0) {
      return _buildEmptyState('暂无数据', theme);
    }
    
    final expiredItems = provider.expiredItems.fold(0, (sum, item) => sum + item.quantity);
    final expiringSoonItems = provider.expiringSoonItems.fold(0, (sum, item) => sum + item.quantity);
    final freshItems = totalItems - expiredItems - expiringSoonItems;
    
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white54 : Colors.black, 
          width: 2
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: freshItems.toDouble(),
                    title: '$freshItems',
                    color: AppColors.secondary,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: expiringSoonItems.toDouble(),
                    title: '$expiringSoonItems',
                    color: AppColors.primary,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  PieChartSectionData(
                    value: expiredItems.toDouble(),
                    title: '$expiredItems',
                    color: isDark ? Colors.grey[600] : Colors.black,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('新鲜', freshItems, AppColors.secondary, theme),
                const SizedBox(height: 8),
                _buildLegendItem('即将过期', expiringSoonItems, AppColors.primary, theme),
                const SizedBox(height: 8),
                _buildLegendItem('已过期', expiredItems, isDark ? Colors.grey[600]! : Colors.black, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(ItemProvider provider, ThemeData theme) {
    final items = provider.items;
    final isDark = theme.brightness == Brightness.dark;

    if (items.isEmpty) {
      return _buildEmptyState('暂无数据', theme);
    }
    
    // Count items by category
    final categoryCount = <String, int>{};
    var totalQuantity = 0;
    for (var item in items) {
      categoryCount[item.category] = (categoryCount[item.category] ?? 0) + item.quantity;
      totalQuantity += item.quantity;
    }
    
    final sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white54 : Colors.black, 
          width: 2
        ),
      ),
      child: Column(
        children: sortedCategories.take(5).map((entry) {
          final category = provider.categories.firstWhere(
            (c) => c.name == entry.key,
            orElse: () => provider.categories.first,
          );
          final percentage = (entry.value / totalQuantity * 100).toStringAsFixed(1);
          final localizedName = Category.getLocalizedName(context, entry.key);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(category.icon, size: 20, color: theme.iconTheme.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizedName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            '${entry.value} ($percentage%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: entry.value / totalQuantity,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpiryTimeline(ItemProvider provider, ThemeData theme) {
    final items = provider.items.where((item) => !item.isExpired).toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    final isDark = theme.brightness == Brightness.dark;
    
    if (items.isEmpty) {
      return _buildEmptyState('暂无未过期物品', theme);
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white54 : Colors.black, 
          width: 2
        ),
      ),
      child: Column(
        children: items.take(10).map((item) {
          final daysLeft = item.daysUntilExpiry;
          final isExpiringSoon = daysLeft <= 7;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: daysLeft == 0 
                        ? AppColors.error 
                        : (isExpiringSoon ? AppColors.primary : AppColors.secondary),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  daysLeft == 0 ? '今天！' : '$daysLeft 天',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: daysLeft == 0 
                        ? AppColors.error 
                        : (isExpiringSoon ? AppColors.primary : AppColors.secondary),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String message, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white54 : Colors.black, 
          width: 2
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: isDark ? Colors.grey[600] : Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
