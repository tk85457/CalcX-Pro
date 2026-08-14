import 'package:flutter/material.dart';
import '../providers/calculator_provider.dart';

class CalculatorButtons extends StatefulWidget {
  final CalculatorProvider calculator;
  final String calculatorType;

  const CalculatorButtons({
    super.key,
    required this.calculator,
    required this.calculatorType,
  });

  @override
  State<CalculatorButtons> createState() => _CalculatorButtonsState();
}

class _CalculatorButtonsState extends State<CalculatorButtons>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    // Reduced from 600ms → 300ms for snappier app feel
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasAnimated) {
      _hasAnimated = true;
      Future.delayed(const Duration(milliseconds: 60), () {
        if (mounted) {
          _entranceController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buttons;

    switch (widget.calculatorType) {
      case 'scientific':
        buttons = _buildScientificButtons();
        break;
      case 'converter':
        buttons = _buildConverterButtons();
        break;
      case 'advanced':
        buttons = _buildAdvancedButtons();
        break;
      default:
        buttons = _buildBasicButtons();
        break;
    }

    final containerPadding = widget.calculatorType == 'basic'
        ? EdgeInsets.zero
        : const EdgeInsets.all(6);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) {},
      onHorizontalDragUpdate: (_) {},
      child: AnimatedBuilder(
        animation: _entranceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _entranceAnimation.value)),
            child: Opacity(
              opacity: _entranceAnimation.value,
              child: Container(padding: containerPadding, child: buttons),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicButtons() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('C', _ButtonType.secondary, 0),
              _buildAnimatedButton('⌫', _ButtonType.secondary, 1),
              _buildAnimatedButton('%', _ButtonType.operator, 2),
              _buildAnimatedButton('÷', _ButtonType.operator, 3),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('7', _ButtonType.number, 4),
              _buildAnimatedButton('8', _ButtonType.number, 5),
              _buildAnimatedButton('9', _ButtonType.number, 6),
              _buildAnimatedButton('×', _ButtonType.operator, 7),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('4', _ButtonType.number, 8),
              _buildAnimatedButton('5', _ButtonType.number, 9),
              _buildAnimatedButton('6', _ButtonType.number, 10),
              _buildAnimatedButton('-', _ButtonType.operator, 11),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('1', _ButtonType.number, 12),
              _buildAnimatedButton('2', _ButtonType.number, 13),
              _buildAnimatedButton('3', _ButtonType.number, 14),
              _buildAnimatedButton('+', _ButtonType.operator, 15),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('0', _ButtonType.number, 16, flex: 2),
              _buildAnimatedButton('.', _ButtonType.number, 17),
              _buildAnimatedButton('=', _ButtonType.primary, 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScientificButtons() {
    int index = 0;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('sin', _ButtonType.secondary, index++),
              _buildAnimatedButton('cos', _ButtonType.secondary, index++),
              _buildAnimatedButton('tan', _ButtonType.secondary, index++),
              _buildAnimatedButton('π', _ButtonType.secondary, index++),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('sin⁻¹', _ButtonType.secondary, index++),
              _buildAnimatedButton('cos⁻¹', _ButtonType.secondary, index++),
              _buildAnimatedButton('tan⁻¹', _ButtonType.secondary, index++),
              _buildAnimatedButton('e', _ButtonType.secondary, index++),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('log', _ButtonType.secondary, index++),
              _buildAnimatedButton('ln', _ButtonType.secondary, index++),
              _buildAnimatedButton('10ˣ', _ButtonType.secondary, index++),
              _buildAnimatedButton('eˣ', _ButtonType.secondary, index++),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('x²', _ButtonType.secondary, index++),
              _buildAnimatedButton('x³', _ButtonType.secondary, index++),
              _buildAnimatedButton('xʸ', _ButtonType.secondary, index++),
              _buildAnimatedButton('√', _ButtonType.operator, index++),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('∛', _ButtonType.secondary, index++),
              _buildAnimatedButton('|x|', _ButtonType.secondary, index++),
              _buildAnimatedButton('%', _ButtonType.operator, index++),
              _buildSmartBracketButton(index++),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('!', _ButtonType.secondary, index++),
              _buildAnimatedButton('C', _ButtonType.secondary, index++),
              _buildAnimatedButton('⌫', _ButtonType.secondary, index++),
              _buildAnimatedButton('÷', _ButtonType.operator, index++),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('7', _ButtonType.number, index++),
              _buildAnimatedButton('8', _ButtonType.number, index++),
              _buildAnimatedButton('9', _ButtonType.number, index++),
              _buildAnimatedButton('×', _ButtonType.operator, index++),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('4', _ButtonType.number, index++),
              _buildAnimatedButton('5', _ButtonType.number, index++),
              _buildAnimatedButton('6', _ButtonType.number, index++),
              _buildAnimatedButton('-', _ButtonType.operator, index++),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('1', _ButtonType.number, index++),
              _buildAnimatedButton('2', _ButtonType.number, index++),
              _buildAnimatedButton('3', _ButtonType.number, index++),
              _buildAnimatedButton('+', _ButtonType.operator, index++),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('0', _ButtonType.number, index++, flex: 2),
              _buildAnimatedButton('.', _ButtonType.number, index++),
              _buildAnimatedButton('=', _ButtonType.primary, index++),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConverterButtons() {
    int index = 0;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('C', _ButtonType.secondary, index++, flex: 1),
              _buildAnimatedButton('7', _ButtonType.number, index++, flex: 1),
              _buildAnimatedButton('8', _ButtonType.number, index++, flex: 1),
              _buildAnimatedButton('9', _ButtonType.number, index++, flex: 1),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('CE', _ButtonType.secondary, index++, flex: 1),
              _buildAnimatedButton('4', _ButtonType.number, index++, flex: 1),
              _buildAnimatedButton('5', _ButtonType.number, index++, flex: 1),
              _buildAnimatedButton('6', _ButtonType.number, index++, flex: 1),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('Convert', _ButtonType.primary, index++, flex: 2),
              _buildAnimatedButton('1', _ButtonType.number, index++, flex: 1),
              _buildAnimatedButton('2', _ButtonType.number, index++, flex: 1),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('Switch', _ButtonType.secondary, index++, flex: 2),
              _buildAnimatedButton('0', _ButtonType.number, index++, flex: 1),
              _buildAnimatedButton('.', _ButtonType.number, index++, flex: 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedButtons() {
    return _buildScientificButtons();
  }

  Widget _buildSmartBracketButton(int staggerIndex) {
    return Expanded(
      flex: 1,
      child: _AnimatedCalculatorButton(
        staggerIndex: staggerIndex,
        entranceAnimation: _entranceAnimation,
        child: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final buttonPadding = screenWidth < 400 ? 1.5 : 2.5;
            final currentExpression = widget.calculator.expression;
            int openBrackets = '('.allMatches(currentExpression).length;
            int closeBrackets = ')'.allMatches(currentExpression).length;
            String bracketText = openBrackets > closeBrackets ? ')' : '(';

            return Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: _PressableButton(
                isBasic: widget.calculatorType == 'basic',
                onPressed: () {
                  widget.calculator.appendSmartBracket();
                },
                style: _getButtonStyle(
                    context, _ButtonType.secondary, widget.calculator.buttonsLocked),
                child: Text(bracketText,
                    style: _getButtonTextStyle(
                        context, _ButtonType.secondary, bracketText)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(String text, _ButtonType type, int staggerIndex,
      {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: _AnimatedCalculatorButton(
        staggerIndex: staggerIndex,
        entranceAnimation: _entranceAnimation,
        child: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final basePadding = screenWidth < 400 ? 2.0 : 4.0;
            final buttonPadding = widget.calculatorType == 'basic'
                ? basePadding * 1.5
                : basePadding * 0.7;

            if (text == '⌫') {
              return Padding(
                padding: EdgeInsets.all(buttonPadding),
                child: GestureDetector(
                  onTap: () => widget.calculator.backspace(),
                  onLongPressStart: (_) =>
                      widget.calculator.startContinuousDelete(),
                  onLongPressEnd: (_) =>
                      widget.calculator.stopContinuousDelete(),
                  child: _PressableButton(
                    isBasic: widget.calculatorType == 'basic',
                    onPressed: () => widget.calculator.backspace(),
                    style: _getButtonStyle(
                        context, type, widget.calculator.buttonsLocked),
                    child: const Icon(Icons.backspace_outlined),
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: _PressableButton(
                isBasic: widget.calculatorType == 'basic',
                onPressed: () {
                  if (!_isButtonEnabled(text, widget.calculator)) {
                    widget.calculator.showError('Invalid format');
                    return;
                  }
                  widget.calculator.buttonPressed(text);
                },
                style: _getButtonStyle(
                    context, type, widget.calculator.buttonsLocked),
                child:
                    Text(text, style: _getButtonTextStyle(context, type, text)),
              ),
            );
          },
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle(
      BuildContext context, _ButtonType type, bool locked) {
    final colorScheme = Theme.of(context).colorScheme;

    if (locked) {
      return ElevatedButton.styleFrom(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.3),
        foregroundColor: colorScheme.onSurface.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              widget.calculatorType == 'basic' ? 32 : 16),
        ),
        elevation: 0,
        minimumSize: widget.calculatorType == 'basic'
            ? const Size(80, 80)
            : const Size(0, 70),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    }

    switch (type) {
      case _ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                widget.calculatorType == 'basic' ? 32 : 16),
          ),
          elevation: widget.calculatorType == 'basic' ? 2 : 4,
          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
          minimumSize: widget.calculatorType == 'basic'
              ? const Size(80, 80)
              : const Size(0, 70),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      case _ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          disabledBackgroundColor: colorScheme.secondaryContainer,
          disabledForegroundColor: colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                widget.calculatorType == 'basic' ? 32 : 16),
          ),
          elevation: widget.calculatorType == 'basic' ? 1 : 2,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          minimumSize: widget.calculatorType == 'basic'
              ? const Size(80, 80)
              : const Size(0, 70),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      case _ButtonType.operator:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                widget.calculatorType == 'basic' ? 32 : 16),
          ),
          elevation: widget.calculatorType == 'basic' ? 1 : 2,
          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
          minimumSize: widget.calculatorType == 'basic'
              ? const Size(80, 80)
              : const Size(0, 70),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      case _ButtonType.number:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          disabledBackgroundColor: colorScheme.surface,
          disabledForegroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                widget.calculatorType == 'basic' ? 32 : 16),
          ),
          elevation: 1,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
          side: widget.calculatorType == 'basic'
              ? BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.05),
                  width: 0.5)
              : BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 0.5),
          minimumSize: widget.calculatorType == 'basic'
              ? const Size(0, 80)
              : const Size(0, 70),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
    }
  }

  bool _isButtonEnabled(String text, CalculatorProvider calculator) {
    final disabledButtons = ['x²', 'x³', 'xʸ', '!'];
    if (disabledButtons.contains(text)) {
      return calculator.canApplyUnaryOperator;
    }
    return true;
  }

  TextStyle _getButtonTextStyle(
      BuildContext context, _ButtonType type, String text) {
    final baseStyle = Theme.of(context).textTheme.headlineSmall!;

    final inverseTrigFunctions = ['sin⁻¹', 'cos⁻¹', 'tan⁻¹'];
    if (inverseTrigFunctions.contains(text)) {
      return baseStyle.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: baseStyle.fontSize! * 0.68,
      );
    }

    // Slightly smaller for multi-char function names
    final multiCharFunctions = ['log', 'sin', 'cos', 'tan', 'ln', '10ˣ', 'eˣ', '|x|', '∛'];
    if (multiCharFunctions.contains(text)) {
      return baseStyle.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: baseStyle.fontSize! * 0.82,
      );
    }

    switch (type) {
      case _ButtonType.primary:
        return baseStyle.copyWith(fontWeight: FontWeight.bold);
      case _ButtonType.secondary:
      case _ButtonType.operator:
        return baseStyle.copyWith(fontWeight: FontWeight.w600);
      default:
        return baseStyle;
    }
  }
}

/// Animated wrapper for staggered button entrance
class _AnimatedCalculatorButton extends StatelessWidget {
  final int staggerIndex;
  final Animation<double> entranceAnimation;
  final Widget child;

  const _AnimatedCalculatorButton({
    required this.staggerIndex,
    required this.entranceAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Tighter stagger — max 0.15 offset (was 0.3)
    final staggerDelay = (staggerIndex * 0.005).clamp(0.0, 0.15);
    final staggerEnd = (staggerDelay + 0.5).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: entranceAnimation,
      builder: (context, child) {
        double progress = 0.0;
        if (entranceAnimation.value > staggerDelay) {
          progress = ((entranceAnimation.value - staggerDelay) /
                  (staggerEnd - staggerDelay))
              .clamp(0.0, 1.0);
        }

        return Transform.scale(
          scale: 0.85 + (0.15 * progress),
          child: Opacity(
            opacity: progress,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Pressable button with ultra-smooth scale animation
class _PressableButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final ButtonStyle style;
  final Widget child;
  final bool isBasic;

  const _PressableButton({
    required this.onPressed,
    required this.style,
    required this.child,
    this.isBasic = false,
  });

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    // Ultra-fast 50ms press feedback — snappiest possible
    _controller = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _elevationAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (details) {
        _onTapUp(details);
        widget.onPressed?.call();
      },
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(widget.isBasic ? 32 : 16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(
                          alpha: 0.12 * _elevationAnimation.value,
                        ),
                    blurRadius: 6 * _elevationAnimation.value,
                    offset: Offset(0, 3 * _elevationAnimation.value),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: null, // GestureDetector handles tap
                style: widget.style,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _ButtonType { number, operator, secondary, primary }
