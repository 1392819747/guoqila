// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '期限切れ';

  @override
  String get home => 'ホーム';

  @override
  String get stats => '統計';

  @override
  String get settings => '設定';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get totalItems => '総アイテム数';

  @override
  String get expired => '期限切れ';

  @override
  String get expiringSoon => '期限間近';

  @override
  String get searchPlaceholder => '検索...';

  @override
  String get sortExpiryDate => '有効期限';

  @override
  String get sortName => '名前';

  @override
  String get sortPurchaseDate => '購入日';

  @override
  String get allItems => 'すべてのアイテム';

  @override
  String get noItems => 'アイテムがありません。追加してください！';

  @override
  String get addItem => 'アイテムを追加';

  @override
  String get editItem => 'アイテムを編集';

  @override
  String get name => '名前';

  @override
  String get category => 'カテゴリー';

  @override
  String get expiryDate => '有効期限';

  @override
  String get purchaseDate => '購入日';

  @override
  String get note => 'メモ';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get categoryFood => '食品';

  @override
  String get categoryMedicine => '医薬品';

  @override
  String get categoryCosmetics => '化粧品';

  @override
  String get categoryDocuments => '書類';

  @override
  String get categoryElectronics => '電子機器';

  @override
  String get categoryOthers => 'その他';

  @override
  String daysLeft(int days) {
    return '残り $days 日';
  }

  @override
  String get aiAssistant => 'AI\nアシスタント';

  @override
  String itemsCount(String count, String total) {
    return '$count / $total アイテム';
  }

  @override
  String get categoryAll => 'すべて';

  @override
  String get notificationTitleSoon => '期限が近づいています';

  @override
  String notificationBodySoon(String item) {
    return '$item は3日後に期限切れになります！';
  }

  @override
  String get notificationTitleExpired => '期限切れ';

  @override
  String notificationBodyExpired(String item) {
    return '$item は今日期限切れになりました！';
  }

  @override
  String get settingsGeneral => '一般';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotificationsSubtitle => '期限切れのアラートを受け取る';

  @override
  String get settingsDataManagement => 'データ管理';

  @override
  String get settingsClearData => 'すべてのデータを消去';

  @override
  String get settingsClearDataSubtitle => 'すべてのアイテムを完全に削除します';

  @override
  String get settingsLanguage => '言語';

  @override
  String get dialogClearDataTitle => 'すべてのデータを消去しますか？';

  @override
  String get dialogClearDataContent => 'この操作は取り消せません。すべてのアイテムが削除されます。';

  @override
  String get dialogDelete => '削除';

  @override
  String get snackBarDataCleared => 'データが消去されました';

  @override
  String get statistics => '統計';

  @override
  String get categoryDistribution => 'カテゴリー分布';
}
