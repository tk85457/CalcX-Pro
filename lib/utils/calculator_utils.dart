// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:math_expressions/math_expressions.dart';

class CalculatorUtils {
  static const double _epsilon = 1e-10;

  // ─────────────────────────────────────────────
  // CORE PARSER — returns double, throws on error
  // ─────────────────────────────────────────────
  static double _evaluateParsedExpression(String expression) {
    try {
      final p = Parser();
      final exp = p.parse(expression);
      final context = ContextModel()
        ..variables['pi'] = Number(pi)
        ..variables['e'] = Number(e);
      final result = exp.evaluate(EvaluationType.REAL, context);
      final d =
          result is num ? result.toDouble() : double.parse(result.toString());
      if (d.isNaN || d.isInfinite) throw Exception('Math Error');
      return d;
    } catch (err) {
      final s = err.toString();
      if (s.contains('Invalid input') || s.contains('Undefined')) {
        rethrow;
      }
      throw Exception('Math Error');
    }
  }

  // ─────────────────────────────────────────────
  // SIMPLE EXPRESSION EVALUATOR (used inside trig/func handlers)
  // ─────────────────────────────────────────────
  static String _formatIntermediateNum(num val) {
    if (val.isNaN || val.isInfinite) {
      throw Exception('Calculation result undefined');
    }
    final s = val.toString();
    if (s.contains('e') || s.contains('E')) {
      final parts = s.toLowerCase().split('e');
      final mantissa = parts[0];
      final exponent = parts[1];
      return '($mantissa*(10)^($exponent))';
    }
    return s;
  }

  static double _evaluateSimpleExpr(String expr, {bool isRadian = false}) {
    expr = expr.trim();
    final numVal = double.tryParse(expr);
    if (numVal != null) {
      if (numVal.isNaN || numVal.isInfinite) {
        throw Exception('Calculation result undefined');
      }
      return numVal;
    }

    return evaluateExpression(expr, isRadian: isRadian);
  }

  // ─────────────────────────────────────────────
  // BALANCED PARENTHESES FUNCTION REPLACER
  // ─────────────────────────────────────────────
  static String _replaceBalancedFunction(
    String expression,
    String funcName,
    String Function(String arg) replacer, {
    String? negativeLookbehindPrefix,
  }) {
    int searchStart = 0;
    while (searchStart < expression.length) {
      final target = '$funcName(';
      final idx = expression.indexOf(target, searchStart);
      if (idx == -1) break;

      // Check negative lookbehind if required (e.g. 'sin' shouldn't match 'asin')
      if (negativeLookbehindPrefix != null && idx > 0) {
        if (expression.substring(0, idx).endsWith(negativeLookbehindPrefix)) {
          searchStart = idx + target.length;
          continue;
        }
      }

      // Find matching closing parenthesis
      final openParenIdx = idx + funcName.length;
      int depth = 1;
      int closeParenIdx = -1;
      for (int i = openParenIdx + 1; i < expression.length; i++) {
        if (expression[i] == '(') {
          depth++;
        } else if (expression[i] == ')') {
          depth--;
          if (depth == 0) {
            closeParenIdx = i;
            break;
          }
        }
      }

      if (closeParenIdx == -1) {
        searchStart = openParenIdx + 1;
        continue;
      }

      final arg = expression.substring(openParenIdx + 1, closeParenIdx);
      final replacement = replacer(arg);
      expression =
          '${expression.substring(0, idx)}$replacement${expression.substring(closeParenIdx + 1)}';
      searchStart = idx + replacement.length;
    }
    return expression;
  }

  // ─────────────────────────────────────────────
  // INVERSE TRIG HANDLER (degree or radian mode)
  // ─────────────────────────────────────────────
  static String _handleInverseTrigFunctions(String expression,
      {bool isRadian = false}) {
    String old;
    do {
      old = expression;
      expression = _replaceBalancedFunction(expression, 'asin', (arg) {
        final v = _evaluateSimpleExpr(arg, isRadian: isRadian);
        if (v < -1 || v > 1) {
          throw Exception('Invalid input for sin\u207b\u00b9');
        }
        final rad = asin(v);
        return isRadian
            ? _formatIntermediateNum(rad)
            : _formatIntermediateNum(rad * 180 / pi);
      });
      expression = _replaceBalancedFunction(expression, 'acos', (arg) {
        final v = _evaluateSimpleExpr(arg, isRadian: isRadian);
        if (v < -1 || v > 1) {
          throw Exception('Invalid input for cos\u207b\u00b9');
        }
        final rad = acos(v);
        return isRadian
            ? _formatIntermediateNum(rad)
            : _formatIntermediateNum(rad * 180 / pi);
      });
      expression = _replaceBalancedFunction(expression, 'atan', (arg) {
        final v = _evaluateSimpleExpr(arg, isRadian: isRadian);
        final rad = atan(v);
        return isRadian
            ? _formatIntermediateNum(rad)
            : _formatIntermediateNum(rad * 180 / pi);
      });
    } while (expression != old);
    return expression;
  }

  // ─────────────────────────────────────────────
  // TRIG HANDLER (degree or radian mode)
  // ─────────────────────────────────────────────
  static String _handleTrigFunctions(String expression,
      {bool isRadian = false}) {
    String old;
    do {
      old = expression;
      // sin — negativeLookbehind 'a' prevents matching 'asin'
      expression = _replaceBalancedFunction(expression, 'sin', (arg) {
        final val = _evaluateSimpleExpr(arg, isRadian: isRadian);
        final rad = isRadian ? val : (val * pi / 180);
        double result = sin(rad);
        if (result.abs() < _epsilon) result = 0;
        return _formatIntermediateNum(result);
      }, negativeLookbehindPrefix: 'a');

      // cos — negativeLookbehind 'a' prevents matching 'acos'
      expression = _replaceBalancedFunction(expression, 'cos', (arg) {
        final val = _evaluateSimpleExpr(arg, isRadian: isRadian);
        final rad = isRadian ? val : (val * pi / 180);
        double result = cos(rad);
        if (result.abs() < _epsilon) result = 0;
        return _formatIntermediateNum(result);
      }, negativeLookbehindPrefix: 'a');

      // tan — negativeLookbehind 'a' prevents matching 'atan'
      expression = _replaceBalancedFunction(expression, 'tan', (arg) {
        final val = _evaluateSimpleExpr(arg, isRadian: isRadian);
        if (!isRadian) {
          final normDeg = ((val % 360) + 360) % 360;
          if ((normDeg - 90).abs() < _epsilon ||
              (normDeg - 270).abs() < _epsilon) {
            throw Exception('Math Error');
          }
        } else {
          final halfPi = pi / 2;
          final normRad = ((val % pi) + pi) % pi;
          if ((normRad - halfPi).abs() < _epsilon) {
            throw Exception('Math Error');
          }
        }
        final rad = isRadian ? val : (val * pi / 180);
        double result = tan(rad);
        if (result.abs() < _epsilon) result = 0;
        return _formatIntermediateNum(result);
      }, negativeLookbehindPrefix: 'a');
    } while (expression != old);
    return expression;
  }

  // ─────────────────────────────────────────────
  // SPECIAL FUNCTIONS HANDLER
  // ─────────────────────────────────────────────
  static String _handleSpecialFunctions(String expression,
      {bool isRadian = false}) {
    String old;
    do {
      old = expression;

      // log base 10
      expression = _replaceBalancedFunction(expression, 'log', (arg) {
        final v = _evaluateSimpleExpr(arg, isRadian: isRadian);
        if (v <= 0) throw Exception('Invalid input for log');
        return _formatIntermediateNum(log(v) / ln10);
      });

      // natural log
      expression = _replaceBalancedFunction(expression, 'ln', (arg) {
        final v = _evaluateSimpleExpr(arg, isRadian: isRadian);
        if (v <= 0) throw Exception('Invalid input for ln');
        return _formatIntermediateNum(log(v));
      });

      // square root
      expression = _replaceBalancedFunction(expression, 'sqrt', (arg) {
        final v = _evaluateSimpleExpr(arg, isRadian: isRadian);
        if (v < 0) throw Exception('Invalid input for sqrt');
        return _formatIntermediateNum(sqrt(v));
      });

      // cube root
      expression = _replaceBalancedFunction(expression, 'cbrt', (arg) {
        final v = _evaluateSimpleExpr(arg, isRadian: isRadian);
        return _formatIntermediateNum(v < 0 ? -pow(-v, 1 / 3) : pow(v, 1 / 3));
      });

      // factorial — fact(n)
      expression = _replaceBalancedFunction(expression, 'fact', (arg) {
        final v = _evaluateSimpleExpr(arg, isRadian: isRadian);
        final n = v.round();
        if (n < 0 || n > 170) throw Exception('Math Error');
        double result = 1;
        for (int i = 2; i <= n; i++) {
          result *= i;
        }
        return _formatIntermediateNum(result);
      });

      // absolute value
      expression = _replaceBalancedFunction(expression, 'abs', (arg) {
        final v = _evaluateSimpleExpr(arg, isRadian: isRadian);
        return _formatIntermediateNum(v.abs());
      });
    } while (expression != old);
    return expression;
  }

  // ─────────────────────────────────────────────
  // HANDLE PIPE ABSOLUTE VALUE: |expr| → abs(expr)
  // ─────────────────────────────────────────────
  static String _handlePipeAbsoluteValue(String expression) {
    String old;
    do {
      old = expression;
      expression = expression.replaceAllMapped(
          RegExp(r'\|([^|]+)\|'), (m) => 'abs(${m.group(1)})');
    } while (expression != old);
    return expression;
  }

  // ─────────────────────────────────────────────
  // SEQUENTIAL PERCENTAGE EXPANSION
  // ─────────────────────────────────────────────
  static String _expandPercentages(String s) {
    while (true) {
      final pctIdx = s.indexOf('%');
      if (pctIdx == -1) break;

      // Extract number immediately before %
      int numEnd = pctIdx;
      while (numEnd > 0 && s[numEnd - 1] == ' ') {
        numEnd--;
      }
      int numStart = numEnd;
      while (numStart > 0 && RegExp(r'[0-9\.]').hasMatch(s[numStart - 1])) {
        numStart--;
      }
      final numStr = s.substring(numStart, numEnd).trim();

      // Check if preceded by + or -
      int opIdx = numStart - 1;
      while (opIdx >= 0 && s[opIdx] == ' ') {
        opIdx--;
      }

      if (opIdx >= 0 && (s[opIdx] == '+' || s[opIdx] == '-')) {
        final op = s[opIdx];
        // Find the LHS expression before op (within current parenthesis scope)
        int lhsEnd = opIdx;
        while (lhsEnd > 0 && s[lhsEnd - 1] == ' ') {
          lhsEnd--;
        }
        int lhsStart = lhsEnd;
        int depth = 0;
        while (lhsStart > 0) {
          final ch = s[lhsStart - 1];
          if (ch == ')') {
            depth++;
          } else if (ch == '(') {
            if (depth == 0) break;
            depth--;
          } else if (depth == 0 && ch == ',') {
            break;
          }
          lhsStart--;
        }

        final lhs = s.substring(lhsStart, lhsEnd).trim();
        if (lhs.isNotEmpty && numStr.isNotEmpty) {
          final replacement = '($lhs $op ($lhs * ($numStr / 100)))';
          s = '${s.substring(0, lhsStart)}$replacement${s.substring(pctIdx + 1)}';
          continue;
        }
      }

      // If preceded by ')' e.g. "(10 + 20)%" => "((10 + 20) / 100)"
      if (numStr.isEmpty && numEnd > 0 && s[numEnd - 1] == ')') {
        int depth = 1;
        int parenStart = numEnd - 1;
        while (parenStart > 0 && depth > 0) {
          parenStart--;
          if (s[parenStart] == ')') depth++;
          if (s[parenStart] == '(') depth--;
        }
        final parenExpr = s.substring(parenStart, numEnd);
        s = '${s.substring(0, parenStart)}($parenExpr / 100)${s.substring(pctIdx + 1)}';
        continue;
      }

      if (numStr.isNotEmpty) {
        s = '${s.substring(0, numStart)}($numStr / 100)${s.substring(pctIdx + 1)}';
      } else {
        s = '${s.substring(0, pctIdx)}${s.substring(pctIdx + 1)}';
      }
    }
    return s;
  }

  // ─────────────────────────────────────────────
  // CLEAN EXPRESSION (display symbols → math + implicit multiplication)
  // ─────────────────────────────────────────────
  static String cleanExpression(String expression) {
    String s = expression
        .replaceAll('\u00d7', '*') // × → *
        .replaceAll('\u00f7', '/') // ÷ → /
        .replaceAll('\u2212', '-') // − → -
        .replaceAll('\u03c0', 'pi') // π → pi
        .replaceAll('x\u00b2', '^2') // x² → ^2
        .replaceAll('x\u00b3', '^3') // x³ → ^3
        .replaceAll('\u00b2', '^2') // ² → ^2 (standalone)
        .replaceAll('\u00b3', '^3') // ³ → ^3 (standalone)
        .replaceAll('10\u02e3(', '(10)^(') // 10ˣ( → (10)^(
        .replaceAll('e\u02e3(', '($e)^(') // eˣ( → ($e)^(
        .replaceAll('sin\u207b\u00b9(', 'asin(') // sin⁻¹( → asin(
        .replaceAll('cos\u207b\u00b9(', 'acos(') // cos⁻¹( → acos(
        .replaceAll('tan\u207b\u00b9(', 'atan(') // tan⁻¹( → atan(
        .replaceAllMapped(
          RegExp(r'\u221a(?!\()(\d+(?:\.\d+)?)'),
          (m) => 'sqrt(${m.group(1)})',
        )
        .replaceAllMapped(
          RegExp(r'\u221b(?!\()(\d+(?:\.\d+)?)'),
          (m) => 'cbrt(${m.group(1)})',
        )
        .replaceAll('\u221a(', 'sqrt(') // √( → sqrt(
        .replaceAll('\u221b(', 'cbrt(') // ∛( → cbrt(
        .replaceAll('\u221a', 'sqrt(')
        .replaceAll('\u221b', 'cbrt(')
        .replaceAllMapped(RegExp(r'(\d+)!'), (m) => 'fact(${m.group(1)})')
        .replaceAll('!(', 'fact(');

    // Percentage handling with accumulated left-hand subtotal
    s = _expandPercentages(s);

    // Handle distinct scientific-notation marker 'E' emitted by formatResult
    s = s.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)E([\+\-]?\d+)'),
      (m) => '(${m.group(1)}*(10)^(${m.group(2)}))',
    );

    // Implicit multiplication:
    // 1. (digit, ), pi, e) followed by ( or pi, OR (digit, ), pi) followed by e
    s = s.replaceAllMapped(
      RegExp(r'(\d|\)|pi|e)(?=[(]|pi\b)|(\d|\)|pi)(?=e)'),
      (m) => '${m.group(0)}*',
    );
    // 2. (digit, ), pi, e) followed by scientific function names
    s = s.replaceAllMapped(
      RegExp(r'(\d|\)|pi|e)(?=(asin|acos|atan|sin|cos|tan|log|ln|sqrt|cbrt|abs|fact))'),
      (m) => '${m.group(1)}*',
    );
    // 3. ) or constant followed by digit
    s = s.replaceAllMapped(
      RegExp(r'(\)|pi|e)(?=\d)'),
      (m) => '${m.group(1)}*',
    );

    // Replace isolated e with exact numeric value to avoid math_expressions lexer RangeError
    s = s.replaceAll(RegExp(r'\be\b'), e.toString());

    return s;
  }

  // ─────────────────────────────────────────────
  // AUTO-CLOSE BRACKETS & PIPES
  // ─────────────────────────────────────────────
  static String autoCloseBrackets(String expression) {
    int open = '('.allMatches(expression).length;
    int close = ')'.allMatches(expression).length;
    if (open > close) {
      expression = '$expression${")" * (open - close)}';
    }
    int pipes = '|'.allMatches(expression).length;
    if (pipes % 2 != 0) {
      expression = '$expression|';
    }
    return expression;
  }

  // ─────────────────────────────────────────────
  // FORMAT RESULT (double → display string)
  // ─────────────────────────────────────────────
  static String formatResult(double result, {int maxDecimals = 9}) {
    if (result.abs() < _epsilon) return '0';

    // Integer result
    if (result == result.roundToDouble() && result.abs() < 1e15) {
      return result.toInt().toString();
    }

    // Very large or very small → scientific notation with uppercase 'E' marker
    if (result.abs() >= 1e15 || (result.abs() < 1e-6 && result != 0)) {
      String sci = result.toStringAsExponential(8);
      // Trim trailing zeros in mantissa
      sci = sci.replaceAllMapped(
          RegExp(r'(\.\d*?)0+(e)'), (m) => '${m.group(1)}${m.group(2)}');
      sci = sci.replaceAllMapped(RegExp(r'\.(e)'), (m) => m.group(1)!);
      sci = sci.replaceAll('e', 'E');
      return sci;
    }

    // Regular decimal — trim trailing zeros only when decimal point is present
    String s = result.toStringAsFixed(maxDecimals);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  // ─────────────────────────────────────────────
  // PUBLIC API — evaluateExpression
  // ─────────────────────────────────────────────
  static double evaluateExpression(String expression, {bool isRadian = false}) {
    if (expression.trim().isEmpty) throw Exception('Empty expression');

    // Step 1: Clean display symbols + implicit multiplication
    String cleaned = cleanExpression(expression);

    // Step 2: Handle |x| pipe notation → abs(x)
    cleaned = _handlePipeAbsoluteValue(cleaned);

    // Step 3: Inverse trig first (asin, acos, atan)
    cleaned = _handleInverseTrigFunctions(cleaned, isRadian: isRadian);

    // Step 4: Forward trig (degree or radian mode)
    cleaned = _handleTrigFunctions(cleaned, isRadian: isRadian);

    // Step 5: log, ln, sqrt, cbrt, fact, abs
    cleaned = _handleSpecialFunctions(cleaned, isRadian: isRadian);

    // Step 6: Final arithmetic via parser
    return _evaluateParsedExpression(cleaned);
  }

  // ─────────────────────────────────────────────
  // PUBLIC API — evaluate (string convenience wrapper)
  // ─────────────────────────────────────────────
  static String evaluate(String expression, {bool isRadian = false}) {
    try {
      final result = evaluateExpression(expression, isRadian: isRadian);
      return formatResult(result);
    } on Exception catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      return msg.isEmpty ? 'Math Error' : msg;
    } catch (_) {
      return 'Math Error';
    }
  }

  // ─────────────────────────────────────────────
  // PUBLIC API — getAutoCalculationPreview
  // ─────────────────────────────────────────────
  static String? getAutoCalculationPreview(String expression,
      {bool isRadian = false}) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) return null;
    if (!RegExp(r'\d|π|e').hasMatch(trimmed)) return null;

    // Do not preview if expression ends with an active operator
    if (RegExp(r'[+\-×÷^,]$').hasMatch(trimmed)) return null;

    String balanced = autoCloseBrackets(trimmed);
    int pipes = '|'.allMatches(balanced).length;
    if (pipes % 2 != 0) {
      balanced = '$balanced|';
    }

    try {
      final res = evaluateExpression(balanced, isRadian: isRadian);
      if (res.isNaN || res.isInfinite) return null;
      return formatResult(res);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // PUBLIC API — isExpressionComplete
  // ─────────────────────────────────────────────
  static bool isExpressionComplete(String expression) {
    if (expression.trim().isEmpty) return false;
    if (!RegExp(r'\d|π|e').hasMatch(expression)) return false;
    // Must not end with operator or open paren
    if (RegExp(r'[+\-\u00d7\u00f7\^(,]$').hasMatch(expression.trim())) {
      return false;
    }
    // Brackets must be balanced
    int depth = 0;
    for (final ch in expression.runes) {
      if (ch == 0x28) depth++;
      if (ch == 0x29) depth--;
      if (depth < 0) return false;
    }
    return depth == 0;
  }

  // Legacy alias
  static bool isValidForEval(String expression) =>
      isExpressionComplete(expression);
}
