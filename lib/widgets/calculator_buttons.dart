import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _entranceController.forward();
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
        : const EdgeInsets.all(4);

    return AnimatedBuilder(
      animation: _entranceAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _entranceAnimation.value,
          child: Container(padding: containerPadding, child: buttons),
        );
      },
    );
  }

  Widget _buildBasicButtons() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildButton('C', _ButtonType.secondary),
              _buildButton('⌫', _ButtonType.secondary),
              _buildButton('%', _ButtonType.operator),
              _buildButton('÷', _ButtonType.operator),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('7', _ButtonType.number),
              _buildButton('8', _ButtonType.number),
              _buildButton('9', _ButtonType.number),
              _buildButton('×', _ButtonType.operator),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('4', _ButtonType.number),
              _buildButton('5', _ButtonType.number),
              _buildButton('6', _ButtonType.number),
              _buildButton('-', _ButtonType.operator),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('1', _ButtonType.number),
              _buildButton('2', _ButtonType.number),
              _buildButton('3', _ButtonType.number),
              _buildButton('+', _ButtonType.operator),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('0', _ButtonType.number, flex: 2),
              _buildButton('.', _ButtonType.number),
              _buildButton('=', _ButtonType.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScientificButtons() {
    return Column(
      children: [
        // Row 0: Angle Mode (DEG/RAD), sin, cos, tan
        Expanded(
          child: Row(
            children: [
              _buildDegRadButton(),
              _buildButton('sin', _ButtonType.secondary),
              _buildButton('cos', _ButtonType.secondary),
              _buildButton('tan', _ButtonType.secondary),
            ],
          ),
        ),
        // Row 1: π, sin⁻¹, cos⁻¹, tan⁻¹
        Expanded(
          child: Row(
            children: [
              _buildButton('π', _ButtonType.secondary),
              _buildButton('sin⁻¹', _ButtonType.secondary),
              _buildButton('cos⁻¹', _ButtonType.secondary),
              _buildButton('tan⁻¹', _ButtonType.secondary),
            ],
          ),
        ),
        // Row 2: e, ln, log, 10ˣ
        Expanded(
          child: Row(
            children: [
              _buildButton('e', _ButtonType.secondary),
              _buildButton('ln', _ButtonType.secondary),
              _buildButton('log', _ButtonType.secondary),
              _buildButton('10ˣ', _ButtonType.secondary),
            ],
          ),
        ),
        // Row 3: √, x², xʸ, eˣ
        Expanded(
          child: Row(
            children: [
              _buildButton('√', _ButtonType.secondary),
              _buildButton('x²', _ButtonType.secondary),
              _buildButton('xʸ', _ButtonType.secondary),
              _buildButton('eˣ', _ButtonType.secondary),
            ],
          ),
        ),
        // Row 4: ∛, x³, |x|, ()
        Expanded(
          child: Row(
            children: [
              _buildButton('∛', _ButtonType.secondary),
              _buildButton('x³', _ButtonType.secondary),
              _buildButton('|x|', _ButtonType.secondary),
              _buildSmartBracketButton(),
            ],
          ),
        ),
        // Row 5: C, ⌫, %, ÷
        Expanded(
          child: Row(
            children: [
              _buildButton('C', _ButtonType.secondary),
              _buildButton('⌫', _ButtonType.secondary),
              _buildButton('%', _ButtonType.operator),
              _buildButton('÷', _ButtonType.operator),
            ],
          ),
        ),
        // Row 6: 7, 8, 9, ×
        Expanded(
          child: Row(
            children: [
              _buildButton('7', _ButtonType.number),
              _buildButton('8', _ButtonType.number),
              _buildButton('9', _ButtonType.number),
              _buildButton('×', _ButtonType.operator),
            ],
          ),
        ),
        // Row 7: 4, 5, 6, -
        Expanded(
          child: Row(
            children: [
              _buildButton('4', _ButtonType.number),
              _buildButton('5', _ButtonType.number),
              _buildButton('6', _ButtonType.number),
              _buildButton('-', _ButtonType.operator),
            ],
          ),
        ),
        // Row 8: 1, 2, 3, +
        Expanded(
          child: Row(
            children: [
              _buildButton('1', _ButtonType.number),
              _buildButton('2', _ButtonType.number),
              _buildButton('3', _ButtonType.number),
              _buildButton('+', _ButtonType.operator),
            ],
          ),
        ),
        // Row 9: !, 0, ., =
        Expanded(
          child: Row(
            children: [
              _buildButton('!', _ButtonType.secondary),
              _buildButton('0', _ButtonType.number),
              _buildButton('.', _ButtonType.number),
              _buildButton('=', _ButtonType.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConverterButtons() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildButton('C', _ButtonType.secondary),
              _buildButton('7', _ButtonType.number),
              _buildButton('8', _ButtonType.number),
              _buildButton('9', _ButtonType.number),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('CE', _ButtonType.secondary),
              _buildButton('4', _ButtonType.number),
              _buildButton('5', _ButtonType.number),
              _buildButton('6', _ButtonType.number),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('Convert', _ButtonType.primary, flex: 2),
              _buildButton('1', _ButtonType.number),
              _buildButton('2', _ButtonType.number),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('Switch', _ButtonType.secondary, flex: 2),
              _buildButton('0', _ButtonType.number),
              _buildButton('.', _ButtonType.number),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedButtons() {
    return _buildScientificButtons();
  }

  Widget _buildDegRadButton() {
    return Expanded(
      flex: 1,
      child: Selector<CalculatorProvider, bool>(
        selector: (_, calc) => calc.isRadian,
        builder: (context, isRadian, _) {
          final screenWidth = MediaQuery.of(context).size.width;
          final buttonPadding = screenWidth < 400 ? 1.5 : 2.5;
          final modeText = isRadian ? 'RAD' : 'DEG';

          return Padding(
            padding: EdgeInsets.all(buttonPadding),
            child: _FastCalcButton(
              onPressed: () => widget.calculator.toggleAngleUnit(),
              style: _getButtonStyle(context, _ButtonType.secondary),
              child: Text(
                modeText,
                style: _getButtonTextStyle(context, _ButtonType.secondary, modeText)
                    .copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmartBracketButton() {
    return Expanded(
      flex: 1,
      child: Selector<CalculatorProvider, String>(
        selector: (_, calc) => calc.expression,
        builder: (context, currentExpression, _) {
          final screenWidth = MediaQuery.of(context).size.width;
          final buttonPadding = screenWidth < 400 ? 1.5 : 2.5;
          int openBrackets = '('.allMatches(currentExpression).length;
          int closeBrackets = ')'.allMatches(currentExpression).length;
          String bracketText = openBrackets > closeBrackets ? ')' : '(';

          return Padding(
            padding: EdgeInsets.all(buttonPadding),
            child: _FastCalcButton(
              isBasic: widget.calculatorType == 'basic',
              onPressed: () {
                widget.calculator.appendSmartBracket();
              },
              style: _getButtonStyle(context, _ButtonType.secondary),
              child: Text(
                bracketText,
                style: _getButtonTextStyle(
                    context, _ButtonType.secondary, bracketText),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(String text, _ButtonType type, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final basePadding = screenWidth < 400 ? 1.5 : 2.5;
          final buttonPadding = widget.calculatorType == 'basic'
              ? basePadding * 1.5
              : basePadding * 0.7;

          if (text == '⌫') {
            return Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: GestureDetector(
                onLongPressStart: (_) =>
                    widget.calculator.startContinuousDelete(),
                onLongPressEnd: (_) => widget.calculator.stopContinuousDelete(),
                child: _FastCalcButton(
                  isBasic: widget.calculatorType == 'basic',
                  onPressed: () => widget.calculator.backspace(),
                  style: _getButtonStyle(context, type),
                  child: const Icon(Icons.backspace_outlined),
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(buttonPadding),
            child: _FastCalcButton(
              isBasic: widget.calculatorType == 'basic',
              onPressed: () {
                if (!_isButtonEnabled(text, widget.calculator)) {
                  widget.calculator.showError('Invalid format');
                  return;
                }
                widget.calculator.buttonPressed(text);
              },
              style: _getButtonStyle(context, type),
              child: Text(text, style: _getButtonTextStyle(context, type, text)),
            ),
          );
        },
      ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context, _ButtonType type) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBasic = widget.calculatorType == 'basic';
    final radius = BorderRadius.circular(isBasic ? 28 : 12);
    final minSize = isBasic ? const Size(0, 72) : const Size(0, 48);

    switch (type) {
      case _ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: isBasic ? 2 : 1,
          minimumSize: minSize,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        );
      case _ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: isBasic ? 1 : 0.5,
          minimumSize: minSize,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        );
      case _ButtonType.operator:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: isBasic ? 1 : 0.5,
          minimumSize: minSize,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        );
      case _ButtonType.number:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: 0.5,
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: isBasic ? 0.08 : 0.15),
            width: 0.5,
          ),
          minimumSize: minSize,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
        fontSize: (baseStyle.fontSize ?? 24) * 0.65,
      );
    }

    final multiCharFunctions = [
      'log',
      'sin',
      'cos',
      'tan',
      'ln',
      '10ˣ',
      'eˣ',
      '|x|',
      '∛',
      'DEG',
      'RAD'
    ];
    if (multiCharFunctions.contains(text)) {
      return baseStyle.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: (baseStyle.fontSize ?? 24) * 0.78,
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

/// Ultra-lightweight, hardware-accelerated calculator button
class _FastCalcButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ButtonStyle style;
  final Widget child;
  final bool isBasic;

  const _FastCalcButton({
    required this.onPressed,
    required this.style,
    required this.child,
    this.isBasic = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}

enum _ButtonType { number, operator, secondary, primary }
