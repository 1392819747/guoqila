import 'package:hive_flutter/hive_flutter.dart';
import '../models/item.dart';

class StorageService {
  static const String _boxName = 'items';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ItemAdapter());
    await Hive.openBox<Item>(_boxName);
  }

  Box<Item> get _box => Hive.box<Item>(_boxName);

  List<Item> getAllItems() {
    return _box.values.toList();
  }

  Future<void> addItem(Item item) async {
    await _box.put(item.id, item);
  }

  Future<void> updateItem(Item item) async {
    await item.save();
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }
  
  Future<void> clearAll() async {
    await _box.clear();
  }
}
