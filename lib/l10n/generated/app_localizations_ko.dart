// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '만료 추적기';

  @override
  String get home => '홈';

  @override
  String get stats => '통계';

  @override
  String get settings => '설정';

  @override
  String get dashboard => '대시보드';

  @override
  String get totalItems => '총 항목';

  @override
  String get expired => '만료됨';

  @override
  String get expiringSoon => '곧 만료됨';

  @override
  String get searchPlaceholder => '검색...';

  @override
  String get sortExpiryDate => '유통 기한';

  @override
  String get sortName => '이름';

  @override
  String get sortPurchaseDate => '구매 날짜';

  @override
  String get allItems => '모든 항목';

  @override
  String get noItems => '항목이 없습니다. 추가해주세요!';

  @override
  String get addItem => '항목 추가';

  @override
  String get editItem => '항목 편집';

  @override
  String get name => '이름';

  @override
  String get category => '카테고리';

  @override
  String get expiryDate => '유통 기한';

  @override
  String get purchaseDate => '구매 날짜';

  @override
  String get note => '메모';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get categoryFood => '식품';

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get categoryMeat => 'Meat';

  @override
  String get categoryMedicine => '의약품';

  @override
  String get categoryCosmetics => '화장품';

  @override
  String get categoryDocuments => '문서';

  @override
  String get categoryElectronics => '전자제품';

  @override
  String get categoryOthers => '기타';

  @override
  String get categoryBeverages => 'Beverages';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryHousehold => 'Household';

  @override
  String get categoryPetSupplies => 'Pet Supplies';

  @override
  String get actionNeeded => 'Action Needed';

  @override
  String expiredItemsCount(int count) {
    return '$count items have expired';
  }

  @override
  String get expiringSoonTitle => 'Expiring Soon';

  @override
  String expiringSoonItemsCount(int count) {
    return '$count items need attention';
  }

  @override
  String get allFresh => 'All Fresh';

  @override
  String allFreshSubtitle(int count) {
    return 'You have $count healthy items';
  }

  @override
  String get review => 'Review';

  @override
  String daysLeft(int days) {
    return '$days일 남음';
  }

  @override
  String get aiAssistant => 'AI\n어시스턴트';

  @override
  String itemsCount(String count, String total) {
    return '$count / $total 항목';
  }

  @override
  String get categoryAll => '전체';

  @override
  String get notificationTitleSoon => '만료 임박';

  @override
  String notificationBodySoon(String item) {
    return '$item 3일 후 만료됩니다!';
  }

  @override
  String get notificationTitleExpired => '만료됨';

  @override
  String notificationBodyExpired(String item) {
    return '$item 오늘 만료되었습니다!';
  }

  @override
  String get settingsGeneral => '일반';

  @override
  String get settingsNotifications => '알림';

  @override
  String get settingsNotificationsSubtitle => '만료 알림 받기';

  @override
  String get settingsDataManagement => '데이터 관리';

  @override
  String get settingsClearData => '모든 데이터 지우기';

  @override
  String get settingsClearDataSubtitle => '모든 항목 영구 삭제';

  @override
  String get settingsLanguage => '언어';

  @override
  String get dialogClearDataTitle => '모든 데이터를 지우시겠습니까?';

  @override
  String get dialogClearDataContent => '이 작업은 취소할 수 없습니다. 모든 항목이 삭제됩니다.';

  @override
  String get dialogDelete => '삭제';

  @override
  String get snackBarDataCleared => '데이터가 삭제되었습니다';

  @override
  String get statistics => '통계';

  @override
  String get categoryDistribution => '카테고리 분포';

  @override
  String get addCategory => 'Add Category';

  @override
  String get newCategoryName => 'New Category Name';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String deleteCategoryConfirm(Object category) {
    return 'Are you sure you want to delete category \"$category\"?';
  }

  @override
  String get add => 'Add';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String get manualInput => 'Manual Input';
}
