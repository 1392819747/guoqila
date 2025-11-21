import 'package:hive_flutter/hive_flutter.dart';
import '../models/item.dart';

class StorageService {
  static const String _boxName = 'items';
  static const String _categoryBoxName = 'categories';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ItemAdapter());
    await Hive.openBox<Item>(_boxName);
    await Hive.openBox<List<String>>(_categoryBoxName);
  }

  Box<Item> get _box => Hive.box<Item>(_boxName);
  Box<List<String>> get _categoryBox => Hive.box<List<String>>(_categoryBoxName);

  List<Item> getAllItems() {
    return _box.values.toList();
  }

  Future<void> addItem(Item item) async {
    await _box.put(item.id, item);
  }

  Future<void> updateItem(Item item) async {
    // Use put instead of save() to avoid "not in box" error with newly created Item objects
    await _box.put(item.id, item);
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }
  
  Future<void> clearAll() async {
    await _box.clear();
  }

  // Category Methods
  List<String> getCategories() {
    return _categoryBox.get('list') ?? [];
  }

  Future<void> saveCategories(List<String> categories) async {
    await _categoryBox.put('list', categories);
  }
}
