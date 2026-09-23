import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calculator_provider.dart';

class CalculatorDisplay extends StatefulWidget {
  const CalculatorDisplay({super.key});

  @override
  State<CalculatorDisplay> createState() => _CalculatorDisplayState();
}

class _CalculatorDisplayState extends State<CalculatorDisplay>
    with TickerProviderStateMixin {
  // Result slide animation
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  // Error shake animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _isAnimating = false;
  String _animatingText = '';
  String _animatingPrevExpression = '';
  String _lastAnimatedResult = '';
  bool _isShaking = false;
  late TextEditingController _controller;
  late ScrollController _scrollController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();

    // Slide animation controller (Google & Samsung Calculator style)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _controller = TextEditingController();
    _controller.addListener(() {
      if (!mounted) return;
      final calculator = Provider.of<CalculatorProvider>(context, listen: false);

      // Prevent updates during sync
      if (_isSyncing) return;

      // Only update if selection is valid and different
      if (_controller.selection.isValid &&
          _controller.selection.baseOffset >= 0 &&
          _controller.selection.baseOffset != calculator.cursorPosition) {
        calculator.setCursorPosition(_controller.selection.baseOffset);
      }
    });

    _scrollController = ScrollController();

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
          _animatingText = '';
          _animatingPrevExpression = '';
        });
      }
    });

    // Shake animation controller
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isShaking = false);
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _shakeController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _triggerAnimation(String resultText, String prevExpr) {
    if (_lastAnimatedResult != resultText) {
      _lastAnimatedResult = resultText;
      setState(() {
        _isAnimating = true;
        _animatingText = resultText;
        _animatingPrevExpression = prevExpr;
      });
      _slideController.forward(from: 0.0);
    }
  }

  void _triggerShake() {
    if (!_isShaking) {
      setState(() => _isShaking = true);
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, child) {
        // Reset animation tracker when calculator is cleared or switched
        if (!calculator.isResult) {
          _lastAnimatedResult = '';
        }

        // Trigger shake animation for errors
        if (calculator.display == 'Error' && !_isShaking) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _triggerShake();
          });
        }

        // Trigger animation in basic, scientific, and advanced mode when result is shown
        if ((calculator.calculatorType == 'basic' ||
                calculator.calculatorType == 'scientific' ||
                calculator.calculatorType == 'advanced') &&
            calculator.isResult &&
            !_isAnimating &&
            calculator.display.isNotEmpty &&
            calculator.display != 'Error' &&
            _lastAnimatedResult != calculator.display) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _triggerAnimation(calculator.display, calculator.previousExpression);
          });
        }

        // Get the answer panel content based on current expression
        final answerPanelText = _getAnswerPanelText(calculator);

        // Calculate responsive font sizes
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final baseDisplayFontSize = screenWidth < 400
            ? 56.0
            : screenWidth < 600
                ? 64.0
                : 72.0;

        // Get dynamic font size based on text length
        final displayText = calculator.display.isNotEmpty
            ? calculator.display
            : calculator.expression;
        final displayFontSize =
            _getDynamicFontSize(displayText, baseDisplayFontSize, screenWidth);

        final answerFontSize = screenWidth < 400
            ? 26.0
            : screenWidth < 600
                ? 27.0
                : 29.0;

        return Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomRight,
          child: _isAnimating
              ? _buildAnimatingDisplay(
                  context,
                  calculator,
                  displayFontSize,
                  answerFontSize,
                  screenHeight,
                )
              : _buildNormalDisplay(
                  context,
                  calculator,
                  displayFontSize,
                  answerFontSize,
                  answerPanelText,
                ),
        );
      },
    );
  }

  Widget _buildAnimatingDisplay(
    BuildContext context,
    CalculatorProvider calculator,
    double displayFontSize,
    double answerFontSize,
    double screenHeight,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final startScale = (answerFontSize / displayFontSize).clamp(0.35, 0.65);

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        final t = _slideAnimation.value;
        // Result translateY slides up from bottom preview position (+42 -> 0)
        final resultOffsetY = 42.0 * (1.0 - t);
        // Result scale expands smoothly from preview size to display size
        final resultScale = startScale + (1.0 - startScale) * t;
        // Result color transitions from preview primary to main onSurface
        final resultColor = Color.lerp(
          colorScheme.primary,
          colorScheme.onSurface,
          t,
        )!;

        // Previous expression transitions smoothly from main display size to previous-expression size
        final prevFontSize =
            displayFontSize + (answerFontSize * 0.85 - displayFontSize) * t;
        final prevOpacity = 1.0 - (0.4 * t);

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Error message display
            if (calculator.errorMessage.isNotEmpty)
              _buildErrorBadge(context, calculator.errorMessage),

            // Previous expression transitioning to upper subtle line
            if (_animatingPrevExpression.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6, right: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _animatingPrevExpression,
                    style: TextStyle(
                      fontSize: prevFontSize,
                      color:
                          colorScheme.onSurface.withValues(alpha: prevOpacity),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),

            // Animating result sliding up from auto-calculation preview
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                child: Transform.translate(
                  offset: Offset(0, resultOffsetY),
                  child: Transform.scale(
                    scale: resultScale,
                    alignment: Alignment.bottomRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _animatingText,
                          style: TextStyle(
                            fontSize: displayFontSize,
                            fontWeight: FontWeight.bold,
                            color: resultColor,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNormalDisplay(
    BuildContext context,
    CalculatorProvider calculator,
    double displayFontSize,
    double answerFontSize,
    String answerPanelText,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isError = calculator.display == 'Error';

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_isShaking ? _shakeAnimation.value : 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Error message display
              if (calculator.errorMessage.isNotEmpty)
                _buildErrorBadge(context, calculator.errorMessage),

              // Previous expression display (Samsung / Google Calculator style)
              if (calculator.isResult && calculator.previousExpression.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, right: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      calculator.previousExpression,
                      style: TextStyle(
                        fontSize: answerFontSize * 0.85,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),

              // Main display
              Expanded(
                child: Container(
                  alignment: Alignment.bottomRight,
                  // Ensure full width so cursor is always visible even if empty
                  width: double.infinity,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Sync controller with provider state
                      final text = calculator.display.isNotEmpty
                          ? calculator.display
                          : calculator.expression;

                      // Use sync guard to prevent listener from firing back to provider
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _isSyncing = true;
                        try {
                          if (_controller.text != text) {
                            _controller.text = text;
                          }

                          // Sync cursor position from provider
                          final cursorPos = calculator.cursorPosition.clamp(0, text.length);
                          if (_controller.selection.baseOffset != cursorPos) {
                            _controller.selection = TextSelection.collapsed(offset: cursorPos);
                          }

                          // Auto-scroll ONLY if cursor is at the very end
                          if (cursorPos == text.length && _scrollController.hasClients) {
                             _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                          }
                        } finally {
                          _isSyncing = false;
                        }
                      });

                      return TextField(
                        controller: _controller,
                        scrollController: _scrollController,
                        readOnly: true,
                        showCursor: !calculator.isResult,
                        // Prevent system keyboard from showing
                        keyboardType: TextInputType.none,
                        // Ensure focus is kept for cursor visibility
                        autofocus: true,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: displayFontSize,
                          fontWeight: FontWeight.bold,
                          color: isError
                              ? colorScheme.error
                              : colorScheme.onSurface,
                          height: 1.1,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        enableInteractiveSelection: true,
                        onTap: () {
                          // Allow cursor positioning
                        },
                      );
                    }
                  ),
                ),
              ),

              // Answer Panel (only shown when live auto-calculation preview is available)
              if (answerPanelText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      answerPanelText,
                      style: TextStyle(
                        fontSize: answerFontSize,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorBadge(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.errorContainer,
                  colorScheme.errorContainer.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.error.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 16,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getDynamicFontSize(
      String text, double baseFontSize, double screenWidth) {
    if (text.isEmpty) return baseFontSize;

    final textLength = text.length;
    final avgCharWidth = baseFontSize * 0.6;
    final estimatedTextWidth = textLength * avgCharWidth;

    if (estimatedTextWidth <= screenWidth * 0.8) {
      return baseFontSize;
    }

    final scaleFactor = (screenWidth * 0.8) / estimatedTextWidth;
    const minFontSize = 24.0;
    final scaledFontSize = baseFontSize * scaleFactor;

    return scaledFontSize.clamp(minFontSize, baseFontSize);
  }

  String _getAnswerPanelText(CalculatorProvider calculator) {
    if (_isAnimating || calculator.isResult) {
      return '';
    }

    if (calculator.autoCalculate &&
        calculator.autoCalculatedResult.isNotEmpty) {
      return calculator.autoCalculatedResult;
    }

    return '';
  }
}

