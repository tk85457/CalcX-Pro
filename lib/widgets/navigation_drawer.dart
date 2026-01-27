import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';
import '../screens/emi_calculator_screen.dart';
import '../screens/gst_calculator_screen.dart';
import '../screens/unit_converter_screen.dart';
import '../screens/currency_converter_screen.dart';
import '../screens/tax_calculator_screen.dart';
import '../screens/bmi_calculator_screen.dart';

class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({super.key});

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 50), () {
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
    final menuItems = [
      _MenuItem(
        icon: Icons.calculate_outlined,
        title: 'Basic Calculator',
        onTap: () {
          Navigator.of(context).pop();
          context.read<CalculatorProvider>().setCalculatorTypeAndClear('basic');
        },
      ),
      _MenuItem(
        icon: Icons.science,
        title: 'Scientific Calculator',
        onTap: () {
          Navigator.of(context).pop();
          context.read<CalculatorProvider>().setCalculatorTypeAndClear('scientific');
        },
      ),
      _MenuItem(
        icon: Icons.calculate,
        title: 'Advanced Calculator',
        onTap: () {
          Navigator.of(context).pop();
          context.read<CalculatorProvider>().setCalculatorTypeAndClear('advanced');
        },
      ),
      null, // Divider
      _MenuItem(
        icon: Icons.account_balance,
        title: 'EMI Calculator',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EMICalculatorScreen()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.receipt,
        title: 'GST Calculator',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const GSTCalculatorScreen()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.swap_horiz,
        title: 'Unit Converter',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const UnitConverterScreen()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.currency_exchange,
        title: 'Currency Converter',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CurrencyConverterScreen()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.attach_money,
        title: 'Tax Calculator',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TaxCalculatorScreen()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.monitor_heart,
        title: 'BMI Calculator',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const BMICalculatorScreen()),
          );
        },
      ),
      null, // Divider
      _MenuItem(
        icon: Icons.history,
        title: 'Calculation History',
        onTap: () {
          Navigator.of(context).pop();
          Scaffold.of(context).openEndDrawer();
        },
      ),
      _MenuItem(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.info,
        title: 'About',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AboutScreen()),
          );
        },
      ),
    ];

    return Drawer(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Column(
            children: [
              // Animated Header
              _AnimatedDrawerHeader(animation: _animation),
              // Menu Items
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];

                    // Calculate stagger
                    final staggerDelay = ((index + 1) * 0.04).clamp(0.0, 0.5);
                    final staggerEnd = (staggerDelay + 0.4).clamp(0.0, 1.0);

                    double progress = 0.0;
                    if (_animation.value > staggerDelay) {
                      progress = ((_animation.value - staggerDelay) / (staggerEnd - staggerDelay)).clamp(0.0, 1.0);
                    }

                    if (item == null) {
                      return Opacity(
                        opacity: progress,
                        child: const Divider(),
                      );
                    }

                    return Transform.translate(
                      offset: Offset(-50 * (1 - progress), 0),
                      child: Opacity(
                        opacity: progress,
                        child: _AnimatedMenuItem(
                          icon: item.icon,
                          title: item.title,
                          onTap: item.onTap,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class _AnimatedDrawerHeader extends StatelessWidget {
  final Animation<double> animation;

  const _AnimatedDrawerHeader({required this.animation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1 + animation.value * 0.3, -1),
          end: Alignment(1 - animation.value * 0.3, 1),
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
            colorScheme.secondary.withValues(alpha: 0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.scale(
                scale: 0.5 + animation.value * 0.5,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/icon/app_icon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.calculate_rounded,
                          size: 36,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Transform.translate(
                  offset: Offset(-30 * (1 - animation.value), 0),
                  child: Opacity(
                    opacity: animation.value,
                    child: const Text(
                      'CalcX Pro',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Transform.translate(
                  offset: Offset(-30 * (1 - animation.value * 0.8), 0),
                  child: Opacity(
                    opacity: animation.value * 0.8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '✨ Premium Calculator',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AnimatedMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconRotation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _iconRotation = Tween<double>(begin: 0, end: 0.1).animate(
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
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _iconRotation,
      builder: (context, child) {
        return Material(
          color: _isHovered
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          child: InkWell(
            onTap: () {
              _controller.forward().then((_) {
                if (mounted) _controller.reverse();
              });
              widget.onTap();
            },
            onHover: (hovering) {
              setState(() => _isHovered = hovering);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Transform.rotate(
                    angle: _iconRotation.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 20,
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

