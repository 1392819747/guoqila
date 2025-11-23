import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/item_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/bold_item_card.dart';
import '../widgets/expiration_summary_card.dart';
import 'add_item_screen.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/scan_service.dart';
import '../../models/item.dart';
import '../../models/category.dart';
import 'package:uuid/uuid.dart';

import '../widgets/grid_item_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  late AnimationController _fabAnimationController;
  late Animation<double> _fabRotateAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _fabSlideAnimation;
  bool _isFabExpanded = false;
  bool _showExpiringDetails = false;
  bool _isGridView = false; // View mode state

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabRotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    ); // 0.125 * 360 = 45 degrees

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOutBack),
    );
    
    _fabSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  // Helper: Check if text contains Chinese characters
  bool _containsChinese(String text) {
    return text.runes.any((rune) => rune >= 0x4E00 && rune <= 0x9FFF);
  }

  // Helper: Count Chinese characters
  int _countChinese(String text) {
    return text.runes.where((rune) => rune >= 0x4E00 && rune <= 0x9FFF).length;
  }

  // Helper: Convert traditional Chinese to simplified (OCR often confuses them)
  String _toSimplifiedChinese(String text) {
    final conversionMap = {
      '気': '气', '態': '态', '頭': '头', '縮': '缩', '廣': '广',
      '檸': '柠', '檬': '檬', '氣': '气', '樸': '朴', '計': '计',
      '蔗': '蔗', '聽': '听', '營': '营', '養': '养', '質': '质',
      '購': '购', '點': '点', '線': '线', '製': '制', '産': '产',
      '會': '会', '億': '亿', '進': '进', '開': '开', '區': '区'
    };
    
    String result = text;
    conversionMap.forEach((traditional, simplified) {
      result = result.replaceAll(traditional, simplified);
    });
    return result;
  }

  // Helper: Score a line to determine if it's likely a product name
  double _scoreProductName(String line) {
    // Convert traditional to simplified first
    line = _toSimplifiedChinese(line);
    
    double score = 0.0;
    
    // CRITICAL: Filter out lines starting with digits (like "8味气泡水...")
    if (RegExp(r'^\d').hasMatch(line)) {
      return -100.0; // 数字开头直接淘汰
    }
    
    // CRITICAL: Filter out addresses (heavy penalty)
    if (RegExp(r'[省市区县路街道号室]').hasMatch(line)) {
      return -100.0; // 地址直接淘汰
    }
    
    // CRITICAL: Filter out ingredients and nutrition info
    if (line.contains('成分') || line.contains('营养') || line.contains('添加') ||
        line.contains('配料') || line.contains('食品') || line.contains('生产') ||
        line.contains('许可') || line.contains('委托') || line.contains('受委托') ||
        line.contains('执行标准') || line.contains('SC') || line.contains('GB/T')) {
      return -100.0; // 成分表和生产信息直接淘汰
    }
    
    // CRITICAL: Filter out overly long lines (likely addresses or specs)
    if (line.length > 30) {
      return -50.0; // 太长的文本（如地址）降分
    }
    
    // Count Chinese characters
    final chineseCount = _countChinese(line);
    
    // High priority: Contains Chinese (more Chinese = better)
    if (chineseCount > 0) {
      score += chineseCount * 2.0; // 2 points per Chinese character
    }
    
    // BOOST: Known brand keywords (huge bonus) - GREATLY EXPANDED
    final brandKeywords = [
      // 饮料品牌
      '元气森林', '可口可乐', '百事', '雪碧', '芬达', '美年达',
      '农夫山泉', '怡宝', '娃哈哈', '康师傅', '统一', '今麦郎',
      '三得利', '喜茶', '奈雪', '茶颜悦色', '蜜雪冰城',
      '美汁源', '果粒橙', '鲜橙多', '酷儿', '小茗同学',
      '东方树叶', '茶π', '淳茶舍', '原叶',
      '红牛', '脉动', '尖叫', '佳得乐', '宝矿力',
      '养乐多', '味全', '简爱', '乐纯',
      
      // 乳制品品牌
      '伊利', '蒙牛', '光明', '三元', '新希望', '君乐宝',
      '安慕希', '纯甄', '特仑苏', '金典', '优倍',
      
      // 零食品牌
      '良品铺子', '三只松鼠', '百草味', '来伊份', '盐津铺子',
      '乐事', '品客', '奥利奥', '趣多多', '德芙', '好时',
      '卫龙', '周黑鸭', '绝味', '煌上煌',
      
      // 日化品牌
      '欧莱雅', '巴黎欧莱雅', '兰蔻', '雅诗兰黛', '资生堂',
      '自然堂', '百雀羚', '珀莱雅', '薇诺娜', '润百颜',
      '海蓝之谜', '科颜氏', '倩碧', '雅漾', '理肤泉',
      '安耐晒', '碧柔', '曼秀雷敦', '妮维雅',
      
      // 调味品/食品
      '老干妈', '海天', '李锦记', '太太乐', '家乐',
      '康师傅', '统一', '今麦郎', '白象', '陈克明'
    ];
    
    for (final brand in brandKeywords) {
      if (line.contains(brand)) {
        score += 25.0; // 品牌词超大加分（从20提升到25）
        break; // 只加一次
      }
    }
    
    // BOOST: Product type keywords - EXPANDED
    final productKeywords = [
      // 饮料类
      '气泡水', '苏打水', '矿泉水', '纯净水', '饮用水',
      '可乐', '雪碧', '芬达', '奶茶', '果茶', '绿茶', '红茶',
      '果汁', '橙汁', '苹果汁', '葡萄汁', '西柚汁',
      '功能饮料', '运动饮料', '能量饮料',
      '酸奶', '乳酸菌', '益生菌',
      
      // 食品类
      '牛奶', '纯牛奶', '鲜牛奶', '全脂奶', '脱脂奶',
      '面包', '吐司', '饼干', '薯片', '锅巴', '辣条',
      '巧克力', '糖果', '软糖', '硬糖',
      '方便面', '泡面', '火锅底料', '调味料',
      
      // 日化类
      '防晒霜', '隔离霜', '面霜', '乳液', '精华',
      '洗面奶', '卸妆水', '爽肤水', '化妆水',
      '面膜', '眼霜', '护手霜', '身体乳',
      '洗发水', '护发素', '沐浴露', '香皂'
    ];
    
    for (final keyword in productKeywords) {
      if (line.contains(keyword)) {
        score += 12.0; // 产品词加分（从10提升到12）
        break; // 只加一次
      }
    }
    
    // Penalize vague/junk words when appearing alone
    final junkPatterns = ['味', '汽水', '海含', '最', '饱满', '果粒', '多会'];
    for (final pattern in junkPatterns) {
      if (line == pattern || (line.length <= 5 && line.endsWith(pattern))) {
        score -= 15.0;
      }
    }
    
    // Heavily penalize letter/digit mixes (like "OH ORG 01")
    if (RegExp(r'[A-Z0-9]').hasMatch(line) && !_containsChinese(line)) {
      score -= 20.0; // Heavy penalty
    }
    
    // Penalize single/double character lines
    final length = line.length;
    if (length <= 2) {
      score -= 10.0;
    } else if (length >= 3 && length <= 25) {
      score += 3.0;
    }
    
    // Penalize if it looks like a date or pure number
    if (RegExp(r'^\d+[年月日/-]').hasMatch(line) || RegExp(r'^\d+$').hasMatch(line)) {
      score -= 10.0;
    }
    
    return score;
  }

  // Helper: Try to infer category from text
  String _inferCategory(String text) {
    final lowerText = text.toLowerCase();
    
    // Dairy - 乳制品
    if (lowerText.contains('牛奶') || lowerText.contains('奶') || lowerText.contains('酸奶') ||
        lowerText.contains('milk') || lowerText.contains('yogurt') || 
        lowerText.contains('乳') || lowerText.contains('奶酪') || lowerText.contains('芝士')) {
      return 'Dairy';
    }
    
    // Beverages - 饮料
    if (lowerText.contains('饮料') || lowerText.contains('可乐') || lowerText.contains('果汁') ||
        lowerText.contains('气泡') || lowerText.contains('水') || lowerText.contains('茶') ||
        lowerText.contains('drink') || lowerText.contains('juice') || lowerText.contains('cola') ||
        lowerText.contains('咖啡') || lowerText.contains('奶茶') || lowerText.contains('汽水')) {
      return 'Beverages';
    }
    
    // Snacks - 零食
    if (lowerText.contains('零食') || lowerText.contains('薯片') || lowerText.contains('饼干') ||
        lowerText.contains('snack') || lowerText.contains('chip') || lowerText.contains('cookie') ||
        lowerText.contains('糖') || lowerText.contains('巧克力') || lowerText.contains('辣条')) {
      return 'Snacks';
    }
    
    // Meat - 肉类
    if (lowerText.contains('肉') || lowerText.contains('鱼') || lowerText.contains('鸡') ||
        lowerText.contains('meat') || lowerText.contains('fish') || lowerText.contains('chicken') ||
        lowerText.contains('猪') || lowerText.contains('牛') || lowerText.contains('羊')) {
      return 'Meat';
    }
    
    // Vegetables - 蔬菜水果 (map to Food since no Vegetables category)
    if (lowerText.contains('菜') || lowerText.contains('蔬') || lowerText.contains('果') ||
        lowerText.contains('vegetable') || lowerText.contains('fruit') ||
        lowerText.contains('番茄') || lowerText.contains('apple') || lowerText.contains('orange')) {
      return 'Food'; // Changed from 'Vegetables' to 'Food'
    }
    
    // Cosmetics - 化妆品/日化
    if (lowerText.contains('霜') || lowerText.contains('乳液') || lowerText.contains('精华') ||
        lowerText.contains('面膜') || lowerText.contains('防晒') || lowerText.contains('洗面') ||
        lowerText.contains('护肤') || lowerText.contains('化妆') || lowerText.contains('spf')) {
      return 'Other'; // 或创建新类别 'Cosmetics'
    }
    
    // Default to Food if nothing matches
    return 'Food';
  }

  void _handleScan(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('分析图片中...'),
          backgroundColor: Colors.black,
          duration: Duration(seconds: 1),
        ),
      );

      final scanService = ScanService();
      final result = await scanService.scanImage(File(image.path));
      
      if (!mounted) return;

      String itemName = '扫描商品';
      String category = 'Food';
      String? noteContent;
      
      if (result.text != null && result.text!.isNotEmpty) {
        // Split into lines and score each
        var lines = result.text!.split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
        
        // Clean up lines: remove ingredients after closing bracket
        lines = lines.map((line) {
          // If line contains )，extract only the part before and including )
          if (line.contains(')')) {
            final closingBracketIndex = line.indexOf(')');
            return line.substring(0, closingBracketIndex + 1);
          }
          // If line is too long, try to find a natural break point
          if (line.length > 25) {
            // Look for separators: ●, •, 、, space after Chinese
            final separators = ['●', '•', '、'];
            for (final sep in separators) {
              if (line.contains(sep)) {
                return line.substring(0, line.indexOf(sep)).trim();
              }
            }
            // Otherwise truncate at 20 chars if it has brand name
            if (line.length > 20 && _containsChinese(line.substring(0, 20))) {
              return line.substring(0, 20);
            }
          }
          return line;
        }).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
        
        if (lines.isNotEmpty) {
          // Score all lines
          final scoredLines = lines.map((line) {
            return MapEntry(line, _scoreProductName(line));
          }).toList();
          
          // Sort by score (highest first)
          scoredLines.sort((a, b) => b.value.compareTo(a.value));
          
          // Collect top Chinese lines with good scores (score > 15)
          var topLines = scoredLines
              .where((entry) => _containsChinese(entry.key) && entry.value > 15)
              .take(3) // Take top 3 candidates first
              .map((entry) => entry.key)
              .toList();
          
          // De-duplicate: remove lines that are substrings of others
          final uniqueLines = <String>[];
          for (final line in topLines) {
            bool isDuplicate = false;
            for (final existing in uniqueLines) {
              if (existing.contains(line) || line.contains(existing)) {
                // Keep the longer one
                if (line.length > existing.length) {
                  uniqueLines.remove(existing);
                  uniqueLines.add(line);
                }
                isDuplicate = true;
                break;
              }
            }
            if (!isDuplicate) {
              uniqueLines.add(line);
            }
          }
          
          // Take only top 1 if it's a complete brand name, otherwise try to combine
          topLines = uniqueLines.take(1).toList();
          
          // 如果没有中文行，至少取得分最高的行
          if (topLines.isEmpty && scoredLines.isNotEmpty) {
            itemName = scoredLines.first.key;
          } else if (topLines.isNotEmpty) {
            itemName = topLines.join(' ');
          }
          
          // Try to infer category
          category = _inferCategory(result.text!);
          
          // Save full recognized text to notes
          noteContent = '扫描识别内容：\n${result.text}';
        }
      }

      // Save scanned image to app directory
      String? savedImagePath;
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/product_images');
      if (!imageDir.existsSync()) {
        imageDir.createSync(recursive: true);
      }
      
      final itemId = const Uuid().v4();
      final savedImage = await File(image.path).copy('${imageDir.path}/$itemId.jpg');
      savedImagePath = savedImage.path;

      final scannedItem = Item(
        id: itemId,
        name: itemName,
        category: category,
        expiryDate: DateTime.now().add(const Duration(days: 7)), // Default 7 days
        purchaseDate: DateTime.now(),
        note: noteContent,
        imagePath: savedImagePath, // Save scanned image path
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddItemScreen(item: scannedItem),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Consumer<ItemProvider>(
              builder: (context, provider, child) {
                final items = provider.items;
                final expiredCount = provider.expiredItems.length;
                final expiringSoonCount = items.where((i) => i.daysUntilExpiry <= 7 && i.daysUntilExpiry >= 0).length;
                
                // Filter items based on search query
                final filteredItems = items.where((i) {
                  if (_searchQuery.isEmpty) return true;
                  return i.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                final expiringItems = filteredItems.where((i) => i.daysUntilExpiry <= 7 && !i.isExpired).toList();
                
                // Filter items based on selection
                // Show ALL items in the list, not just non-expiring ones
                var otherItems = filteredItems.toList();
                
                if (_selectedCategory != 'All') {
                  otherItems = otherItems.where((i) => i.category == _selectedCategory).toList();
                }

                // Sort items: Expired at TOP, then by date (natural sort does this)
                otherItems.sort((a, b) {
                   return a.expiryDate.compareTo(b.expiryDate);
                });

                int getCategoryCount(String category) {
                  if (category == 'All') return filteredItems.length;
                  return filteredItems.where((i) => i.category == category).length;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      ExpirationSummaryCard(
                        expiringSoonCount: expiringSoonCount,
                        expiredCount: expiredCount,
                        totalCount: items.length,
                        isExpanded: _showExpiringDetails,
                        onReviewTap: () {
                          setState(() {
                            _showExpiringDetails = !_showExpiringDetails;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Search Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white54 : Colors.black, 
                            width: 2
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: l10n.searchPlaceholder,
                            hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: theme.iconTheme.color ?? (isDark ? Colors.white : Colors.black)),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: theme.iconTheme.color ?? (isDark ? Colors.white : Colors.black)),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Expiring Soon Section (Horizontal) - Toggle visibility
                      if (_showExpiringDetails && expiringItems.isNotEmpty) ...[
                        Text(
                          l10n.expiringSoonTitle,
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180, // Height for horizontal cards
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: expiringItems.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 280,
                                child: BoldItemCard(
                                  item: expiringItems[index],
                                  index: index,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddItemScreen(item: expiringItems[index]),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // All Items Section Header with Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.allItems,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => _isGridView = false),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: !_isGridView 
                                          ? (isDark ? Colors.grey[700] : Colors.white) 
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: !_isGridView ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ] : [],
                                    ),
                                    child: Icon(
                                      Icons.list,
                                      size: 20,
                                      color: !_isGridView 
                                          ? (isDark ? Colors.white : Colors.black) 
                                          : (isDark ? Colors.grey[400] : Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => setState(() => _isGridView = true),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _isGridView 
                                          ? (isDark ? Colors.grey[700] : Colors.white) 
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: _isGridView ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ] : [],
                                    ),
                                    child: Icon(
                                      Icons.grid_view,
                                      size: 20,
                                      color: _isGridView 
                                          ? (isDark ? Colors.white : Colors.black) 
                                          : (isDark ? Colors.grey[400] : Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Category Filter
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            _buildCategoryChip(context, 'All', '${l10n.categoryAll} (${getCategoryCount('All')})'),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Consumer<ItemProvider>(
                                builder: (context, provider, child) {
                                  return ReorderableListView(
                                    scrollDirection: Axis.horizontal,
                                    onReorder: (oldIndex, newIndex) {
                                      provider.reorderCategories(oldIndex, newIndex);
                                    },
                                    proxyDecorator: (child, index, animation) {
                                      return Material(
                                        color: Colors.transparent,
                                        child: child,
                                      );
                                    },
                                    children: provider.categories.map((c) {
                                      return Container(
                                        key: ValueKey(c.name),
                                        margin: const EdgeInsets.only(right: 12),
                                        child: _buildCategoryChip(
                                          context, 
                                          c.name, 
                                          '${Category.getLocalizedName(context, c.name)} (${getCategoryCount(c.name)})'
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (otherItems.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noItems,
                                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        _isGridView 
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75, // Adjust as needed for card height
                            ),
                            itemCount: otherItems.length,
                            itemBuilder: (context, index) {
                              return GridItemCard(
                                item: otherItems[index],
                                index: index,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddItemScreen(item: otherItems[index]),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: otherItems.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return BoldItemCard(
                                item: otherItems[index],
                                index: index,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddItemScreen(item: otherItems[index]),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                    ],
                  ),
                );
              },
            ),
            
            // Overlay to close FAB when clicking outside (Transparent now)
            if (_isFabExpanded)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleFab,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    color: Colors.transparent, // Removed gray overlay
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Avoid overlap with BottomNavBar
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isFabExpanded) ...[
              SlideTransition(
                position: _fabSlideAnimation,
                child: ScaleTransition(
                  scale: _fabScaleAnimation,
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      _buildFabOption(
                        context,
                        icon: Icons.auto_awesome,
                        label: l10n.aiRecognition,
                        onTap: () {
                          _toggleFab();
                          // TODO: Implement AI Recognition
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('AI 识别功能开发中...')),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildFabOption(
                        context,
                        icon: Icons.camera_alt_outlined,
                        label: l10n.scanReceipt,
                        onTap: () {
                          _toggleFab();
                          _handleScan(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildFabOption(
                        context,
                        icon: Icons.edit_note_outlined,
                        label: l10n.manualInput,
                        onTap: () {
                          _toggleFab();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddItemScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              ),
            ],
            FloatingActionButton(
              onPressed: _toggleFab,
              backgroundColor: Colors.black,
              elevation: 0,
              shape: const CircleBorder(),
              child: RotationTransition(
                turns: _fabRotateAnimation,
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white54 : Colors.black, 
            width: 2
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.iconTheme.color ?? (isDark ? Colors.white : Colors.black), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String id, String label) {
    final isSelected = _selectedCategory == id;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? theme.colorScheme.primary : Colors.black) 
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white54 : Colors.black, 
            width: 2
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? (isDark ? Colors.black : Colors.white) 
                : theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
