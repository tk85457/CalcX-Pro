import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../utils/calculator_utils.dart';
import 'history_provider.dart';

class CalculatorProvider extends ChangeNotifier {
  final Set<String> _binaryOperators = {'+', '×', '÷', '%', '^'};

  // Separate state for each calculator type to prevent sharing
  String _basicDisplay = '';
  String _basicExpression = '';
  bool _basicIsResult = false;
  String _basicAutoCalculatedResult = '';
  String _basicLastValidResult = '';

  String _scientificDisplay = '';
  String _scientificExpression = '';
  bool _scientificIsResult = false;
  String _scientificAutoCalculatedResult = '';
  String _scientificLastValidResult = '';

  String _advancedDisplay = '';
  String _advancedExpression = '';
  bool _advancedIsResult = false;
  String _advancedAutoCalculatedResult = '';
  String _advancedLastValidResult = '';

  String _calculatorType = 'basic';
  HistoryProvider? _historyProvider;

  // Getters for current calculator type
  String get display => _getCurrentDisplay();
  String get expression => _getCurrentExpression();
  bool get isResult => _getCurrentIsResult();
  String get calculatorType => _calculatorType;
  bool get autoCalculate => _autoCalculate && _calculatorType == 'basic';
  bool get shouldAutoCalculate =>
      _autoCalculate &&
      (_calculatorType == 'basic' ||
          _calculatorType == 'scientific' ||
          _calculatorType == 'advanced');
  String get autoCalculatedResult => _getCurrentAutoCalculatedResult();
  String get lastValidResult => _getCurrentLastValidResult();

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
  bool _isBackspacing = false;
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
    if (_cursorPosition > currentDisplay.length) _cursorPosition = currentDisplay.length;

    // Handle Result State
    if (isResult) {
      if (_binaryOperators.contains(value) || value == '^' || value == '%' || value == 'x²' || value == 'x³' || value == 'xʸ') {
        // Continue with result
        // currentDisplay is already the result
        _cursorPosition = currentDisplay.length;
      } else {
        // Start new calculation
        currentDisplay = '';
        _cursorPosition = 0;
      }

      switch (_calculatorType) {
        case 'basic': _basicIsResult = false; break;
        case 'scientific': _scientificIsResult = false; break;
        case 'advanced': _advancedIsResult = false; break;
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

    // Safety check: if we were at the end before insertion (nearly),
    // and this is a scientific function, ensure we are at the end
    if (_calculatorType != 'basic' && isResult) {
      _moveCursorToEnd();
    }

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
    try {
      final currentExpression = expression;
      // Only auto-calculate if expression is not empty (after trimming) and contains actual input (not just operators)
      if (currentExpression.trim().isNotEmpty &&
          CalculatorUtils.isExpressionComplete(currentExpression) &&
          RegExp(r'\d').hasMatch(currentExpression)) {
        final result = CalculatorUtils.evaluateExpression(currentExpression);
        switch (_calculatorType) {
          case 'basic':
            _basicAutoCalculatedResult = CalculatorUtils.formatResult(result);
            _basicLastValidResult = _basicAutoCalculatedResult;
            break;
          case 'scientific':
            _scientificAutoCalculatedResult =
                CalculatorUtils.formatResult(result);
            _scientificLastValidResult = _scientificAutoCalculatedResult;
            break;
          case 'advanced':
            _advancedAutoCalculatedResult =
                CalculatorUtils.formatResult(result);
            _advancedLastValidResult = _advancedAutoCalculatedResult;
            break;
        }
      } else {
        // Clear auto-calculated result when input is empty or invalid
        switch (_calculatorType) {
          case 'basic':
            _basicAutoCalculatedResult = '';
            break;
          case 'scientific':
            _scientificAutoCalculatedResult = '';
            break;
          case 'advanced':
            _advancedAutoCalculatedResult = '';
            break;
        }
      }
    } catch (_) {
      // Clear auto-calculated result on error
      switch (_calculatorType) {
        case 'basic':
          _basicAutoCalculatedResult = '';
          break;
        case 'scientific':
          _scientificAutoCalculatedResult = '';
          break;
        case 'advanced':
          _advancedAutoCalculatedResult = '';
          break;
      }
    }
  }

  void startContinuousDelete() {
    _vibrate();

    // Ek baar turant delete
    backspace();

    // Fir repeat delete
    _deleteTimer = Timer.periodic(
      const Duration(milliseconds: 120),
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

    // Clear error after 0.5 seconds (reduced from 1 second)
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
    // Ensure auto-calculated result is cleared for the new mode
    _tryAutoCalculate();
    // Don't clear error message when switching calculator types
    // Error message is already cleared in clear() method, so we need to preserve it
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

    // 1. Smart Minus for Absolute Value: |anydigit| -> |-anydigit|
    // This should work even if isPrevOperator is false (since '|' is not an operator)
    if (operator == '-' &&
        _cursorPosition > 0 &&
        _cursorPosition == currentDisplay.length &&
        currentDisplay.endsWith('|')) {

      int lastPipe = currentDisplay.length - 1;
      int firstPipe = currentDisplay.lastIndexOf('|', lastPipe - 1);

      if (firstPipe != -1) {
        String inside = currentDisplay.substring(firstPipe + 1, lastPipe);
        if (inside.isNotEmpty && !inside.startsWith('-')) {
          final newDisplay = '${currentDisplay.substring(0, firstPipe + 1)}-$inside|';
          _updateDisplayAndExpression(newDisplay);
          _cursorPosition = newDisplay.length;
          notifyListeners();
          return;
        }
      }
    }

    // 2. Standard operator handling
    if (_cursorPosition > 0 && _cursorPosition <= currentDisplay.length) {
      final prevChar = currentDisplay[_cursorPosition - 1];
      final isPrevOperator = '+-×÷%^.'.contains(prevChar);

      if (isPrevOperator) {
        if (operator == '-') {
          // Allow negative sign after operator
          _insertText(operator);
          return;
        }

        if (operator == prevChar) {
          showError('Invalid format');
          return;
        }

        backspace(); // Replace current operator
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
      final currentDisplay = display;

      if (currentExpression.isEmpty) return;

      if (_calculatorType == 'basic') {
        // Add closing bracket if missing
        int openBrackets = '('.allMatches(currentExpression).length;
        int closeBrackets = ')'.allMatches(currentExpression).length;
        if (openBrackets > closeBrackets) {
          _updateDisplayAndExpression('$currentDisplay)');
        }

        if (!CalculatorUtils.isExpressionComplete(expression)) {
          _setErrorState();
          return;
        }

        final originalExpression = expression;
        final result = CalculatorUtils.evaluateExpression(expression);
        final formattedResult = CalculatorUtils.formatResult(result);

        _setResultState(formattedResult);
        _saveToHistory(originalExpression, formattedResult);
      } else {
        // Scientific/Advanced
        int openBrackets = '('.allMatches(expression).length;
        int closeBrackets = ')'.allMatches(expression).length;
        if (openBrackets > closeBrackets) {
          _updateDisplayAndExpression('$currentDisplay)');
        }

        if (!CalculatorUtils.isExpressionComplete(expression)) {
          _setErrorState();
          return;
        }

        final originalExpression = expression;
        final result = CalculatorUtils.evaluateExpression(expression);
        final formattedResult = CalculatorUtils.formatResult(result);

        _setResultState(formattedResult);
        _saveToHistory(originalExpression, formattedResult);
      }
      _moveCursorToEnd();
    } catch (e) {
      _handleCalculationError(e);
    }
  }

  void _setErrorState() {
    switch (_calculatorType) {
      case 'basic': _basicDisplay = 'Error'; _basicIsResult = true; break;
      case 'scientific': _scientificDisplay = 'Error'; _scientificIsResult = true; break;
      case 'advanced': _advancedDisplay = 'Error'; _advancedIsResult = true; break;
    }
    _cursorPosition = display.length;
    notifyListeners();
  }

  void _setResultState(String result) {
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
      case 'basic': _basicDisplay = errorMessage; _basicIsResult = true; break;
      case 'scientific': _scientificDisplay = errorMessage; _scientificIsResult = true; break;
      case 'advanced': _advancedDisplay = errorMessage; _advancedIsResult = true; break;
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
        _basicIsResult = false;
        _basicAutoCalculatedResult = '';
        _basicLastValidResult = '';
        break;
      case 'scientific':
        _scientificDisplay = '';
        _scientificExpression = '';
        _scientificIsResult = false;
        _scientificAutoCalculatedResult = '';
        _scientificLastValidResult = '';
        break;
      case 'advanced':
        _advancedDisplay = '';
        _advancedExpression = '';
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
    if ([
      'sin', 'cos', 'tan', 'log', 'ln', 'sin⁻¹', 'cos⁻¹', 'tan⁻¹'
    ].contains(function)) {
      _insertText('$function(');
    } else if (function == '√' || function == '∛') {
      // Re-enable "wrap" behavior for roots as requested: "jaise ye kaam kar raha tha pahle"
      final currentDisplay = display;

      // If display is empty or error, just insert normally
      if (currentDisplay.isEmpty || currentDisplay == 'Error') {
        _insertText('$function(');
      } else {
        // Prepend root symbol to existing expression
        final nextVal = '$function($currentDisplay';
        _updateDisplayAndExpression(nextVal);
        _moveCursorToEnd();
      }
    } else if ([
      '10ˣ', 'eˣ'
    ].contains(function)) {
      _insertText('$function(');
    } else if (function == 'x²' || function == 'x³') {
      if (!canApplyUnaryOperator) {
        showError('Invalid format');
        return;
      }
      _insertText(function == 'x²' ? '²' : '³');
    } else if (function == '|x|') {
      final currentDisplay = display;
      // Fix: Ensure cursor is within valid bounds of the string before checking character
      if (_cursorPosition > 0 &&
          _cursorPosition <= currentDisplay.length &&
          '0123456789'.contains(currentDisplay[_cursorPosition - 1])) {
        // Wrap previous number behavior requested by user (e.g. "5" -> "|5|")
        // Get the number ending at cursor
        int start = _cursorPosition - 1;
        while (start > 0 && '0123456789.'.contains(currentDisplay[start - 1])) {
          start--;
        }
        final number = currentDisplay.substring(start, _cursorPosition);

        // Delete the number
        for (int i = 0; i < number.length; i++) {
          backspace();
        }

        // Insert wrapped number
        _insertText('|$number|');
      } else {
        // Standard behavior
        _insertText('|');
      }
    } else if (function == 'xʸ') {
      _insertText('^');
    }
    notifyListeners();
  }

  // Helper to check if binary operator is used at start
  bool _isInvalidOperatorWithoutInput(String value) {
    final currentExpression = expression;
    return _binaryOperators.contains(value) &&
        currentExpression.isEmpty &&
        value != '-' &&
        value != '+'; // Allow unary plus (+45) as requested
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
    // Trigger auto-calculation when loading expression from history
    if (shouldAutoCalculate) {
      _tryAutoCalculate();
    }
    notifyListeners();
  }

  void appendSmartBracket() {
    final currentDisplay = display;

    // Count opening and closing brackets
    int openBrackets = '('.allMatches(currentDisplay).length;
    int closeBrackets = ')'.allMatches(currentDisplay).length;

    String bracket;
    if (openBrackets > closeBrackets) {
      // Add closing bracket if there are more opening brackets
      bracket = ')';
    } else {
      // Add opening bracket otherwise
      bracket = '(';
    }

    _insertText(bracket);
    notifyListeners();
  }

  void buttonPressed(String value) {
    // Check if buttons are locked due to error
    if (_buttonsLocked) {
      return; // Ignore button presses when locked
    }

    // Handle backspace button
    if (value == '⌫') {
      backspace();
      return;
    }

    // Handle different calculator types
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
    if (_isBackspacing) return;
    _isBackspacing = true;

    _vibrate();

    // If display shows 'Error', clear everything
    final currentDisplay = display;
    if (currentDisplay == 'Error') {
      clear();
      _isBackspacing = false;
      return;
    }

    // Cursor-based backspace
    if (_cursorPosition > 0 && currentDisplay.isNotEmpty) {
      // Handle special cases: deleting part of a function or constant might need specific logic
      // For now, simpler approach: just delete char before cursor

      // Check bounds
      if (_cursorPosition > currentDisplay.length) _cursorPosition = currentDisplay.length;

      final newDisplay = currentDisplay.substring(0, _cursorPosition - 1) +
                         currentDisplay.substring(_cursorPosition);

      _updateDisplayAndExpression(newDisplay);
      _cursorPosition--;
    }

    if (shouldAutoCalculate) {
      _tryAutoCalculate();
    }

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 100), () {
      _isBackspacing = false;
    });
  }

  void _handleBasicCalculatorInput(String value) {
    // 🚫 Operator without input → INVALID FORMAT
    if (_isInvalidOperatorWithoutInput(value)) {
      _showInvalidFormat();
      return;
    }

    // Check if it's a digit
    if (value == '0' ||
        value == '1' ||
        value == '2' ||
        value == '3' ||
        value == '4' ||
        value == '5' ||
        value == '6' ||
        value == '7' ||
        value == '8' ||
        value == '9') {
      appendDigit(value);
    }
    // Check if it's an operator
    else if (value == '+' || value == '-' || value == '×' || value == '÷') {
      appendOperator(value);
    }
    // Check if it's a special function
    else if (value == 'C') {
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
      // For other functions like scientific functions
      appendFunction(value);
    }
  }

  void _handleScientificCalculatorInput(String value) {
    // 🚫 Operator without input → INVALID FORMAT
    if (_isInvalidOperatorWithoutInput(value)) {
      _showInvalidFormat();
      return;
    }

    // Check if it's a digit
    if (value == '0' ||
        value == '1' ||
        value == '2' ||
        value == '3' ||
        value == '4' ||
        value == '5' ||
        value == '6' ||
        value == '7' ||
        value == '8' ||
        value == '9') {
      appendDigit(value);
    }
    // Operators (only binary operators)
    else if (value == '+' ||
        value == '-' ||
        value == '×' ||
        value == '÷' ||
        value == '^' ||
        value == '%') {
      appendOperator(value);
    }
    // Parentheses
    else if (value == '(' || value == ')') {
      _insertText(value);
    }
    // Constants
    else if (value == 'π') {
      appendConstant('π');
    } else if (value == 'e') {
      appendConstant('e');
    }
    // Factorial
    else if (value == '!') {
      _insertText('!');
    }

    // Scientific functions
    else if (value == 'sin' ||
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
    }
    // Special functions
    else if (value == 'C') {
      clear();
    } else if (value == '±') {
      toggleSign();
    } else if (value == '%') {
       appendOperator('%');
    } else if (value == '.') {
      addDecimal();
    } else if (value == '=') {
      calculate();
    }
  }

  void _handleAdvancedCalculatorInput(String value) {
    // Advanced Calculator should behave exactly like Scientific Calculator
    _handleScientificCalculatorInput(value);
  }

  Future<void> _vibrate() async {
    try {
      // Check if vibration is available on this platform
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 50);
      }
      // If no vibrator available, silently continue (no vibration)
    } catch (e) {
      // If vibration fails for any reason, silently continue
      // This prevents crashes on platforms that don't support vibration
    }
  }

  Future<void> _vibrateStrong() async {
    try {
      // Check if vibration is available on this platform
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100, amplitude: 255);
      }
      // If no vibrator available, silently continue (no vibration)
    } catch (e) {
      // If vibration fails for any reason, silently continue
      // This prevents crashes on platforms that don't support vibration
    }
  }
}
