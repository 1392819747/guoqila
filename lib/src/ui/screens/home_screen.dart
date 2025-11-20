import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/item_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/item_tile.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
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
                            title: 'Industrial',
                            subtitle: 'Design UX',
                            count: percentage.toString(),
                            total: totalCount.toString(),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddItemScreen()),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'All Items',
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
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text('No items yet. Add one!'),
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
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                },
              ),
            ),
          ],
        ),
      ),
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
                'Kristian Watson', // Placeholder name
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
