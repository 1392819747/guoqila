import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../ui/theme/app_colors.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;

  const Category({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<Category> defaultCategories = [
    Category(name: 'Food', icon: Icons.restaurant_menu, color: Colors.orange),
    Category(name: 'Dairy', icon: Icons.bakery_dining, color: Colors.lightBlue), // 乳制品
    Category(name: 'Meat', icon: Icons.set_meal, color: Colors.red), // 肉类
    Category(name: 'Medicine', icon: Icons.medication, color: Colors.red),
    Category(name: 'Cosmetics', icon: Icons.face, color: Colors.pink),
    Category(name: 'Documents', icon: Icons.description, color: Colors.blue),
    Category(name: 'Electronics', icon: Icons.electrical_services, color: Colors.purple),
    Category(name: 'Beverages', icon: Icons.local_drink, color: Colors.teal),
    Category(name: 'Snacks', icon: Icons.cookie, color: Colors.amber),
    Category(name: 'Household', icon: Icons.cleaning_services, color: Colors.indigo),
    Category(name: 'Pet Supplies', icon: Icons.pets, color: Colors.brown),
    Category(name: 'Others', icon: Icons.category, color: AppColors.grey300),
  ];

  static String getLocalizedName(BuildContext context, String categoryName) {
    final l10n = AppLocalizations.of(context)!;
    switch (categoryName) {
      case 'Food': return l10n.categoryFood;
      case 'Dairy': return l10n.categoryDairy;
      case 'Meat': return l10n.categoryMeat;
      case 'Medicine': return l10n.categoryMedicine;
      case 'Cosmetics': return l10n.categoryCosmetics;
      case 'Documents': return l10n.categoryDocuments;
      case 'Electronics': return l10n.categoryElectronics;
      case 'Beverages': return l10n.categoryBeverages;
      case 'Snacks': return l10n.categorySnacks;
      case 'Household': return l10n.categoryHousehold;
      case 'Pet Supplies': return l10n.categoryPetSupplies;
      case 'Others': return l10n.categoryOthers;
      default: return categoryName;
    }
  }

  static Category getByName(String name) {
    return defaultCategories.firstWhere(
      (c) => c.name == name,
      orElse: () => Category(
        name: name,
        icon: Icons.bookmark, // Default icon for custom categories
        color: Colors.grey,   // Default color for custom categories
      ),
    );
  }
}
