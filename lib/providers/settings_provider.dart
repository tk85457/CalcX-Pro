import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsProvider extends ChangeNotifier {
  // Theme options
  static const List<String> themeOptions = [
    'Default',
    'Dark',
    'Light',
    'Blue',
    'Green',
    'Purple',
    'Red',
    'Orange',
    'Teal',
    'Pink',
    'Indigo',
  ];

  static const String _settingsBoxName = 'settings';
  static const String _themeIndexKey = 'selectedThemeIndex';
  static const String _autoCalculateKey = 'autoCalculate';
  static const String _apiKeyKey = 'currencyApiKey';

  int _selectedThemeIndex = 0;
  bool _autoCalculate = true;
  String _currencyApiKey = '';

  int get selectedThemeIndex => _selectedThemeIndex;
  bool get autoCalculate => _autoCalculate;
  String get currencyApiKey => _currencyApiKey;

  String get selectedThemeName => themeOptions[_selectedThemeIndex];

  SettingsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSettings();
  }

  Future<Box> _openSettingsBox() async {
    // If box is already open, return it directly — avoids double-open crash
    if (Hive.isBoxOpen(_settingsBoxName)) {
      return Hive.box(_settingsBoxName);
    }
    return await Hive.openBox(_settingsBoxName);
  }

  Future<void> _loadSettings() async {
    try {
      final box = await _openSettingsBox();
      _selectedThemeIndex = box.get(_themeIndexKey, defaultValue: 0) as int;
      _autoCalculate = box.get(_autoCalculateKey, defaultValue: true) as bool;
      _currencyApiKey = box.get(_apiKeyKey, defaultValue: '') as String;
    } catch (e) {
      // Use safe defaults if box open fails (e.g. corrupted on first install)
      _selectedThemeIndex = 0;
      _autoCalculate = true;
      _currencyApiKey = '';
    }
    notifyListeners();
  }

  Future<void> setSelectedTheme(int index) async {
    if (index >= 0 && index < themeOptions.length) {
      _selectedThemeIndex = index;
      notifyListeners();
      try {
        final box = await _openSettingsBox();
        await box.put(_themeIndexKey, index);
      } catch (_) {}
    }
  }

  Future<void> toggleAutoCalculate() async {
    _autoCalculate = !_autoCalculate;
    notifyListeners();
    try {
      final box = await _openSettingsBox();
      await box.put(_autoCalculateKey, _autoCalculate);
    } catch (_) {}
  }

  Future<void> setCurrencyApiKey(String apiKey) async {
    _currencyApiKey = apiKey.trim();
    notifyListeners();
    try {
      final box = await _openSettingsBox();
      await box.put(_apiKeyKey, _currencyApiKey);
    } catch (_) {}
  }

  // Get theme data based on selected theme
  ThemeData getThemeData() {
    switch (_selectedThemeIndex) {
      case 0: // Default (uses ThemeProvider)
        return ThemeData.light();
      case 1: // Dark
        return ThemeData.dark();
      case 2: // Light
        return ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 207, 229, 247),
            brightness: Brightness.light,
          ),
        );
      case 3: // Blue
        return ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        );
      case 4: // Green
        return ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        );
      case 5: // Purple
        return ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.light,
          ),
        );
      case 6: // Red
        return ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.light,
          ),
        );
      case 7: // Orange
        return ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.light,
          ),
        );
      case 8: // Teal
        return ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
        );
      case 9: // Pink
        return ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
            brightness: Brightness.light,
          ),
        );
      case 10: // Indigo
        return ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
        );
      default:
        return ThemeData.light();
    }
  }
}
