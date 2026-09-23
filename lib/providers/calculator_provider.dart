import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/calculator_utils.dart';
import 'history_provider.dart';

class CalculatorProvider extends ChangeNotifier {
  final Set<String> _binaryOperators = {'+', '×', '÷', '%', '^'};

  // Separate state for each calculator type to prevent sharing
  String _basicDisplay = '';
  String _basicExpression = '';
  String _basicPreviousExpression = '';
  bool _basicIsResult = false;
  String _basicAutoCalculatedResult = '';
  String _basicLastValidResult = '';

  String _scientificDisplay = '';
  String _scientificExpression = '';
  String _scientificPreviousExpression = '';
  bool _scientificIsResult = false;
  String _scientificAutoCalculatedResult = '';
  String _scientificLastValidResult = '';

  String _advancedDisplay = '';
  String _advancedExpression = '';
  String _advancedPreviousExpression = '';
  bool _advancedIsResult = false;
  String _advancedAutoCalculatedResult = '';
  String _advancedLastValidResult = '';

  String _calculatorType = 'basic';
  bool _isRadian = false;
  HistoryProvider? _historyProvider;

  // Getters for current calculator type
  String get display => _getCurrentDisplay();
  String get expression => _getCurrentExpression();
  String get previousExpression => _getCurrentPreviousExpression();
  bool get isResult => _getCurrentIsResult();
  String get calculatorType => _calculatorType;
  bool get isRadian => _isRadian;
  bool get autoCalculate => shouldAutoCalculate;
  bool get shouldAutoCalculate =>
      _autoCalculate &&
      (_calculatorType == 'basic' ||
          _calculatorType == 'scientific' ||
          _calculatorType == 'advanced');
  String get autoCalculatedResult => _getCurrentAutoCalculatedResult();
  String get lastValidResult => _getCurrentLastValidResult();

  void toggleAngleUnit() {
    _isRadian = !_isRadian;
    if (shouldAutoCalculate) {
      _tryAutoCalculate();
    }
    notifyListeners();
  }

  // Helper methods to get current values
  String _getCurrentDisplay() {
    switch (_calculatorType) {
      case 'basic':
        return _basicDisplay;
      case 'scientific':
        return _scientificDisplay;
      case 'advanced':
        return _advancedDisplay;
      default:
        return '';
    }
  }

  String _getCurrentExpression() {
    switch (_calculatorType) {
      case 'basic':
        return _basicExpression;
      case 'scientific':
        return _scientificExpression;
      case 'advanced':
        return _advancedExpression;
      default:
        return '';
    }
  }

  String _getCurrentPreviousExpression() {
    switch (_calculatorType) {
      case 'basic':
        return _basicPreviousExpression;
      case 'scientific':
        return _scientificPreviousExpression;
      case 'advanced':
        return _advancedPreviousExpression;
      default:
        return '';
    }
  }

  bool _getCurrentIsResult() {
    switch (_calculatorType) {
      case 'basic':
        return _basicIsResult;
      case 'scientific':
        return _scientificIsResult;
      case 'advanced':
        return _advancedIsResult;
      default:
        return false;
    }
  }

  String _getCurrentAutoCalculatedResult() {
    switch (_calculatorType) {
      case 'basic':
        return _basicAutoCalculatedResult;
      case 'scientific':
        return _scientificAutoCalculatedResult;
      case 'advanced':
        return _advancedAutoCalculatedResult;
      default:
        return '';
    }
  }

  String _getCurrentLastValidResult() {
    switch (_calculatorType) {
      case 'basic':
        return _basicLastValidResult;
      case 'scientific':
        return _scientificLastValidResult;
      case 'advanced':
        return _advancedLastValidResult;
      default:
        return '';
    }
  }

  String get errorMessage => _errorMessage;
  bool get buttonsLocked => _buttonsLocked;

  // Samsung Calculator style - check if unary operators can be applied
  bool get canApplyUnaryOperator {
    final currentExpression = expression;
    final currentIsResult = isResult;
    if (currentExpression.isEmpty && !currentIsResult) return false;
    return RegExp(r'(\d|\)|π|e)$').hasMatch(currentExpression) ||
        currentIsResult;
  }

  bool _autoCalculate = true;
  Timer? _deleteTimer;
  String _errorMessage = '';
  final bool _buttonsLocked = false;
  Timer? _errorTimer;
  int _cursorPosition = 0;

  int get cursorPosition => _cursorPosition;

  void setCursorPosition(int position) {
    _cursorPosition = position;
    notifyListeners();
  }

  void _insertText(String value) {
    String currentDisplay = _getCurrentDisplay();

    // Check bounds before properties
    if (_cursorPosition < 0) _cursorPosition = 0;
    if (_cursorPosition > currentDisplay.length) {
      _cursorPosition = currentDisplay.length;
    }

    // Handle Result State
    if (isResult) {
      if (_binaryOperators.contains(value) ||
          value == '^' ||
          value == '%' ||
          value == 'x²' ||
          value == 'x³' ||
          value == 'xʸ') {
        // Continue with result
        _cursorPosition = currentDisplay.length;
      } else {
        // Start new calculation
        currentDisplay = '';
        _cursorPosition = 0;
        switch (_calculatorType) {
          case 'basic':
            _basicPreviousExpression = '';
            break;
          case 'scientific':
            _scientificPreviousExpression = '';
            break;
          case 'advanced':
            _advancedPreviousExpression = '';
            break;
        }
      }

      switch (_calculatorType) {
        case 'basic':
          _basicIsResult = false;
          break;
        case 'scientific':
          _scientificIsResult = false;
          break;
        case 'advanced':
          _advancedIsResult = false;
          break;
      }
    }

    // Insert text
    final newDisplay = currentDisplay.substring(0, _cursorPosition) +
        value +
        currentDisplay.substring(_cursorPosition);

    // Update State
    _updateDisplayAndExpression(newDisplay);

    // Move cursor
    _cursorPosition += value.length;

    if (shouldAutoCalculate) {
      _tryAutoCalculate();
    }
    notifyListeners();
  }

  void _updateDisplayAndExpression(String newValue) {
    switch (_calculatorType) {
      case 'basic':
        _basicDisplay = newValue;
        _basicExpression = newValue;
        break;
      case 'scientific':
        _scientificDisplay = newValue;
        _scientificExpression = newValue;
        break;
      case 'advanced':
        _advancedDisplay = newValue;
        _advancedExpression = newValue;
        break;
    }
  }

  void _tryAutoCalculate() {
    final currentExpression = expression;
    final preview = CalculatorUtils.getAutoCalculationPreview(
      currentExpression,
      isRadian: _isRadian,
    );
    final val = preview ?? '';

    switch (_calculatorType) {
      case 'basic':
        _basicAutoCalculatedResult = val;
        if (val.isNotEmpty) _basicLastValidResult = val;
        break;
      case 'scientific':
        _scientificAutoCalculatedResult = val;
        if (val.isNotEmpty) _scientificLastValidResult = val;
        break;
      case 'advanced':
        _advancedAutoCalculatedResult = val;
        if (val.isNotEmpty) _advancedLastValidResult = val;
        break;
    }
  }

  void startContinuousDelete() {
    _vibrate();
    backspace();
    _deleteTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        final currentExpression = expression;
        if (currentExpression.isEmpty) {
          stopContinuousDelete();
        } else {
          backspace();
        }
      },
    );
  }

  void stopContinuousDelete() {
    _deleteTimer?.cancel();
    _deleteTimer = null;
  }

  void showError(String message) {
    _errorMessage = message;
    _vibrateStrong();
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(milliseconds: 500), () {
      _errorMessage = '';
      notifyListeners();
    });
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void _showInvalidFormat() {
    showError('Invalid format');
  }

  void toggleAutoCalculate() {
    _autoCalculate = !_autoCalculate;
    notifyListeners();
  }

  void setCalculatorType(String type) {
    _calculatorType = type;
    _moveCursorToEnd();
    notifyListeners();
  }

  void setCalculatorTypeAndClear(String type) {
    _calculatorType = type;
    clear();
    _moveCursorToEnd();
    _tryAutoCalculate();
    notifyListeners();
  }

  String get currentCalculatorType => _calculatorType;

  void setHistoryProvider(HistoryProvider historyProvider) {
    _historyProvider = historyProvider;
  }

  void _saveToHistory(String expression, String result) {
    if (_historyProvider != null && expression.isNotEmpty) {
      _historyProvider!.addEntry(expression, result, _calculatorType);
    }
  }

  void appendDigit(String digit) {
    _insertText(digit);
  }

  void appendOperator(String operator) {
    final currentDisplay = display;

    // Smart Minus for Absolute Value: |anydigit| -> |-anydigit|
    if (operator == '-' &&
        _cursorPosition > 0 &&
        _cursorPosition == currentDisplay.length &&
        currentDisplay.endsWith('|')) {
      int lastPipe = currentDisplay.length - 1;
      int firstPipe = currentDisplay.lastIndexOf('|', lastPipe - 1);
      if (firstPipe != -1) {
        String inside = currentDisplay.substring(firstPipe + 1, lastPipe);
        if (inside.isNotEmpty && !inside.startsWith('-')) {
          final newDisplay =
              '${currentDisplay.substring(0, firstPipe + 1)}-$inside|';
          _updateDisplayAndExpression(newDisplay);
          _cursorPosition = newDisplay.length;
          notifyListeners();
          return;
        }
      }
    }

    // Standard operator handling
    if (_cursorPosition > 0 && _cursorPosition <= currentDisplay.length) {
      final prevChar = currentDisplay[_cursorPosition - 1];
      final isPrevOperator = '+-×÷%^.'.contains(prevChar);

      if (isPrevOperator) {
        if (operator == '-') {
          _insertText(operator);
          return;
        }
        if (operator == prevChar) {
          showError('Invalid format');
          return;
        }
        backspace();
        _insertText(operator);
        return;
      }
    }

    _insertText(operator);
  }

  void appendFunction(String function) {
    _insertText(function);
    notifyListeners();
  }

  void appendConstant(String constant) {
    _insertText(constant);
    notifyListeners();
  }

  void calculate() {
    try {
      final currentExpression = expression;
      if (currentExpression.isEmpty) return;

      // Auto-close all unclosed brackets
      final balanced = CalculatorUtils.autoCloseBrackets(currentExpression);
      if (balanced != currentExpression) {
        _updateDisplayAndExpression(balanced);
      }

      if (!CalculatorUtils.isExpressionComplete(balanced)) {
        _setErrorState();
        return;
      }

      final originalExpression = balanced;
      final result =
          CalculatorUtils.evaluateExpression(balanced, isRadian: _isRadian);
      final formattedResult = CalculatorUtils.formatResult(result);

      _setResultState(formattedResult, previousExpr: originalExpression);
      _saveToHistory(originalExpression, formattedResult);
      _moveCursorToEnd();
    } catch (e) {
      _handleCalculationError(e);
    }
  }

  void _setPreviousExpression(String expr) {
    switch (_calculatorType) {
      case 'basic':
        _basicPreviousExpression = expr;
        break;
      case 'scientific':
        _scientificPreviousExpression = expr;
        break;
      case 'advanced':
        _advancedPreviousExpression = expr;
        break;
    }
  }

  void _setErrorState() {
    _setPreviousExpression('');
    switch (_calculatorType) {
      case 'basic':
        _basicDisplay = 'Error';
        _basicIsResult = true;
        break;
      case 'scientific':
        _scientificDisplay = 'Error';
        _scientificIsResult = true;
        break;
      case 'advanced':
        _advancedDisplay = 'Error';
        _advancedIsResult = true;
        break;
    }
    _cursorPosition = display.length;
    notifyListeners();
  }

  void _setResultState(String result, {String previousExpr = ''}) {
    _setPreviousExpression(previousExpr);
    switch (_calculatorType) {
      case 'basic':
        _basicDisplay = result;
        _basicExpression = result;
        _basicIsResult = true;
        _basicAutoCalculatedResult = '';
        break;
      case 'scientific':
        _scientificDisplay = result;
        _scientificExpression = result;
        _scientificIsResult = true;
        _scientificAutoCalculatedResult = '';
        break;
      case 'advanced':
        _advancedDisplay = result;
        _advancedExpression = result;
        _advancedIsResult = true;
        _advancedAutoCalculatedResult = '';
        break;
    }
  }

  void _handleCalculationError(Object e) {
    _setPreviousExpression('');
    String errorMessage = 'Error';
    final errorString = e.toString().toLowerCase();
    if (errorString.contains('undefined')) {
      errorMessage = 'Undefined';
    } else if (errorString.contains('division by zero')) {
      errorMessage = 'Division by zero';
    } else if (errorString.contains('not defined for negative')) {
      errorMessage = 'Invalid input';
    }

    switch (_calculatorType) {
      case 'basic':
        _basicDisplay = errorMessage;
        _basicIsResult = true;
        break;
      case 'scientific':
        _scientificDisplay = errorMessage;
        _scientificIsResult = true;
        break;
      case 'advanced':
        _advancedDisplay = errorMessage;
        _advancedIsResult = true;
        break;
    }
    _saveToHistory(expression, errorMessage);
    _moveCursorToEnd();
  }

  void _moveCursorToEnd() {
    _cursorPosition = display.length;
    notifyListeners();
  }

  void clear() {
    switch (_calculatorType) {
      case 'basic':
        _basicDisplay = '';
        _basicExpression = '';
        _basicPreviousExpression = '';
        _basicIsResult = false;
        _basicAutoCalculatedResult = '';
        _basicLastValidResult = '';
        break;
      case 'scientific':
        _scientificDisplay = '';
        _scientificExpression = '';
        _scientificPreviousExpression = '';
        _scientificIsResult = false;
        _scientificAutoCalculatedResult = '';
        _scientificLastValidResult = '';
        break;
      case 'advanced':
        _advancedDisplay = '';
        _advancedExpression = '';
        _advancedPreviousExpression = '';
        _advancedIsResult = false;
        _advancedAutoCalculatedResult = '';
        _advancedLastValidResult = '';
        break;
    }
    _errorMessage = '';
    _cursorPosition = 0;
    notifyListeners();
  }

  void clearEntry() {
    final currentIsResult = isResult;
    final currentDisplay = display;
    final currentExpression = expression;
    if (currentIsResult) {
      clear();
    } else {
      if (currentDisplay.length > 1) {
        switch (_calculatorType) {
          case 'basic':
            _basicDisplay =
                currentDisplay.substring(0, currentDisplay.length - 1);
            _basicExpression =
                currentExpression.substring(0, currentExpression.length - 1);
            break;
          case 'scientific':
            _scientificDisplay =
                currentDisplay.substring(0, currentDisplay.length - 1);
            _scientificExpression =
                currentExpression.substring(0, currentExpression.length - 1);
            break;
          case 'advanced':
            _advancedDisplay =
                currentDisplay.substring(0, currentDisplay.length - 1);
            _advancedExpression =
                currentExpression.substring(0, currentExpression.length - 1);
            break;
        }
      } else {
        switch (_calculatorType) {
          case 'basic':
            _basicDisplay = '0';
            _basicExpression = '';
            break;
          case 'scientific':
            _scientificDisplay = '0';
            _scientificExpression = '';
            break;
          case 'advanced':
            _advancedDisplay = '0';
            _advancedExpression = '';
            break;
        }
      }
      notifyListeners();
    }
  }

  void toggleSign() {
    final currentDisplay = display;
    if (currentDisplay.isNotEmpty && currentDisplay != 'Error') {
      String newValue;
      int newCursor = _cursorPosition;

      if (currentDisplay.startsWith('-')) {
        newValue = currentDisplay.substring(1);
        newCursor = (newCursor - 1).clamp(0, newValue.length);
      } else {
        newValue = '-$currentDisplay';
        newCursor = newCursor + 1;
      }

      _updateDisplayAndExpression(newValue);
      _cursorPosition = newCursor;
      notifyListeners();
    }
  }

  void addDecimal() {
    _insertText('.');
  }

  void _appendScientificFunction(String function) {
    if (['sin', 'cos', 'tan', 'log', 'ln', 'sin⁻¹', 'cos⁻¹', 'tan⁻¹']
        .contains(function)) {
      _insertText('$function(');
    } else if (function == '√' || function == '∛') {
      _insertText('$function(');
    } else if (['10ˣ', 'eˣ'].contains(function)) {
      _insertText('$function(');
    } else if (function == 'x²' || function == 'x³') {
      if (!canApplyUnaryOperator) {
        showError('Invalid format');
        return;
      }
      _insertText(function == 'x²' ? '²' : '³');
    } else if (function == '|x|') {
      final currentDisplay = display;
      if (_cursorPosition > 0 &&
          _cursorPosition <= currentDisplay.length &&
          '0123456789'.contains(currentDisplay[_cursorPosition - 1])) {
        int start = _cursorPosition - 1;
        while (start > 0 && '0123456789.'.contains(currentDisplay[start - 1])) {
          start--;
        }
        final number = currentDisplay.substring(start, _cursorPosition);
        for (int i = 0; i < number.length; i++) {
          backspace();
        }
        _insertText('|$number|');
      } else {
        _insertText('|');
      }
    } else if (function == 'xʸ') {
      _insertText('^');
    }
    notifyListeners();
  }

  bool _isInvalidOperatorWithoutInput(String value) {
    final currentExpression = expression;
    return _binaryOperators.contains(value) &&
        currentExpression.isEmpty &&
        value != '-' &&
        value != '+';
  }

  void setDisplay(String value) {
    switch (_calculatorType) {
      case 'basic':
        _basicDisplay = value;
        _basicExpression = value;
        _basicIsResult = true;
        break;
      case 'scientific':
        _scientificDisplay = value;
        _scientificExpression = value;
        _scientificIsResult = true;
        break;
      case 'advanced':
        _advancedDisplay = value;
        _advancedExpression = value;
        _advancedIsResult = true;
        break;
    }
    notifyListeners();
  }

  void setExpression(String value) {
    switch (_calculatorType) {
      case 'basic':
        _basicDisplay = value;
        _basicExpression = value;
        _basicIsResult = false;
        break;
      case 'scientific':
        _scientificDisplay = value;
        _scientificExpression = value;
        _scientificIsResult = false;
        break;
      case 'advanced':
        _advancedDisplay = value;
        _advancedExpression = value;
        _advancedIsResult = false;
        break;
    }
    if (shouldAutoCalculate) {
      _tryAutoCalculate();
    }
    notifyListeners();
  }

  void appendSmartBracket() {
    final currentDisplay = display;
    int openBrackets = '('.allMatches(currentDisplay).length;
    int closeBrackets = ')'.allMatches(currentDisplay).length;
    String bracket = openBrackets > closeBrackets ? ')' : '(';
    _insertText(bracket);
    notifyListeners();
  }

  void buttonPressed(String value) {
    if (_buttonsLocked) return;

    if (value == '⌫') {
      backspace();
      return;
    }

    switch (_calculatorType) {
      case 'basic':
        _handleBasicCalculatorInput(value);
        break;
      case 'scientific':
        _handleScientificCalculatorInput(value);
        break;
      case 'advanced':
        _handleAdvancedCalculatorInput(value);
        break;
      default:
        _handleBasicCalculatorInput(value);
        break;
    }
  }

  void backspace() {
    _vibrate();

    final currentDisplay = display;
    if (currentDisplay == 'Error') {
      clear();
      return;
    }

    if (_cursorPosition > 0 && currentDisplay.isNotEmpty) {
      if (_cursorPosition > currentDisplay.length) {
        _cursorPosition = currentDisplay.length;
      }

      final newDisplay = currentDisplay.substring(0, _cursorPosition - 1) +
          currentDisplay.substring(_cursorPosition);

      _updateDisplayAndExpression(newDisplay);
      _cursorPosition--;
    }

    if (shouldAutoCalculate) {
      _tryAutoCalculate();
    }

    notifyListeners();
  }

  void _handleBasicCalculatorInput(String value) {
    if (_isInvalidOperatorWithoutInput(value)) {
      _showInvalidFormat();
      return;
    }

    if ('0123456789'.contains(value)) {
      appendDigit(value);
    } else if (value == '+' || value == '-' || value == '×' || value == '÷') {
      appendOperator(value);
    } else if (value == 'C') {
      clear();
    } else if (value == '±') {
      toggleSign();
    } else if (value == '%') {
      appendOperator('%');
    } else if (value == '.') {
      addDecimal();
    } else if (value == '=') {
      calculate();
    } else {
      appendFunction(value);
    }
  }

  void _handleScientificCalculatorInput(String value) {
    if (_isInvalidOperatorWithoutInput(value)) {
      _showInvalidFormat();
      return;
    }

    if ('0123456789'.contains(value)) {
      appendDigit(value);
    } else if (value == '+' ||
        value == '-' ||
        value == '×' ||
        value == '÷' ||
        value == '^' ||
        value == '%') {
      appendOperator(value);
    } else if (value == '(' || value == ')') {
      _insertText(value);
    } else if (value == 'π') {
      appendConstant('π');
    } else if (value == 'e') {
      appendConstant('e');
    } else if (value == '!') {
      _insertText('!');
    } else if (value == 'sin' ||
        value == 'cos' ||
        value == 'tan' ||
        value == 'log' ||
        value == 'ln' ||
        value == 'sin⁻¹' ||
        value == 'cos⁻¹' ||
        value == 'tan⁻¹' ||
        value == 'x²' ||
        value == 'x³' ||
        value == 'xʸ' ||
        value == '10ˣ' ||
        value == 'eˣ' ||
        value == '|x|' ||
        value == '√' ||
        value == '∛') {
      _appendScientificFunction(value);
    } else if (value == 'C') {
      clear();
    } else if (value == '±') {
      toggleSign();
    } else if (value == '.') {
      addDecimal();
    } else if (value == '=') {
      calculate();
    } else if (value == 'DEG' || value == 'RAD') {
      toggleAngleUnit();
    }
  }

  void _handleAdvancedCalculatorInput(String value) {
    _handleScientificCalculatorInput(value);
  }

  void _vibrate() {
    HapticFeedback.lightImpact();
  }

  void _vibrateStrong() {
    HapticFeedback.mediumImpact();
  }
}
