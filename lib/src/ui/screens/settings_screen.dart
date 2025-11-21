import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/item_provider.dart';
import '../../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settings, style: AppTextStyles.displayMedium.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 32),
              _buildSectionHeader(l10n.settingsGeneral),
              const SizedBox(height: 16),
              _buildSettingTile(
                title: l10n.settingsNotifications,
                subtitle: l10n.settingsNotificationsSubtitle,
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                  activeColor: Colors.black,
                  activeTrackColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingTile(
                title: l10n.settingsLanguage,
                subtitle: _getLanguageName(context.watch<LocaleProvider>().locale.languageCode),
                trailing: const Icon(Icons.chevron_right, color: Colors.black),
                onTap: () => _showLanguageDialog(context),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(l10n.settingsDataManagement),
              const SizedBox(height: 16),
              _buildSettingTile(
                title: l10n.settingsClearData,
                subtitle: l10n.settingsClearDataSubtitle,
                trailing: const Icon(Icons.chevron_right, color: Colors.black),
                onTap: () => _showClearDataDialog(context),
                isDestructive: true,
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'zh': return '中文';
      case 'ja': return '日本語';
      case 'ko': return '한국어';
      default: return 'English';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'English', 'en'),
            _buildLanguageOption(context, '中文', 'zh'),
            _buildLanguageOption(context, '日本語', 'ja'),
            _buildLanguageOption(context, '한국어', 'ko'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code) {
    final isSelected = context.read<LocaleProvider>().locale.languageCode == code;
    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: Colors.black,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.black) : null,
      onTap: () {
        context.read<LocaleProvider>().setLocale(Locale(code));
        Navigator.pop(context);
      },
    );
  }

  void _showClearDataDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        title: Text(l10n.dialogClearDataTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(l10n.dialogClearDataContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              context.read<ItemProvider>().clearAllItems();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.snackBarDataCleared)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.dialogDelete, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
