import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/theme_model.dart';
import '../utils/constants.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeBox = 'theme';
  static const String _themeIndexKey = 'themeIndex';

  late AppTheme _appTheme;
  int _selectedThemeIndex = 0;
  bool _isInitialized = false;

  AppTheme get appTheme => _appTheme;
  int get selectedThemeIndex => _selectedThemeIndex;
  bool get isInitialized => _isInitialized;

  // Legacy getters for backward compatibility
  bool get isDark => _appTheme.isDark;
  Color get primaryColor => Color(_appTheme.primaryColor);

  ThemeProvider() {
    // Default to first theme (Ocean Blue Light)
    _appTheme = AppConstants.predefinedThemes[0];
  }

  Future<void> init() async {
    if (_isInitialized) return; // Prevent multiple initializations

    final box = await Hive.openBox(_themeBox);
    final themeIndex = box.get(_themeIndexKey, defaultValue: 0);

    // Ensure theme index is valid
    _selectedThemeIndex =
        (themeIndex >= 0 && themeIndex < AppConstants.predefinedThemes.length)
            ? themeIndex
            : 0;

    _appTheme = AppConstants.predefinedThemes[_selectedThemeIndex];
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setTheme(int index) async {
    if (index < 0 || index >= AppConstants.predefinedThemes.length) return;

    _selectedThemeIndex = index;
    _appTheme = AppConstants.predefinedThemes[index];

    final box = await Hive.openBox(_themeBox);
    await box.put(_themeIndexKey, index);
    notifyListeners();
  }

  // Legacy methods for backward compatibility
  Future<void> toggleTheme() async {
    // Toggle between light and dark versions of current theme
    final currentThemeName =
        _appTheme.name.replaceAll(' Dark', '').replaceAll(' Light', '');
    final isCurrentlyDark = _appTheme.isDark;
    final targetThemeName =
        isCurrentlyDark ? currentThemeName : '$currentThemeName Dark';

    // Find the target theme
    final targetIndex = AppConstants.predefinedThemes
        .indexWhere((theme) => theme.name == targetThemeName);

    if (targetIndex != -1) {
      await setTheme(targetIndex);
    }
  }

  Future<void> setPrimaryColor(Color color) async {
    // For backward compatibility, find a theme with similar primary color
    final closestThemeIndex = AppConstants.predefinedThemes
        .indexWhere((theme) => Color(theme.primaryColor) == color);

    if (closestThemeIndex != -1) {
      await setTheme(closestThemeIndex);
    }
  }

  ThemeData get theme => _generateThemeData();

  ThemeData _generateThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: _appTheme.isDark ? Brightness.dark : Brightness.light,
        primary: Color(_appTheme.primaryColor),
        onPrimary: Color(_appTheme.onPrimaryColor),
        secondary: Color(_appTheme.secondaryColor),
        onSecondary: Color(_appTheme.onSecondaryColor),
        surface: Color(_appTheme.surfaceColor),
        onSurface: Color(_appTheme.onSurfaceColor),
        error: Colors.red,
        onError: Colors.white,
        surfaceContainer: Color(_appTheme.surfaceColor),
        surfaceContainerHigh: _appTheme.isDark
            ? Color(_appTheme.surfaceColor).withValues(alpha: 0.8)
            : Color(_appTheme.surfaceColor).withValues(alpha: 0.9),
        surfaceContainerLow: _appTheme.isDark
            ? Color(_appTheme.surfaceColor).withValues(alpha: 0.6)
            : Color(_appTheme.surfaceColor).withValues(alpha: 0.7),
      ),
      scaffoldBackgroundColor: Color(_appTheme.backgroundColor),
      cardColor: Color(_appTheme.surfaceColor),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Color(_appTheme.onBackgroundColor),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(_appTheme.onBackgroundColor).withValues(alpha: 0.87),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(_appTheme.primaryColor),
        foregroundColor: Color(_appTheme.onPrimaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(_appTheme.primaryColor),
          foregroundColor: Color(_appTheme.onPrimaryColor),
        ),
      ),
    );
  }
}
