import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime expiryDate;

  @HiveField(4)
  DateTime purchaseDate;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final String? imagePath; // Product image path

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.expiryDate,
    required this.purchaseDate,
    this.note,
    this.imagePath,
  });

  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  bool get isExpired => daysUntilExpiry < 0;
}
