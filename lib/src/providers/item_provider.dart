import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/storage_service.dart';

class ItemProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<Item> _items = [];

  ItemProvider(this._storageService) {
    _loadItems();
  }

  List<Item> get items => _items;

  List<Item> get expiringSoonItems {
    final now = DateTime.now();
    final threeDaysFromNow = now.add(const Duration(days: 3));
    return _items.where((item) {
      return !item.isExpired && item.expiryDate.isBefore(threeDaysFromNow);
    }).toList();
  }
  
  List<Item> get expiredItems {
    return _items.where((item) => item.isExpired).toList();
  }

  void _loadItems() {
    _items = _storageService.getAllItems();
    _sortItems();
    notifyListeners();
  }

  void _sortItems() {
    _items.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
  }

  Future<void> addItem(Item item) async {
    await _storageService.addItem(item);
    _loadItems();
  }

  Future<void> updateItem(Item item) async {
    await _storageService.updateItem(item);
    _loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _storageService.deleteItem(id);
    _loadItems();
  }
}
