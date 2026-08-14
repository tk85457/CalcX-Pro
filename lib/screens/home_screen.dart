import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/calculator_display.dart';
import '../widgets/calculator_buttons.dart';
import '../widgets/history_drawer.dart';
import '../widgets/navigation_drawer.dart';
import '../screens/emi_calculator_screen.dart';
import '../screens/gst_calculator_screen.dart';
import '../screens/age_calculator_screen.dart';
import '../screens/discount_calculator_screen.dart';
import '../screens/unit_converter_screen.dart';
import '../screens/currency_converter_screen.dart';
import '../screens/percentage_calculator_screen.dart';
import '../screens/tax_calculator_screen.dart';
import '../screens/bmi_calculator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  bool _isUserTabChange = false;
  Timer? _navBarHideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Hide nav bar immediately when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hideNavBar();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navBarHideTimer?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  // Re-hide nav bar when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _hideNavBar();
    }
  }

  // Called when system UI visibility changes (user swipes nav bar out)
  @override
  void didChangeMetrics() {
    // Start 1-second timer to re-hide nav bar after user reveals it
    _scheduleNavBarHide();
  }

  void _hideNavBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  void _scheduleNavBarHide() {
    _navBarHideTimer?.cancel();
    _navBarHideTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) _hideNavBar();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && _isUserTabChange) {
      final calculator = context.read<CalculatorProvider>();
      calculator.clear();
      _isUserTabChange = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, child) {
        int tabIndex = 0;
        switch (calculator.currentCalculatorType) {
          case 'basic':
            tabIndex = 0;
            break;
          case 'scientific':
            tabIndex = 1;
            break;
          case 'advanced':
            tabIndex = 2;
            break;
        }

        if (_tabController.index != tabIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_tabController.index != tabIndex) {
              _isUserTabChange = false;
              _tabController.index = tabIndex;
            }
          });
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('CalcX Pro'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              leading: (calculator.currentCalculatorType != 'basic' &&
                      calculator.currentCalculatorType != 'scientific' &&
                      calculator.currentCalculatorType != 'advanced')
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () =>
                          calculator.setCalculatorTypeAndClear('basic'),
                    )
                  : Builder(
                      builder: (context) => IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
              actions: [
                if (calculator.currentCalculatorType != 'advanced')
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(
                        Icons.history,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    final onPrimaryColor =
                        Theme.of(context).colorScheme.onPrimary;
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: onPrimaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          themeProvider.isDark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          color: onPrimaryColor,
                        ),
                        onPressed: () => themeProvider.toggleTheme(),
                        tooltip: themeProvider.isDark
                            ? 'Switch to Light Mode'
                            : 'Switch to Dark Mode',
                      ),
                    );
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.7),
                indicatorColor: Theme.of(context).colorScheme.onPrimary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Basic'),
                  Tab(text: 'Scientific'),
                  Tab(text: 'Advanced'),
                ],
                onTap: (index) {
                  _isUserTabChange = true;
                  String type = 'basic';
                  switch (index) {
                    case 0:
                      type = 'basic';
                      break;
                    case 1:
                      type = 'scientific';
                      break;
                    case 2:
                      type = 'advanced';
                      break;
                  }
                  calculator.setCalculatorType(type);
                },
              ),
            ),
            drawer: const NavigationDrawerWidget(),
            endDrawer: calculator.currentCalculatorType != 'advanced'
                ? const HistoryDrawer()
                : null,
            body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicCalculator(),
                _buildScientificCalculator(),
                _buildAdvancedCalculator(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicCalculator() {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, child) {
        return Column(
          children: [
            const Expanded(
                flex: 2,
                child: CalculatorDisplay(key: ValueKey('basic_display'))),
            Expanded(
              flex: 5,
              child: CalculatorButtons(
                key: const ValueKey('basic_buttons'),
                calculator: calculator,
                calculatorType: 'basic',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScientificCalculator() {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, child) {
        return Column(
          children: [
            const Expanded(
                flex: 2,
                child:
                    CalculatorDisplay(key: ValueKey('scientific_display'))),
            Expanded(
              flex: 5,
              child: CalculatorButtons(
                key: const ValueKey('scientific_buttons'),
                calculator: calculator,
                calculatorType: 'scientific',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdvancedCalculator() {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, child) {
        return _AnimatedTileGrid(
          tiles: [
            _TileData(
              icon: Icons.science,
              title: 'Scientific Calculator',
              onTap: () => _navigateToCalculator(context, 'scientific'),
            ),
            _TileData(
              icon: Icons.account_balance_wallet,
              title: 'EMI Calculator',
              onTap: () => _navigateToCalculator(context, 'emi'),
            ),
            _TileData(
              icon: Icons.receipt,
              title: 'GST Calculator',
              onTap: () => _navigateToCalculator(context, 'gst'),
            ),
            _TileData(
              icon: Icons.swap_horiz,
              title: 'Unit Converter',
              onTap: () => _navigateToCalculator(context, 'converter'),
            ),
            _TileData(
              icon: Icons.currency_exchange,
              title: 'Currency Converter',
              onTap: () => _navigateToCalculator(context, 'currency'),
            ),
            _TileData(
              icon: Icons.percent,
              title: 'Percentage Calculator',
              onTap: () => _navigateToCalculator(context, 'percentage'),
            ),
            _TileData(
              icon: Icons.cake,
              title: 'Age Calculator',
              onTap: () => _navigateToCalculator(context, 'age'),
            ),
            _TileData(
              icon: Icons.discount,
              title: 'Discount Calculator',
              onTap: () => _navigateToCalculator(context, 'discount'),
            ),
            _TileData(
              icon: Icons.attach_money,
              title: 'Tax Calculator',
              onTap: () => _navigateToCalculator(context, 'tax'),
            ),
            _TileData(
              icon: Icons.monitor_heart,
              title: 'BMI Calculator',
              onTap: () => _navigateToCalculator(context, 'bmi'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCalculator(BuildContext context, String type) {
    Widget? screen;
    switch (type) {
      case 'scientific':
        context.read<CalculatorProvider>().setCalculatorTypeAndClear('scientific');
        return;
      case 'emi':
        screen = const EMICalculatorScreen();
        break;
      case 'gst':
        screen = const GSTCalculatorScreen();
        break;
      case 'converter':
        screen = const UnitConverterScreen();
        break;
      case 'currency':
        screen = const CurrencyConverterScreen();
        break;
      case 'age':
        screen = const AgeCalculatorScreen();
        break;
      case 'discount':
        screen = const DiscountCalculatorScreen();
        break;
      case 'percentage':
        screen = const PercentageCalculatorScreen();
        break;
      case 'tax':
        screen = const TaxCalculatorScreen();
        break;
      case 'bmi':
        screen = const BMICalculatorScreen();
        break;
    }

    if (screen != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen!));
    }
  }
}

// ── Tile data class ──────────────────────────────────────────────────────────

class _TileData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  _TileData({required this.icon, required this.title, required this.onTap});
}

// ── Animated Tile Grid ───────────────────────────────────────────────────────

class _AnimatedTileGrid extends StatefulWidget {
  final List<_TileData> tiles;
  const _AnimatedTileGrid({required this.tiles});

  @override
  State<_AnimatedTileGrid> createState() => _AnimatedTileGridState();
}

class _AnimatedTileGridState extends State<_AnimatedTileGrid>
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
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: widget.tiles.length,
          itemBuilder: (context, index) {
            final staggerDelay = (index * 0.08).clamp(0.0, 0.6);
            final staggerEnd = (staggerDelay + 0.4).clamp(0.0, 1.0);
            double progress = 0.0;
            if (_animation.value > staggerDelay) {
              progress = ((_animation.value - staggerDelay) /
                      (staggerEnd - staggerDelay))
                  .clamp(0.0, 1.0);
            }
            return Transform.translate(
              offset: Offset(0, 30 * (1 - progress)),
              child: Opacity(
                opacity: progress,
                child: Transform.scale(
                  scale: 0.8 + (0.2 * progress),
                  child: _AnimatedCalculatorTile(
                    icon: widget.tiles[index].icon,
                    title: widget.tiles[index].title,
                    onTap: widget.tiles[index].onTap,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Animated Calculator Tile ─────────────────────────────────────────────────

class _AnimatedCalculatorTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AnimatedCalculatorTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_AnimatedCalculatorTile> createState() =>
      _AnimatedCalculatorTileState();
}

class _AnimatedCalculatorTileState extends State<_AnimatedCalculatorTile>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _iconController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconBounceAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    _iconBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_iconController);
  }

  @override
  void dispose() {
    _pressController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    _iconController.forward(from: 0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _iconBounceAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withValues(alpha: 0.8),
                  ],
                ),
                border: Border.all(
                  color: colorScheme.primary
                      .withValues(alpha: _isPressed ? 0.5 : 0.15),
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary
                        .withValues(alpha: _isPressed ? 0.2 : 0.1),
                    blurRadius: _isPressed ? 20 : 12,
                    offset: Offset(0, _isPressed ? 8 : 4),
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Transform.scale(
                        scale: _iconBounceAnimation.value,
                        child: Icon(
                          widget.icon,
                          size: 36,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
