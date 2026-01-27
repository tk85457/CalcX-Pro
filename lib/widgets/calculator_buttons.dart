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
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      Future.delayed(const Duration(milliseconds: 100), () {
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
      default: // basic calculator
        buttons = _buildBasicButtons();
        break;
    }

    // Compact padding for all calculator types
    final containerPadding = const EdgeInsets.all(6);

    // Wrap buttons in GestureDetector to prevent swipe gestures from button presses
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) {}, // Absorb horizontal drag gestures
      onHorizontalDragUpdate: (_) {}, // Prevent swipe propagation
      child: AnimatedBuilder(
        animation: _entranceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _entranceAnimation.value)),
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
        // Row 1
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
        // Row 2
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
        // Row 3
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
        // Row 4
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
        // Row 5
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
        // First row: Trigonometric functions
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
        // Second row: Inverse trigonometric functions
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
        // Third row: Logarithmic and exponential functions
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
        // Fourth row: Powers and roots
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
        // Fifth row: More roots and absolute value
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
        // Sixth row: Operations and controls
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
        // Seventh row: Numbers
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
        // Eighth row: Numbers
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
        // Ninth row: Numbers
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
        // Tenth row: Bottom row
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
        // Converter input row
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
        // Converter row 2
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
        // Converter row 3
        Expanded(
          child: Row(
            children: [
              _buildAnimatedButton('Convert', _ButtonType.primary, index++, flex: 2),
              _buildAnimatedButton('1', _ButtonType.number, index++, flex: 1),
              _buildAnimatedButton('2', _ButtonType.number, index++, flex: 1),
            ],
          ),
        ),
        // Converter row 4
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
            // Calculate responsive padding based on screen size
            final screenWidth = MediaQuery.of(context).size.width;
            final buttonPadding = screenWidth < 400 ? 1.5 : 2.5;

            // Determine which bracket to show
            final currentExpression = widget.calculator.expression;
            int openBrackets = '('.allMatches(currentExpression).length;
            int closeBrackets = ')'.allMatches(currentExpression).length;
            String bracketText = openBrackets > closeBrackets ? ')' : '(';

            return Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: _PressableButton(
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

  Widget _buildAnimatedButton(String text, _ButtonType type, int staggerIndex, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: _AnimatedCalculatorButton(
        staggerIndex: staggerIndex,
        entranceAnimation: _entranceAnimation,
        child: Builder(
          builder: (context) {
            // Calculate responsive padding based on screen size and calculator type
            final screenWidth = MediaQuery.of(context).size.width;
            // Ultra compact padding for basic calculator - minimal button spacing
            final basePadding = screenWidth < 400 ? 1.0 : 2.0;
            final buttonPadding = widget.calculatorType == 'basic'
                ? basePadding * 0.02 // Even more compact for basic calculator
                : basePadding * 0.7;

            // Wrap backspace button with GestureDetector for long-press
            if (text == '⌫') {
              return Padding(
                padding: EdgeInsets.all(buttonPadding),
                child: GestureDetector(
                  onTap: () => widget.calculator.backspace(),
                  onLongPressStart: (_) => widget.calculator.startContinuousDelete(),
                  onLongPressEnd: (_) => widget.calculator.stopContinuousDelete(),
                  child: _PressableButton(
                    onPressed: () => widget.calculator.backspace(),
                    style: _getButtonStyle(context, type, widget.calculator.buttonsLocked),
                    child: const Icon(Icons.backspace),
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: _PressableButton(
                onPressed: () {
                  // Samsung Calculator style - functional disabling with error
                  if (!_isButtonEnabled(text, widget.calculator)) {
                    widget.calculator.showError('Invalid format');
                    return;
                  }
                  widget.calculator.buttonPressed(text);
                },
                style: _getButtonStyle(context, type, widget.calculator.buttonsLocked),
                child: Text(text, style: _getButtonTextStyle(context, type, text)),
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
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        minimumSize: widget.calculatorType == 'basic'
            ? const Size(80, 60) // Increased height from 48 to 60
            : const Size(0, 70), // Increased height from 58 to 70
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    }

    switch (type) {
      case _ButtonType.primary:
        // Equals button - use primary color with high contrast
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
          minimumSize: widget.calculatorType == 'basic'
              ? const Size(80, 60) // Increased height from 48 to 60
              : const Size(0, 70), // Increased height from 58 to 70
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      case _ButtonType.secondary:
        // Function buttons (C, ⌫, ±, sin, cos, etc.) - use secondary with good contrast
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          minimumSize: widget.calculatorType == 'basic'
              ? const Size(80, 60) // Increased height from 48 to 60
              : const Size(0, 70), // Increased height from 58 to 70
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      case _ButtonType.operator:
        // Operator buttons (+, -, ×, ÷) - use primary color for highlighting
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
          minimumSize: widget.calculatorType == 'basic'
              ? const Size(80, 60) // Increased height from 48 to 60
              : const Size(0, 70), // Increased height from 58 to 70
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      case _ButtonType.number:
        // Number buttons - use surface with subtle elevation
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 1,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
          minimumSize: widget.calculatorType == 'basic'
              ? const Size(0, 60) // Increased height from 48 to 60
              : const Size(0, 70), // Increased height from 58 to 70
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
    }
  }

  bool _isButtonEnabled(String text, CalculatorProvider calculator) {
    // Samsung Calculator style - only these buttons are disabled when no valid operand
    final disabledButtons = ['x²', 'x³', 'xʸ', '!'];

    if (disabledButtons.contains(text)) {
      return calculator.canApplyUnaryOperator;
    }

    // All other buttons are always enabled
    return true;
  }

  TextStyle _getButtonTextStyle(
      BuildContext context, _ButtonType type, String text) {
    final baseStyle = Theme.of(context).textTheme.headlineSmall!;

    // Special handling for inverse trigonometric functions - make them smaller
    final inverseTrigFunctions = ['sin⁻¹', 'cos⁻¹', 'tan⁻¹'];
    if (inverseTrigFunctions.contains(text)) {
      return baseStyle.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: baseStyle.fontSize! * 0.7, // Make font 70% of original size
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
    // Calculate stagger delay based on index
    final staggerDelay = (staggerIndex * 0.02).clamp(0.0, 0.5);
    final staggerEnd = (staggerDelay + 0.5).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: entranceAnimation,
      builder: (context, child) {
        // Calculate progress for this specific button
        double progress = 0.0;
        if (entranceAnimation.value > staggerDelay) {
          progress = ((entranceAnimation.value - staggerDelay) / (staggerEnd - staggerDelay)).clamp(0.0, 1.0);
        }

        return Transform.scale(
          scale: 0.8 + (0.2 * progress),
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

/// Pressable button with scale animation
class _PressableButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final ButtonStyle style;
  final Widget child;

  const _PressableButton({
    required this.onPressed,
    required this.style,
    required this.child,
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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(
                      alpha: 0.15 * _elevationAnimation.value,
                    ),
                    blurRadius: 8 * _elevationAnimation.value,
                    offset: Offset(0, 4 * _elevationAnimation.value),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.onPressed,
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

