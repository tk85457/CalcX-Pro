import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/history_entry.dart';
import 'providers/calculator_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/history_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Parallel init: Hive + SystemUI
  // Hive boxes are opened BEFORE runApp so ThemeProvider can read them
  // synchronously in its constructor — no theme flash.
  await Future.wait([_initHive(), _initSystemUI()]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const CalculatorProApp(),
    ),
  );
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(HistoryEntryAdapter());
  // Open all boxes upfront — providers read them synchronously after this
  await Future.wait([
    Hive.openBox<HistoryEntry>(AppConstants.historyBox),
    Hive.openBox(AppConstants.themeBox),
    Hive.openBox('settings'), // SettingsProvider box
  ]);
}

Future<void> _initSystemUI() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class CalculatorProApp extends StatefulWidget {
  const CalculatorProApp({super.key});
  @override
  State<CalculatorProApp> createState() => _CalculatorProAppState();
}

class _CalculatorProAppState extends State<CalculatorProApp> {
  @override
  void initState() {
    super.initState();
    // Only wire up the history provider — theme is already loaded synchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CalculatorProvider>().setHistoryProvider(
              context.read<HistoryProvider>(),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: themeProvider.theme,
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _glowAnimation;
  late List<_SplashParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(12, (_) => _SplashParticle(
      x: _random.nextDouble(), y: _random.nextDouble(),
      size: _random.nextDouble() * 3 + 1.5,
      speedY: _random.nextDouble() * 0.2 + 0.08,
      opacity: _random.nextDouble() * 0.4 + 0.2,
    ));
    _mainController = AnimationController(duration: const Duration(milliseconds: 900), vsync: this);
    _glowController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..repeat(reverse: true);
    _textController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _particleController = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat();
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.12).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 65),
      TweenSequenceItem(tween: Tween<double>(begin: 1.12, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 35),
    ]).animate(_mainController);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_glowController);
    _textSlideAnimation = Tween<double>(begin: 24.0, end: 0.0).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    _mainController.forward();
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const HomeScreen(),
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 320),
    ));
  }

  @override
  void dispose() {
    _mainController.dispose(); _glowController.dispose();
    _textController.dispose(); _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _glowController, _textController, _particleController]),
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [cs.primary, Color.lerp(cs.primary, cs.secondary, 0.6)!, cs.secondary],
              ),
            ),
            child: Stack(children: [
              RepaintBoundary(child: CustomPaint(
                painter: _SplashParticlesPainter(particles: _particles, animationValue: _particleController.value),
                size: Size.infinite,
              )),
              Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Transform.scale(scale: _scaleAnimation.value, child: Opacity(opacity: _fadeAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), boxShadow: [
                      BoxShadow(color: Colors.white.withValues(alpha: 0.2 + _glowAnimation.value * 0.15),
                        blurRadius: 18 + _glowAnimation.value * 12, spreadRadius: 4 + _glowAnimation.value * 4),
                    ]),
                    child: Container(width: 130, height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                      ),
                      child: ClipRRect(borderRadius: BorderRadius.circular(26),
                        child: Image.asset('assets/images/icon/app_icon.png', fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.calculate_rounded, size: 80, color: Colors.white)),
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 36),
                Transform.translate(offset: Offset(0, _textSlideAnimation.value), child: Opacity(opacity: _textFadeAnimation.value,
                  child: const Text(AppConstants.appName, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                )),
                const SizedBox(height: 10),
                Transform.translate(offset: Offset(0, _textSlideAnimation.value * 1.3), child: Opacity(opacity: _textFadeAnimation.value * 0.85,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Text('\u2728 Premium Calculator Experience',
                      style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                )),
              ])),
              Positioned(bottom: 56, left: 0, right: 0, child: Opacity(opacity: _textFadeAnimation.value,
                child: Center(child: SizedBox(width: 100, child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _mainController.value,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 3,
                  ),
                ))),
              )),
            ]),
          );
        },
      ),
    );
  }
}

class _SplashParticle {
  final double x, y, size, speedY, opacity;
  const _SplashParticle({required this.x, required this.y, required this.size, required this.speedY, required this.opacity});
}

class _SplashParticlesPainter extends CustomPainter {
  final List<_SplashParticle> particles;
  final double animationValue;
  const _SplashParticlesPainter({required this.particles, required this.animationValue});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final y = ((p.y + animationValue * p.speedY) % 1.0) * size.height;
      final x = (p.x + sin(animationValue * pi * 2 + p.y * 8) * 0.015) * size.width;
      final pulse = p.opacity * (0.6 + 0.4 * sin(animationValue * pi * 3 + p.x * 8));
      paint.color = Colors.white.withValues(alpha: pulse);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _SplashParticlesPainter old) => old.animationValue != animationValue;
}

