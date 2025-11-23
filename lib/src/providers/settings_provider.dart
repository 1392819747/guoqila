import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  
  // Notification settings
  bool _notificationsEnabled = true;
  int _notificationDays = 3; // Days before expiry to notify
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  
  // Theme settings
  bool _isDarkMode = false;
  
  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationDays => _notificationDays;
  TimeOfDay get notificationTime => _notificationTime;
  bool get isDarkMode => _isDarkMode;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }
  
  void _loadSettings() {
    _notificationsEnabled = _prefs?.getBool('notifications_enabled') ?? true;
    _notificationDays = _prefs?.getInt('notification_days') ?? 3;
    
    final hour = _prefs?.getInt('notification_hour') ?? 9;
    final minute = _prefs?.getInt('notification_minute') ?? 0;
    _notificationTime = TimeOfDay(hour: hour, minute: minute);
    
    _isDarkMode = _prefs?.getBool('dark_mode') ?? false;
    
    notifyListeners();
  }
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs?.setBool('notifications_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setNotificationDays(int days) async {
    _notificationDays = days;
    await _prefs?.setInt('notification_days', days);
    notifyListeners();
  }
  
  Future<void> setNotificationTime(TimeOfDay time) async {
    _notificationTime = time;
    await _prefs?.setInt('notification_hour', time.hour);
    await _prefs?.setInt('notification_minute', time.minute);
    notifyListeners();
  }
  
  Future<void> setDarkMode(bool enabled) async {
    _isDarkMode = enabled;
    await _prefs?.setBool('dark_mode', enabled);
    notifyListeners();
  }
}
