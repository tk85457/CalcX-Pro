class AppTheme {
  final String name;
  final bool isDark;
  final int primaryColor;
  final int secondaryColor;
  final int backgroundColor;
  final int surfaceColor;
  final int onPrimaryColor;
  final int onSecondaryColor;
  final int onBackgroundColor;
  final int onSurfaceColor;

  AppTheme({
    required this.name,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.onPrimaryColor,
    required this.onSecondaryColor,
    required this.onBackgroundColor,
    required this.onSurfaceColor,
  });

  AppTheme copyWith({
    String? name,
    bool? isDark,
    int? primaryColor,
    int? secondaryColor,
    int? backgroundColor,
    int? surfaceColor,
    int? onPrimaryColor,
    int? onSecondaryColor,
    int? onBackgroundColor,
    int? onSurfaceColor,
  }) {
    return AppTheme(
      name: name ?? this.name,
      isDark: isDark ?? this.isDark,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      onPrimaryColor: onPrimaryColor ?? this.onPrimaryColor,
      onSecondaryColor: onSecondaryColor ?? this.onSecondaryColor,
      onBackgroundColor: onBackgroundColor ?? this.onBackgroundColor,
      onSurfaceColor: onSurfaceColor ?? this.onSurfaceColor,
    );
  }
}
