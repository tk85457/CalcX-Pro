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

  Future<void> _loadSettings() async {
    try {
      final box = await Hive.openBox(_settingsBoxName);
      _selectedThemeIndex = box.get(_themeIndexKey, defaultValue: 0);
      _autoCalculate = box.get(_autoCalculateKey, defaultValue: true);
      _currencyApiKey = box.get(_apiKeyKey, defaultValue: '');
    } catch (e) {
      // If there's an error loading settings, use defaults and try to create box
      try {
        final box = await Hive.openBox(_settingsBoxName);
        _selectedThemeIndex = box.get(_themeIndexKey, defaultValue: 0);
        _autoCalculate = box.get(_autoCalculateKey, defaultValue: true);
        _currencyApiKey = box.get(_apiKeyKey, defaultValue: '');
      } catch (error) {
        // Use defaults if all else fails
        _selectedThemeIndex = 0;
        _autoCalculate = true;
        _currencyApiKey = '';
      }
    }
    notifyListeners();
  }

  Future<void> setSelectedTheme(int index) async {
    if (index >= 0 && index < themeOptions.length) {
      _selectedThemeIndex = index;
      final box = await Hive.openBox(_settingsBoxName);
      await box.put(_themeIndexKey, index);
      notifyListeners();
    }
  }

  Future<void> toggleAutoCalculate() async {
    _autoCalculate = !_autoCalculate;
    final box = await Hive.openBox(_settingsBoxName);
    await box.put(_autoCalculateKey, _autoCalculate);
    notifyListeners();
  }

  Future<void> setCurrencyApiKey(String apiKey) async {
    _currencyApiKey = apiKey.trim();
    final box = await Hive.openBox(_settingsBoxName);
    await box.put(_apiKeyKey, _currencyApiKey);
    notifyListeners();
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
