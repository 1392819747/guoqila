import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

enum SortOption { expiryDate, name, purchaseDate }

class ItemProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;
  List<Item> _items = [];

  ItemProvider(this._storageService, this._notificationService) {
    _loadItems();
  }

  String? _selectedCategory;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.expiryDate;

  List<Item> get items {
    var filtered = _items;
    
    if (_selectedCategory != null) {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) => 
        item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    switch (_sortOption) {
      case SortOption.expiryDate:
        filtered.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        break;
      case SortOption.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.purchaseDate:
        filtered.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        break;
    }

    return filtered;
  }

  String? get selectedCategory => _selectedCategory;
  SortOption get sortOption => _sortOption;

  void selectCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

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
    await _notificationService.scheduleNotification(item);
    _loadItems();
  }

  Future<void> updateItem(Item item) async {
    await _storageService.updateItem(item);
    await _notificationService.scheduleNotification(item);
    _loadItems();
  }

  Future<void> deleteItem(String id) async {
    final item = _items.firstWhere((i) => i.id == id);
    await _notificationService.cancelNotification(item);
    await _storageService.deleteItem(id);
    _loadItems();
  }

  Future<void> clearAllItems() async {
    await _notificationService.cancelAllNotifications();
    await _storageService.clearAll();
    _loadItems();
  }
}
