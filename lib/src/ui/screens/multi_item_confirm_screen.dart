import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/scan_service.dart';
import '../../models/item.dart';
import '../../providers/item_provider.dart';
import 'add_item_screen.dart';
import '../theme/app_text_styles.dart';

class MultiItemConfirmScreen extends StatefulWidget {
  final List<ScanItem> items;
  final File imageFile;

  const MultiItemConfirmScreen({
    super.key,
    required this.items,
    required this.imageFile,
  });

  @override
  State<MultiItemConfirmScreen> createState() => _MultiItemConfirmScreenState();
}

class _MultiItemConfirmScreenState extends State<MultiItemConfirmScreen> {
  late List<ScanItem> _pendingItems;
  late List<bool> _completedFlags;
  late List<Item?> _editedItems;
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _pendingItems = List<ScanItem>.from(widget.items);
    _completedFlags = List<bool>.filled(_pendingItems.length, false, growable: true);
    _editedItems = List<Item?>.filled(_pendingItems.length, null, growable: true);
    _itemKeys = List<GlobalKey>.generate(_pendingItems.length, (_) => GlobalKey(), growable: true);
  }

  // Map AI category to internal ID (similar to HomeView logic)
  String _mapCategory(String? aiCategory, String itemName) {
    String category = aiCategory ?? 'Food';
    
    // Get user's categories (including custom ones)
    final provider = Provider.of<ItemProvider>(context, listen: false);
    final userCategoryNames = provider.categories.map((c) => c.name).toList();
    
    // If the category already exists in user's list (including custom), use it directly
    if (!userCategoryNames.contains(category)) {
      // Category not found, try to map to built-in English ID
      final validCategories = ['Food', 'Dairy', 'Meat', 'Medicine', 'Cosmetics', 'Documents', 'Electronics', 'Beverages', 'Snacks', 'Household', 'Pet Supplies', 'Others'];
      if (!validCategories.contains(category)) {
        // Try to infer from category name or item name
        category = _inferCategory(category) ?? _inferCategory(itemName) ?? 'Food';
      }
    }
    
    return category;
  }

  // Simple category inference (subset of HomeView's logic)
  String? _inferCategory(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('饮料') || lowerText.contains('drink') || 
        lowerText.contains('可乐') || lowerText.contains('juice')) {
      return 'Beverages';
    }
    if (lowerText.contains('牛奶') || lowerText.contains('奶') || lowerText.contains('酸奶')) {
      return 'Dairy';
    }
    if (lowerText.contains('零食') || lowerText.contains('snack')) {
      return 'Snacks';
    }
    
    return null;
  }

  Future<void> _processItem(int index) async {
    final scanItem = _pendingItems[index];
    
    // Map category
    final category = _mapCategory(scanItem.category, scanItem.name ?? '');
    
    // Create a temporary Item object to pass to AddItemScreen
    final tempItem = Item(
      id: '', // Will be generated in AddItemScreen
      name: scanItem.name ?? '',
      category: category,
      expiryDate: scanItem.expiryDate != null 
          ? DateTime.parse(scanItem.expiryDate!) 
          : (scanItem.productionDate != null && scanItem.shelfLifeDays != null
              ? DateTime.parse(scanItem.productionDate!).add(Duration(days: scanItem.shelfLifeDays!))
              : DateTime.now().add(Duration(days: scanItem.shelfLifeDays ?? 7))),
      purchaseDate: DateTime.now(),
      quantity: scanItem.quantity,
      imagePath: widget.imageFile.path,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(item: tempItem, batchMode: true),
      ),
    );



    if (!mounted) return;
    setState(() {
      if (result is Item) {
        _editedItems[index] = result;
      }
      _completedFlags[index] = true;
    });

    final next = _completedFlags.indexWhere((v) => !v);
    if (next != -1) {
      final ctx = _itemKeys[next].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
          curve: Curves.easeOut,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已确认，继续下一个'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _saveAll() {
    final provider = Provider.of<ItemProvider>(context, listen: false);
    for (int i = 0; i < _pendingItems.length; i++) {
      final edited = _editedItems[i];
      if (edited != null) {
        provider.addItem(edited);
      } else {
        final scanItem = _pendingItems[i];
        final category = _mapCategory(scanItem.category, scanItem.name ?? '');
        final item = Item(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: scanItem.name ?? '',
          category: category,
          expiryDate: scanItem.expiryDate != null
              ? DateTime.parse(scanItem.expiryDate!)
              : (scanItem.productionDate != null && scanItem.shelfLifeDays != null
                  ? DateTime.parse(scanItem.productionDate!).add(Duration(days: scanItem.shelfLifeDays!))
                  : DateTime.now().add(Duration(days: scanItem.shelfLifeDays ?? 7))),
          purchaseDate: DateTime.now(),
          quantity: scanItem.quantity,
          imagePath: widget.imageFile.path,
        );
        provider.addItem(item);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('已保存所有商品'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  void _saveCompleted() {
    final provider = Provider.of<ItemProvider>(context, listen: false);
    final toRemove = <int>[];
    for (int i = 0; i < _pendingItems.length; i++) {
      if (_completedFlags[i]) {
        final edited = _editedItems[i];
        if (edited != null) {
          provider.addItem(edited);
        } else {
          final scanItem = _pendingItems[i];
          final category = _mapCategory(scanItem.category, scanItem.name ?? '');
          final item = Item(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: scanItem.name ?? '',
            category: category,
            expiryDate: scanItem.expiryDate != null
                ? DateTime.parse(scanItem.expiryDate!)
                : (scanItem.productionDate != null && scanItem.shelfLifeDays != null
                    ? DateTime.parse(scanItem.productionDate!).add(Duration(days: scanItem.shelfLifeDays!))
                    : DateTime.now().add(Duration(days: scanItem.shelfLifeDays ?? 7))),
            purchaseDate: DateTime.now(),
            quantity: scanItem.quantity,
            imagePath: widget.imageFile.path,
          );
          provider.addItem(item);
        }
        toRemove.add(i);
      }
    }
    if (toRemove.isEmpty) return;
    setState(() {
      for (final idx in toRemove.reversed) {
        _pendingItems.removeAt(idx);
        _completedFlags.removeAt(idx);
        _editedItems.removeAt(idx);
        _itemKeys.removeAt(idx);
      }
    });
    final count = toRemove.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('已保存已完成的商品$count件'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
    if (_pendingItems.isEmpty) {
      Navigator.pop(context);
    } else {
      final ctx = _itemKeys.first.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '识别到 ${_pendingItems.length} 个商品',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
          // Image Preview with bold border style
          Container(
            margin: const EdgeInsets.all(16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white54 : Colors.black,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          
          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              '点击下方商品进行确认和编辑',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
          
          // Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _pendingItems[index];
                final isCompleted = _completedFlags[index];
                return Dismissible(
                  key: ValueKey('scan_item_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                onDismissed: (_) {
                  setState(() {
                    _pendingItems.removeAt(index);
                    _completedFlags.removeAt(index);
                    _editedItems.removeAt(index);
                    _itemKeys.removeAt(index);
                  });
                },
                child: KeyedSubtree(
                  key: _itemKeys[index],
                  child: GestureDetector(
                    onTap: isCompleted ? null : () => _processItem(index),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCompleted 
                          ? (isDark ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1))
                          : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCompleted 
                              ? Colors.green
                              : (isDark ? Colors.white54 : Colors.black),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isCompleted 
                                  ? Colors.green
                                  : (isDark ? Colors.grey[700] : Colors.grey[200]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isCompleted ? Icons.check_circle : Icons.inventory_2_outlined,
                              color: isCompleted ? Colors.white : theme.iconTheme.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name ?? '未知商品',
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                    if (item.quantity > 1)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.grey[700] : Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'x${item.quantity}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: theme.textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.category ?? "其他"} ${item.expiryDate != null ? "• 到期: ${item.expiryDate}" : item.shelfLifeDays != null ? "• 保质期 ${item.shelfLifeDays}天" : ""}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isCompleted ? Icons.check : Icons.arrow_forward_ios,
                            size: 16,
                            color: isCompleted 
                                ? Colors.green 
                                : theme.iconTheme.color?.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: (_completedFlags.isNotEmpty && _completedFlags.any((v) => v)) ? const Offset(0, 0) : const Offset(0, 1),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: (_completedFlags.isNotEmpty && _completedFlags.any((v) => v)) ? 1 : 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_completedFlags.isNotEmpty && _completedFlags.any((v) => v)) ? _saveCompleted : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('保存已完成项'),
                      ),
                    ),
                    if (_completedFlags.isNotEmpty && _completedFlags.every((v) => v)) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('确认保存全部'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
