// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '过期啦';

  @override
  String get home => '首页';

  @override
  String get stats => '统计';

  @override
  String get settings => '设置';

  @override
  String get dashboard => '概览';

  @override
  String get totalItems => '物品总数';

  @override
  String get expired => '已过期';

  @override
  String get expiringSoon => '即将过期';

  @override
  String get searchPlaceholder => '搜索物品...';

  @override
  String get sortExpiryDate => '到期日期';

  @override
  String get sortName => '名称';

  @override
  String get sortPurchaseDate => '购买日期';

  @override
  String get allItems => '所有物品';

  @override
  String get noItems => '暂无物品，快去添加吧！';

  @override
  String get addItem => '添加物品';

  @override
  String get editItem => '编辑物品';

  @override
  String get name => '名称';

  @override
  String get category => '分类';

  @override
  String get expiryDate => '到期日期';

  @override
  String get purchaseDate => '购买日期';

  @override
  String get note => '备注';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get categoryFood => '食品';

  @override
  String get categoryMedicine => '药品';

  @override
  String get categoryCosmetics => '化妆品';

  @override
  String get categoryDocuments => '证件';

  @override
  String get categoryElectronics => '电子产品';

  @override
  String get categoryOthers => '其他';

  @override
  String daysLeft(int days) {
    return '剩余 $days 天';
  }

  @override
  String get aiAssistant => '包含\nAI 助手';

  @override
  String itemsCount(String count, String total) {
    return '$count / $total 物品';
  }

  @override
  String get categoryAll => '全部';

  @override
  String get notificationTitleSoon => '物品即将过期';

  @override
  String notificationBodySoon(String item) {
    return '$item 将在3天后过期！';
  }

  @override
  String get notificationTitleExpired => '物品已过期';

  @override
  String notificationBodyExpired(String item) {
    return '$item 今天过期了！';
  }

  @override
  String get settingsGeneral => '通用';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotificationsSubtitle => '接收过期提醒';

  @override
  String get settingsDataManagement => '数据管理';

  @override
  String get settingsClearData => '清除所有数据';

  @override
  String get settingsClearDataSubtitle => '永久删除所有物品';

  @override
  String get settingsLanguage => '语言';

  @override
  String get dialogClearDataTitle => '清除所有数据？';

  @override
  String get dialogClearDataContent => '此操作无法撤销。所有物品将被删除。';

  @override
  String get dialogDelete => '删除';

  @override
  String get snackBarDataCleared => '数据已清除';

  @override
  String get statistics => '统计分析';

  @override
  String get categoryDistribution => '分类分布';
}
