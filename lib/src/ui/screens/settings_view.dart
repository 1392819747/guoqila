import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../models/category.dart';
import '../../providers/item_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/bold_dialog.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                l10n.settings,
                style: AppTextStyles.displayLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.displayLarge?.color,
                ),
              ),
              const SizedBox(height: 32),
              
              // Notification Section
              _buildSectionTitle(context, '通知设置'),
              const SizedBox(height: 16),
              _buildNotificationSettings(context),
              const SizedBox(height: 32),
              
              // Category Management
              _buildSectionTitle(context, '分类管理'),
              const SizedBox(height: 16),
              _buildCategoryManagement(context),
              const SizedBox(height: 32),
              
              // Data Management
              _buildSectionTitle(context, '数据管理'),
              const SizedBox(height: 16),
              _buildDataManagement(context),
              const SizedBox(height: 32),
              
              // Language Section
              _buildSectionTitle(context, '语言 / Language'),
              const SizedBox(height: 16),
              _buildLanguageSelector(context),
              const SizedBox(height: 32),
              
              // About
              _buildSectionTitle(context, '关于'),
              const SizedBox(height: 16),
              _buildAboutSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: 18,
        color: theme.textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final languages = [
      {'code': 'zh', 'name': '简体中文', 'flag': '🇨🇳'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
      {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    ];
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white54 : Colors.black, 
          width: 2
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: languages.asMap().entries.map((entry) {
          final index = entry.key;
          final lang = entry.value;
          final isSelected = currentLocale?.languageCode == lang['code'];
          final isFirst = index == 0;
          final isLast = index == languages.length - 1;
          
          return InkWell(
            onTap: () {
              localeProvider.setLocale(Locale(lang['code']!));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? (isDark ? theme.colorScheme.primary : Colors.black) 
                    : Colors.transparent,
                borderRadius: BorderRadius.vertical(
                  top: isFirst ? const Radius.circular(18) : Radius.zero,
                  bottom: isLast ? const Radius.circular(18) : Radius.zero,
                ),
                border: !isLast ? Border(bottom: BorderSide(color: isDark ? Colors.white24 : Colors.grey, width: 1)) : null,
              ),
              child: Row(
                children: [
                  Text(
                    lang['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lang['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? (isDark ? Colors.black : Colors.white) 
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, color: isDark ? Colors.black : Colors.white),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white54 : Colors.black, 
              width: 2
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '启用通知',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Switch(
                    value: settings.notificationsEnabled,
                    onChanged: settings.setNotificationsEnabled,
                    activeColor: AppColors.secondary,
                  ),
                ],
              ),
              if (settings.notificationsEnabled) ...[
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '提前提醒天数',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    DropdownButton<int>(
                      value: settings.notificationDays,
                      dropdownColor: theme.colorScheme.surface,
                      items: [1, 3, 7, 14].map((days) {
                        return DropdownMenuItem(
                          value: days,
                          child: Text(
                            '$days 天',
                            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          settings.setNotificationDays(value);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '通知时间',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: settings.notificationTime,
                        );
                        if (time != null) {
                          settings.setNotificationTime(time);
                        }
                      },
                      child: Text(
                        settings.notificationTime.format(context),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryManagement(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white54 : Colors.black, 
              width: 2
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '自定义分类',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: theme.iconTheme.color),
                    onPressed: () => _showAddCategoryDialog(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                '长按分类可删除',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.categories.map((category) {
                  final localizedName = Category.getLocalizedName(context, category.name);
                  return GestureDetector(
                    onLongPress: () {
                      _showDeleteCategoryDialog(context, category.name);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : AppColors.grey100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white54 : Colors.black, 
                          width: 1
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon, size: 16, color: theme.iconTheme.color),
                          const SizedBox(width: 4),
                          Text(
                            localizedName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataManagement(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white54 : Colors.black, 
          width: 2
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.file_upload_outlined, color: theme.iconTheme.color),
            title: Text('导出数据', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color),
            onTap: () => _exportData(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.file_download_outlined, color: theme.iconTheme.color),
            title: Text('导入数据', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color),
            onTap: () => _importData(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('清空所有数据', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
            onTap: () => _clearAllData(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white54 : Colors.black, 
          width: 2
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          Text(
            '不许过期',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.w900,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text(
            '一款帮助你管理物品保质期的应用',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => BoldDialog(
        title: '添加分类',
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入分类名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          BoldDialogButton(
            text: '取消',
            onPressed: () => Navigator.pop(context),
          ),
          BoldDialogButton(
            text: '添加',
            isPrimary: true,
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<ItemProvider>().addCategory(controller.text);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, String categoryName) {
    showDialog(
      context: context,
      builder: (context) => BoldDialog(
        title: '删除分类',
        content: Text('确定要删除分类 "$categoryName" 吗？'),
        actions: [
          BoldDialogButton(
            text: '取消',
            onPressed: () => Navigator.pop(context),
          ),
          BoldDialogButton(
            text: '删除',
            textColor: Colors.red,
            onPressed: () {
              context.read<ItemProvider>().deleteCategory(categoryName);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final provider = context.read<ItemProvider>();
      final items = provider.items;
      
      // Convert items to JSON
      final jsonData = jsonEncode({
        'items': items.map((item) => {
          'id': item.id,
          'name': item.name,
          'category': item.category,
          'expiryDate': item.expiryDate.toIso8601String(),
          'purchaseDate': item.purchaseDate.toIso8601String(),
          'note': item.note,
          'imagePath': item.imagePath,
        }).toList(),
        'exportDate': DateTime.now().toIso8601String(),
      });
      
      // Save to temp file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/expiry_data_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonData);
      
      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '过期啦数据导出',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据导出成功！')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入功能开发中...')),
    );
  }

  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BoldDialog(
        title: '清空所有数据',
        content: const Text('此操作将永久删除所有物品数据，无法恢复！\n\n确定要继续吗？'),
        actions: [
          BoldDialogButton(
            text: '取消',
            onPressed: () => Navigator.pop(context),
          ),
          BoldDialogButton(
            text: '清空',
            textColor: Colors.red,
            onPressed: () {
              context.read<ItemProvider>().clearAllItems();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('所有数据已清空')),
              );
            },
          ),
        ],
      ),
    );
  }
}
