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
        ..variables['e'] = Number(e)
        ..variables['e_const'] = Number(e);
      final result = exp.evaluate(EvaluationType.REAL, context);
      final d =
          result is num ? result.toDouble() : double.parse(result.toString());
      if (d.isNaN || d.isInfinite) throw Exception('Math Error');
      return d;
    } catch (err) {
      final s = err.toString();
      if (s.contains('Invalid input') ||
          s.contains('Undefined') ||
          s.contains('e_const')) {
        rethrow;
      }
      throw Exception('Math Error');
    }
  }

  // ─────────────────────────────────────────────
  // SIMPLE EXPRESSION EVALUATOR (used inside trig handlers)
  // ─────────────────────────────────────────────
  static double _evaluateSimpleExpr(String expr) {
    expr = expr.trim();
    try {
      final p = Parser();
      final exp = p.parse(expr);
      final ctx = ContextModel()
        ..variables['pi'] = Number(pi)
        ..variables['e'] = Number(e)
        ..variables['e_const'] = Number(e);
      final res = exp.evaluate(EvaluationType.REAL, ctx);
      return res is num ? res.toDouble() : double.parse(res.toString());
    } catch (_) {
      return double.parse(expr);
    }
  }

  // ─────────────────────────────────────────────
  // INVERSE TRIG HANDLER (degree mode)
  // ─────────────────────────────────────────────
  static String _handleInverseTrigFunctions(String expression) {
    String old;
    do {
      old = expression;
      expression =
          expression.replaceAllMapped(RegExp(r'asin\(([^()]+)\)'), (m) {
        final v = _evaluateSimpleExpr(m.group(1)!);
        if (v < -1 || v > 1) {
          throw Exception('Invalid input for sin\u207b\u00b9');
        }
        return (asin(v) * 180 / pi).toString();
      });
      expression =
          expression.replaceAllMapped(RegExp(r'acos\(([^()]+)\)'), (m) {
        final v = _evaluateSimpleExpr(m.group(1)!);
        if (v < -1 || v > 1) {
          throw Exception('Invalid input for cos\u207b\u00b9');
        }
        return (acos(v) * 180 / pi).toString();
      });
      expression =
          expression.replaceAllMapped(RegExp(r'atan\(([^()]+)\)'), (m) {
        final v = _evaluateSimpleExpr(m.group(1)!);
        return (atan(v) * 180 / pi).toString();
      });
    } while (expression != old);
    return expression;
  }

  // ─────────────────────────────────────────────
  // TRIG HANDLER (degree mode)
  // ─────────────────────────────────────────────
  static String _handleTrigFunctions(String expression) {
    String old;
    do {
      old = expression;
      // sin — (?<!a) prevents matching asin
      expression =
          expression.replaceAllMapped(RegExp(r'(?<!a)sin\(([^()]+)\)'), (m) {
        final deg = _evaluateSimpleExpr(m.group(1)!);
        final rad = deg * pi / 180;
        double result = sin(rad);
        if (result.abs() < _epsilon) result = 0;
        return result.toString();
      });
      // cos — (?<!a) prevents matching acos
      expression =
          expression.replaceAllMapped(RegExp(r'(?<!a)cos\(([^()]+)\)'), (m) {
        final deg = _evaluateSimpleExpr(m.group(1)!);
        final rad = deg * pi / 180;
        double result = cos(rad);
        if (result.abs() < _epsilon) result = 0;
        return result.toString();
      });
      // tan — (?<!a) prevents matching atan
      expression =
          expression.replaceAllMapped(RegExp(r'(?<!a)tan\(([^()]+)\)'), (m) {
        final deg = _evaluateSimpleExpr(m.group(1)!);
        final normDeg = deg % 360;
        if ((normDeg - 90).abs() < _epsilon ||
            (normDeg - 270).abs() < _epsilon) {
          throw Exception('Math Error');
        }
        final rad = deg * pi / 180;
        double result = tan(rad);
        if (result.abs() < _epsilon) result = 0;
        return result.toString();
      });
    } while (expression != old);
    return expression;
  }

  // ─────────────────────────────────────────────
  // SPECIAL FUNCTIONS HANDLER
  // ─────────────────────────────────────────────
  static String _handleSpecialFunctions(String expression) {
    String old;
    do {
      old = expression;

      // log base 10
      expression = expression.replaceAllMapped(RegExp(r'log\(([^()]+)\)'), (m) {
        final v = _evaluateSimpleExpr(m.group(1)!);
        if (v <= 0) throw Exception('Invalid input for log');
        return (log(v) / ln10).toString();
      });

      // natural log
      expression = expression.replaceAllMapped(RegExp(r'ln\(([^()]+)\)'), (m) {
        final v = _evaluateSimpleExpr(m.group(1)!);
        if (v <= 0) throw Exception('Invalid input for ln');
        return log(v).toString();
      });

      // square root
      expression =
          expression.replaceAllMapped(RegExp(r'sqrt\(([^()]+)\)'), (m) {
        final v = _evaluateSimpleExpr(m.group(1)!);
        if (v < 0) throw Exception('Invalid input for sqrt');
        return sqrt(v).toString();
      });

      // cube root
      expression =
          expression.replaceAllMapped(RegExp(r'cbrt\(([^()]+)\)'), (m) {
        final v = _evaluateSimpleExpr(m.group(1)!);
        return (v < 0 ? -pow(-v, 1 / 3) : pow(v, 1 / 3)).toString();
      });

      // factorial — both fact(n) and postfix n!
      expression =
          expression.replaceAllMapped(RegExp(r'fact\(([^()]+)\)'), (m) {
        final v = _evaluateSimpleExpr(m.group(1)!);
        final n = v.round();
        if (n < 0 || n > 170) throw Exception('Math Error');
        double result = 1;
        for (int i = 2; i <= n; i++) {
          result *= i;
        }
        return result.toString();
      });

      // absolute value — handles |expr| pipe notation
      expression = expression.replaceAllMapped(RegExp(r'abs\(([^()]+)\)'), (m) {
        final v = _evaluateSimpleExpr(m.group(1)!);
        return v.abs().toString();
      });
    } while (expression != old);
    return expression;
  }

  // ─────────────────────────────────────────────
  // HANDLE PIPE ABSOLUTE VALUE: |expr| → abs(expr)
  // ─────────────────────────────────────────────
  static String _handlePipeAbsoluteValue(String expression) {
    // Convert |expr| notation to abs(expr)
    // Handle nested pipes carefully — process innermost first
    String old;
    do {
      old = expression;
      expression = expression.replaceAllMapped(
          RegExp(r'\|([^|]+)\|'), (m) => 'abs(${m.group(1)})');
    } while (expression != old);
    return expression;
  }

  // ─────────────────────────────────────────────
  // CLEAN EXPRESSION (display symbols → math)
  // ─────────────────────────────────────────────
  static String cleanExpression(String expression) {
    return expression
        .replaceAll('\u00d7', '*') // × → *
        .replaceAll('\u00f7', '/') // ÷ → /
        .replaceAll('\u2212', '-') // − → -
        .replaceAll('\u03c0', 'pi') // π → pi
        .replaceAll('x\u00b2', '^2') // x² → ^2
        .replaceAll('x\u00b3', '^3') // x³ → ^3
        .replaceAll('\u00b2', '^2') // ² → ^2 (standalone)
        .replaceAll('\u00b3', '^3') // ³ → ^3 (standalone)
        .replaceAll('10\u02e3(', '10^(') // 10ˣ( → 10^(
        .replaceAll('e\u02e3(', 'e_const^(') // eˣ( → e_const^(
        .replaceAll('sin\u207b\u00b9(', 'asin(') // sin⁻¹( → asin(
        .replaceAll('cos\u207b\u00b9(', 'acos(') // cos⁻¹( → acos(
        .replaceAll('tan\u207b\u00b9(', 'atan(') // tan⁻¹( → atan(
        .replaceAll('\u221a(', 'sqrt(') // √( → sqrt(
        .replaceAll('\u221b(', 'cbrt(') // ∛( → cbrt(
        // Postfix factorial: 5! → fact(5)
        .replaceAllMapped(RegExp(r'(\d+)!'), (m) => 'fact(${m.group(1)})')
        // Prefix factorial: !( → fact(  (if user typed !(n))
        .replaceAll('!(', 'fact(');
  }

  // ─────────────────────────────────────────────
  // FORMAT RESULT (double → display string)
  // ─────────────────────────────────────────────
  static String formatResult(double result) {
    if (result.abs() < _epsilon) return '0';

    // Integer result
    if (result == result.roundToDouble() && result.abs() < 1e15) {
      return result.toInt().toString();
    }

    // Very large or very small → scientific notation
    if (result.abs() >= 1e15 || (result.abs() < 1e-6 && result != 0)) {
      String sci = result.toStringAsExponential(8);
      // Trim trailing zeros in mantissa
      sci = sci.replaceAllMapped(
          RegExp(r'(\.\d*?)0+(e)'), (m) => '${m.group(1)}${m.group(2)}');
      sci = sci.replaceAllMapped(RegExp(r'\.(e)'), (m) => m.group(1)!);
      return sci;
    }

    // Regular decimal — trim trailing zeros
    String s = result.toStringAsFixed(10);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  // ─────────────────────────────────────────────
  // PUBLIC API — evaluateExpression
  // ─────────────────────────────────────────────
  static double evaluateExpression(String expression) {
    if (expression.trim().isEmpty) throw Exception('Empty expression');

    // Step 1: Clean display symbols → math
    String cleaned = cleanExpression(expression);

    // Step 2: Handle |x| pipe notation → abs(x)
    cleaned = _handlePipeAbsoluteValue(cleaned);

    // Step 3: Inverse trig first (asin, acos, atan)
    cleaned = _handleInverseTrigFunctions(cleaned);

    // Step 4: Forward trig (degree mode)
    cleaned = _handleTrigFunctions(cleaned);

    // Step 5: log, ln, sqrt, cbrt, fact, abs
    cleaned = _handleSpecialFunctions(cleaned);

    // Step 6: Final arithmetic via parser
    return _evaluateParsedExpression(cleaned);
  }

  // ─────────────────────────────────────────────
  // PUBLIC API — evaluate (string convenience wrapper)
  // ─────────────────────────────────────────────
  static String evaluate(String expression) {
    try {
      final result = evaluateExpression(expression);
      return formatResult(result);
    } on Exception catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      return msg.isEmpty ? 'Math Error' : msg;
    } catch (_) {
      return 'Math Error';
    }
  }

  // ─────────────────────────────────────────────
  // PUBLIC API — isExpressionComplete
  // ─────────────────────────────────────────────
  static bool isExpressionComplete(String expression) {
    if (expression.trim().isEmpty) return false;
    if (!RegExp(r'\d').hasMatch(expression)) return false;
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
