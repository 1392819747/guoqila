import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/item_provider.dart';
import '../../models/category.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/item_tile.dart';
import 'add_item_screen.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Consumer<ItemProvider>(
            builder: (context, provider, child) {
              final items = provider.items;
              final totalCount = items.length;
              final percentage = totalCount > 0 
                  ? ((totalCount - provider.expiredItems.length) / totalCount * 100).toInt() 
                  : 100;

              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                children: [
                  DashboardCard(
                    title: l10n.dashboard,
                    subtitle: l10n.appTitle,
                    count: percentage.toString(),
                    total: totalCount.toString(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddItemScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) => provider.search(value),
                          decoration: InputDecoration(
                            hintText: l10n.searchPlaceholder,
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: PopupMenuButton<SortOption>(
                          icon: const Icon(Icons.sort),
                          onSelected: (option) => provider.setSortOption(option),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: SortOption.expiryDate,
                              child: Text(l10n.sortExpiryDate),
                            ),
                            PopupMenuItem(
                              value: SortOption.name,
                              child: Text(l10n.sortName),
                            ),
                            PopupMenuItem(
                              value: SortOption.purchaseDate,
                              child: Text(l10n.sortPurchaseDate),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: Category.defaultCategories.length + 1,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = provider.selectedCategory == null;
                          return ChoiceChip(
                            label: Text(l10n.categoryAll),
                            selected: isSelected,
                            onSelected: (_) => provider.selectCategory(null),
                            selectedColor: AppColors.secondary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            backgroundColor: AppColors.surface,
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : Colors.grey.shade300,
                            ),
                          );
                        }
                        final category = Category.defaultCategories[index - 1];
                        final isSelected = provider.selectedCategory == category.name;
                        return ChoiceChip(
                          label: Text(Category.getLocalizedName(context, category.name)),
                          selected: isSelected,
                          onSelected: (_) => provider.selectCategory(isSelected ? null : category.name),
                          selectedColor: category.color,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.grey.shade300,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.allItems,
                        style: AppTextStyles.displayMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${items.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(l10n.noItems),
                      ),
                    )
                  else
                    ...items.map((item) => ItemTile(
                          item: item,
                          onDelete: () => provider.deleteItem(item.id),
                        )),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: AppTextStyles.labelSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'User', // Generic name
                style: AppTextStyles.titleLarge,
              ),
            ],
          ),
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.grey300,
            child: Icon(Icons.person, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
