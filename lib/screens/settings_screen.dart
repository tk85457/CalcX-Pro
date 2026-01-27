import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/calculator_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Theme Controls Card
                  _buildAnimatedCard(
                    index: 0,
                    child: _buildThemeCard(context, colorScheme),
                  ),

                  const SizedBox(height: 16),

                  // Auto Calculate Toggle
                  _buildAnimatedCard(
                    index: 1,
                    child: _buildAutoCalculateCard(context, colorScheme),
                  ),

                  const SizedBox(height: 16),

                  // Currency API Key Section
                  _buildAnimatedCard(
                    index: 2,
                    child: _buildApiKeyCard(context, colorScheme, settingsProvider),
                  ),

                  const SizedBox(height: 16),

                  // About Section
                  _buildAnimatedCard(
                    index: 3,
                    child: _buildAboutCard(context, colorScheme),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    final staggerDelay = (index * 0.12).clamp(0.0, 0.5);
    final staggerEnd = (staggerDelay + 0.4).clamp(0.0, 1.0);

    double progress = 0.0;
    if (_animation.value > staggerDelay) {
      progress = ((_animation.value - staggerDelay) / (staggerEnd - staggerDelay)).clamp(0.0, 1.0);
    }

    return Transform.translate(
      offset: Offset(0, 30 * (1 - progress)),
      child: Opacity(
        opacity: progress,
        child: Transform.scale(
          scale: 0.95 + (0.05 * progress),
          child: child,
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.palette,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Theme Controls',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dark Mode Toggle with custom animation
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _AnimatedSwitchTile(
                      title: 'Dark Mode',
                      subtitle: 'Toggle between light and dark theme',
                      icon: themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                      value: themeProvider.isDark,
                      onChanged: (value) => themeProvider.toggleTheme(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Theme Selection header
                Text(
                  'Theme Selection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                // Animated Theme Grid
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: AppConstants.predefinedThemes.length,
                      itemBuilder: (context, index) {
                        final theme = AppConstants.predefinedThemes[index];
                        final isSelected = themeProvider.selectedThemeIndex == index;

                        return _AnimatedThemeTile(
                          theme: theme,
                          isSelected: isSelected,
                          onTap: () => themeProvider.setTheme(index),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoCalculateCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<CalculatorProvider>(
          builder: (context, calculatorProvider, child) {
            return _AnimatedSwitchTile(
              title: 'Auto Calculate',
              subtitle: 'Automatically calculate results as you type',
              icon: Icons.calculate,
              value: calculatorProvider.autoCalculate,
              onChanged: (value) => calculatorProvider.toggleAutoCalculate(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildApiKeyCard(BuildContext context, ColorScheme colorScheme, SettingsProvider settingsProvider) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.secondaryContainer,
                  colorScheme.secondaryContainer.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.vpn_key,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Currency API',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: TextEditingController(
                    text: settingsProvider.currencyApiKey,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Currency API Key',
                    hintText: 'Enter your exchangerate-api.com API key',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.key),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  obscureText: true,
                  onChanged: (value) => settingsProvider.setCurrencyApiKey(value),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get your free API key from exchangerate-api.com',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.tertiaryContainer,
                  colorScheme.tertiaryContainer.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/icon/app_icon.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CalcX Pro',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'A premium calculator app with advanced features',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAboutDialog(context),
                    icon: const Icon(Icons.info),
                    label: const Text('View Details'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About CalcX Pro'),
        content: const Text(
          'CalcX Pro is a premium calculator app with basic, scientific, and advanced calculators.\n\n'
          'Features:\n'
          '• Basic calculations\n'
          '• Scientific functions\n'
          '• History tracking\n'
          '• Multiple themes\n'
          '• Auto calculation\n',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Animated Theme Tile
class _AnimatedThemeTile extends StatefulWidget {
  final dynamic theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedThemeTile({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedThemeTile> createState() => _AnimatedThemeTileState();
}

class _AnimatedThemeTileState extends State<_AnimatedThemeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(widget.theme.surfaceColor),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isSelected
                      ? Color(widget.theme.primaryColor)
                      : Colors.grey.shade300,
                  width: widget.isSelected ? 2.5 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: Color(widget.theme.primaryColor).withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: widget.isSelected ? 24 : 20,
                    height: widget.isSelected ? 24 : 20,
                    decoration: BoxDecoration(
                      color: Color(widget.theme.primaryColor),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Color(widget.theme.primaryColor).withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: widget.isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.theme.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                        color: Color(widget.theme.onSurfaceColor),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Animated Switch Tile
class _AnimatedSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnimatedSwitchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: value
                ? colorScheme.primary.withValues(alpha: 0.15)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: Icon(
              icon,
              key: ValueKey(icon),
              color: value ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

