// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expiry Tracker';

  @override
  String get home => 'Home';

  @override
  String get stats => 'Stats';

  @override
  String get settings => 'Settings';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get totalItems => 'Total Items';

  @override
  String get expired => 'Expired';

  @override
  String get expiringSoon => 'Expiring Soon';

  @override
  String get searchPlaceholder => 'Search items...';

  @override
  String get sortExpiryDate => 'Expiry Date';

  @override
  String get sortName => 'Name';

  @override
  String get sortPurchaseDate => 'Purchase Date';

  @override
  String get allItems => 'All Items';

  @override
  String get noItems => 'No items yet. Add one!';

  @override
  String get addItem => 'Add Item';

  @override
  String get editItem => 'Edit Item';

  @override
  String get name => 'Name';

  @override
  String get category => 'Category';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get purchaseDate => 'Purchase Date';

  @override
  String get note => 'Note';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryMedicine => 'Medicine';

  @override
  String get categoryCosmetics => 'Cosmetics';

  @override
  String get categoryDocuments => 'Documents';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryOthers => 'Others';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String get aiAssistant => 'Includes\nAI Assistant';

  @override
  String itemsCount(String count, String total) {
    return '$count / $total items';
  }

  @override
  String get categoryAll => 'All';

  @override
  String get notificationTitleSoon => 'Item Expiring Soon';

  @override
  String notificationBodySoon(String item) {
    return '$item expires in 3 days!';
  }

  @override
  String get notificationTitleExpired => 'Item Expired';

  @override
  String notificationBodyExpired(String item) {
    return '$item has expired today!';
  }

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Receive alerts for expiring items';

  @override
  String get settingsDataManagement => 'Data Management';

  @override
  String get settingsClearData => 'Clear All Data';

  @override
  String get settingsClearDataSubtitle => 'Delete all items permanently';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get dialogClearDataTitle => 'Clear All Data?';

  @override
  String get dialogClearDataContent =>
      'This action cannot be undone. All your items will be deleted.';

  @override
  String get dialogDelete => 'Delete';

  @override
  String get snackBarDataCleared => 'All data cleared';

  @override
  String get statistics => 'Statistics';

  @override
  String get categoryDistribution => 'Category Distribution';
}
