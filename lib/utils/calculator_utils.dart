// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:math_expressions/math_expressions.dart';

class CalculatorUtils {
  static double _evaluateParsedExpression(String expression) {
    final p = GrammarParser();
    final exp = p.parse(expression);

    final context = ContextModel()
      ..variables['pi'] = Number(pi)
      ..variables['e'] = Number(e);

    final result = exp.evaluate(
        EvaluationType.REAL, context);
    final resultAsDouble =
        result is num ? result.toDouble() : double.parse(result.toString());

    if (resultAsDouble.isNaN || result.isInfinite) {
      throw Exception("Math Error");
    }

    return resultAsDouble;
  }

  static String _handleInverseTrigFunctions(String expression) {
    // Handle inverse trig functions by evaluating them directly
    expression = expression.replaceAllMapped(
      RegExp(r'asin\(([^)]+)\)'),
      (match) {
        try {
          String arg = match.group(1)!;
          // Evaluate the argument first if it's an expression
          double argValue = _evaluateSimpleExpression(arg);
          double result = asin(argValue) * 180 / pi; // Convert to degrees
          return result.toString();
        } catch (e) {
          throw Exception('Invalid input for asin');
        }
      },
    );

    expression = expression.replaceAllMapped(
      RegExp(r'acos\(([^)]+)\)'),
      (match) {
        try {
          String arg = match.group(1)!;
          double argValue = _evaluateSimpleExpression(arg);
          double result = acos(argValue) * 180 / pi; // Convert to degrees
          return result.toString();
        } catch (e) {
          throw Exception('Invalid input for acos');
        }
      },
    );

    expression = expression.replaceAllMapped(
      RegExp(r'atan\(([^)]+)\)'),
      (match) {
        try {
          String arg = match.group(1)!;
          double argValue = _evaluateSimpleExpression(arg);
          double result = atan(argValue) * 180 / pi; // Convert to degrees
          return result.toString();
        } catch (e) {
          throw Exception('Invalid input for atan');
        }
      },
    );

    return expression;
  }

  static double _evaluateSimpleExpression(String expression) {
    // For simple expressions inside inverse trig functions
    if (double.tryParse(expression) != null) {
      return double.parse(expression);
    }

    // Handle pi and e
    expression = expression.replaceAll('pi', pi.toString());
    expression = expression.replaceAll('e', e.toString());

    // Try to evaluate simple expressions
    try {
      final p = GrammarParser();
      final exp = p.parse(expression);
      final context = ContextModel();
      final result = exp.evaluate(
          EvaluationType.REAL, context);
      return result is num
          ? result.toDouble()
          : double.parse(result.toString());
    } catch (e) {
      throw Exception('Cannot evaluate argument: $expression');
    }
  }

  static bool _isPureInverseTrigExpression(String input) {
    // Check if the input is a pure inverse trig function like sin⁻¹(0), cos⁻¹(1), tan⁻¹(6)
    return RegExp(r'^sin⁻¹\([^)]+\)$|^cos⁻¹\([^)]+\)$|^tan⁻¹\([^)]+\)$')
        .hasMatch(input);
  }

  static double _evaluatePureInverseTrigExpression(String input) {
    // Handle pure inverse trig expressions directly
    if (input.startsWith('sin⁻¹(')) {
      String arg = input.substring(6, input.length - 1); // Extract argument
      double argValue = double.tryParse(arg) ?? 0;
      return asin(argValue) * 180 / pi;
    } else if (input.startsWith('cos⁻¹(')) {
      String arg = input.substring(6, input.length - 1);
      double argValue = double.tryParse(arg) ?? 0;
      return acos(argValue) * 180 / pi;
    } else if (input.startsWith('tan⁻¹(')) {
      String arg = input.substring(6, input.length - 1);
      double argValue = double.tryParse(arg) ?? 0;
      return atan(argValue) * 180 / pi;
    }
    throw Exception('Invalid inverse trig expression');
  }

  static bool _isValidExpression(String input) {
    if (input.isEmpty) return false;

    // Check for consecutive absolute value symbols (more than 2 in a row)
    if (input.contains('|||')) {
      return false;
    }

    // Check for malformed absolute value expressions
    int absCount = 0;
    bool hasContentBetweenAbs = false;
    for (int i = 0; i < input.length; i++) {
      if (input[i] == '|') {
        absCount++;
        // Check if there's content between consecutive | symbols
        if (i > 0 && input[i - 1] == '|') {
          hasContentBetweenAbs = false;
        } else if (absCount > 1) {
          hasContentBetweenAbs = true;
        }
      }
    }

    // If we have multiple | symbols but no content between them, it's invalid
    if (absCount > 2 && !hasContentBetweenAbs) {
      return false;
    }

    return true;
  }

  static double evaluateExpression(String input) {
    try {
      // Validate the input expression first
      if (!_isValidExpression(input)) {
        throw Exception('Invalid expression format');
      }

      // Check if this is a pure inverse trig function expression
      if (_isPureInverseTrigExpression(input)) {
        return _evaluatePureInverseTrigExpression(input);
      }

      // First, try to evaluate the expression as is
      String expression = input;

      // 🔥 Inverse Trigonometry Mapping (UI symbols to math engine)
      // Convert UI symbols to math functions BEFORE any other processing
      expression = expression
          .replaceAll('sin⁻¹', 'asin')
          .replaceAll('cos⁻¹', 'acos')
          .replaceAll('tan⁻¹', 'atan');

      // Handle inverse trig functions immediately after mapping
      expression = _handleInverseTrigFunctions(expression);

      // Add missing closing brackets if needed (including absolute values)
      expression = _addMissingClosingBrackets(expression);

      // Preprocess the input to handle UI symbols
      try {
        expression = _preprocess(expression);
      } catch (e) {
        // If preprocessing fails, return an error
        // Debug: Preprocessing error
        throw Exception('Invalid expression');
      }

      // Handle trigonometric functions with degree conversion
      expression = _convertTrigFunctionsToDegrees(expression);

      // Handle inverse trig functions using Dart math library (after all preprocessing)
      expression = _handleInverseTrigFunctions(expression);

      // Evaluate the expression
      return _evaluateParsedExpression(expression);
    } catch (e) {
      // Check if the error is due to an incomplete expression that we can fix
      if (!isExpressionComplete(input)) {
        // Try to fix the expression by adding missing brackets
        String fixedExpression = _addMissingClosingBrackets(input);
        if (fixedExpression != input) {
          // Try evaluating the fixed expression
          try {
            String expression = fixedExpression;
            expression = _preprocess(expression);
            expression = _convertTrigFunctionsToDegrees(expression);

            return _evaluateParsedExpression(expression);
          } catch (retryError) {
            // If retry also fails, continue with original error handling
          }
        }
      }

      // Handle specific math errors
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('division by zero')) {
        throw Exception('Division by zero');
      } else if (errorString.contains('undefined') ||
          errorString.contains('not defined')) {
        throw Exception('Undefined');
      } else if (errorString.contains('invalid input') ||
          errorString.contains('domain')) {
        throw Exception('Invalid input');
      } else if (errorString.contains('outside')) {
        throw Exception('Invalid input');
      } else if (errorString.contains('factorial')) {
        throw Exception('Invalid factorial');
      } else if (errorString.contains('rangeerror') ||
          errorString.contains('index') ||
          errorString.contains('stack overflow')) {
        // Handle range errors and other parsing errors gracefully
        throw Exception('Invalid expression');
      } else {
        // Debug: Evaluation error for expression
      }
      throw Exception('Error');
    }
  }

  // Add missing closing brackets to expressions
  static String _addMissingClosingBrackets(String expression) {
    // Count opening and closing brackets
    int openCount = 0;
    int closeCount = 0;
    List<int> bracketPositions = [];

    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') {
        openCount++;
        bracketPositions.add(i);
      } else if (expression[i] == ')') {
        closeCount++;
      }
    }

    // Add missing closing brackets if needed
    if (openCount > closeCount) {
      int missingBrackets = openCount - closeCount;
      for (int i = 0; i < missingBrackets; i++) {
        expression += ')';
      }
    }

    // Handle absolute value brackets more carefully
    // Process | symbols from left to right, pairing them properly
    String result = '';
    bool inAbsValue = false;
    int absStart = -1;

    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '|') {
        if (!inAbsValue) {
          // Start of absolute value
          inAbsValue = true;
          absStart = result.length;
          result += '|';
        } else {
          // End of absolute value - check if we have content
          if (absStart != -1 && result.length > absStart) {
            inAbsValue = false;
            result += '|';
          } else {
            // Empty absolute value, treat as unpaired
            result += '|';
          }
        }
      } else {
        result += expression[i];
      }
    }

    // If we end with an unclosed absolute value, close it
    if (inAbsValue) {
      result += '|';
    }

    return result;
  }

  // ================= helpers =================

  static String cleanExpression(String exp) {
    // First, handle powers and special cases before removing 'x'
    exp = exp
        // powers - handle x² and x³ before removing 'x'
        .replaceAll('x²', '^2')
        .replaceAll('x³', '^3')
        // operators
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-') // minus sign to regular minus
        // constants
        .replaceAll('π', 'pi')
        .replaceAll('e', '2.718281828459045')
        // inverse trig - handled separately in evaluateExpression
        // log base 10: log(x) = ln(x)/ln(10)
        .replaceAllMapped(
          RegExp(r'log\(([^)]+)\)'),
          (m) => 'ln(${m[1]})/ln(10)',
        )
        // remaining powers
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('ˣ', '^')
        // cube root: ∛x = x^(1/3) - handle both single numbers and expressions in parentheses
        .replaceAllMapped(
          RegExp(r'∛\(([^)]+)\)'),
          (m) => '(${m[1]})^(1/3)',
        )
        .replaceAllMapped(
          RegExp(r'∛(\d+(\.\d+)?)'),
          (m) => '(${m[1]})^(1/3)',
        )
        // absolute value
        .replaceAllMapped(
          RegExp(r'\|([^|]+)\|'),
          (m) => 'abs(${m[1]})',
        )
        // remove invalid variable x (but not the ones already processed in x², x³)
        .replaceAll('x', '');

    // Handle implicit multiplication patterns
    // Pattern: number followed by pi (e.g., 3π -> 3*pi)
    exp = exp.replaceAllMapped(
        RegExp(r'(\d)(pi)'), (m) => '${m.group(1)}*${m.group(2)}');

    // Pattern: pi followed by number (e.g., π5 -> pi*5)
    exp = exp.replaceAllMapped(
        RegExp(r'(pi)(\d)'), (m) => '${m.group(1)}*${m.group(2)}');

    // Pattern: pi followed by pi (e.g., ππ -> pi*pi)
    exp = exp.replaceAllMapped(
        RegExp(r'(pi)(pi)'), (m) => '${m.group(1)}*${m.group(2)}');

    // Pattern: multiple consecutive pi symbols (e.g., πππ -> pi*pi*pi)
    exp = exp.replaceAllMapped(RegExp(r'(pi)+'), (match) {
      int count = 'pi'.allMatches(match.group(0)!).length;
      if (count > 1) {
        String result = 'pi';
        for (int i = 1; i < count; i++) {
          result += '*pi';
        }
        return result;
      }
      return match.group(0)!;
    });

    // Pattern: number followed by opening parenthesis (e.g., 2(3+4) -> 2*(3+4))
    exp = exp.replaceAllMapped(
        RegExp(r'(\d)(\()'), (m) => '${m.group(1)}*${m.group(2)}');

    // Pattern: closing parenthesis followed by number (e.g., (3+4)2 -> (3+4)*2)
    exp = exp.replaceAllMapped(
        RegExp(r'(\))(\d)'), (m) => '${m.group(1)}*${m.group(2)}');

    // Pattern: closing parenthesis followed by opening parenthesis (e.g., (2)(3) -> (2)*(3))
    exp = exp.replaceAllMapped(
        RegExp(r'(\))(\()'), (m) => '${m.group(1)}*${m.group(2)}');

    // Pattern: number followed by function (e.g., 2sin(30) -> 2*sin(30))
    exp = exp.replaceAllMapped(
        RegExp(r'(\d)(sin|cos|tan|asin|acos|atan|ln|sqrt)'),
        (m) => '${m.group(1)}*${m.group(2)}');

    // Pattern: closing parenthesis followed by function (e.g., (2)sin(30) -> (2)*sin(30))
    exp = exp.replaceAllMapped(
        RegExp(r'(\))(\s*)(sin|cos|tan|asin|acos|atan|ln|sqrt)'),
        (m) => '${m.group(1)}*${m.group(3)}');

    return exp;
  }

  static String _preprocess(String exp) {
    // Use the cleanExpression function for comprehensive symbol mapping
    exp = cleanExpression(exp);

    // Handle percentage
    exp = exp.replaceAllMapped(RegExp(r'(\d+(?:\.\d+)?)%'), (match) {
      final value = double.parse(match.group(1)!);
      return (value / 100).toString();
    });

    // Handle square root - convert √ to sqrt
    exp = exp.replaceAll('√(', 'sqrt(');
    // Handle standalone square root symbol followed by number or expression
    exp = exp.replaceAllMapped(RegExp(r'√(\d+(?:\.\d+)?)'), (match) {
      return 'sqrt(${match.group(1)})';
    });
    // Handle standalone square root with parentheses (make sure it's not already handled)
    exp = exp.replaceAllMapped(RegExp(r'√\(([^)]+)\)'), (match) {
      return 'sqrt(${match.group(1)})';
    });

    // Handle when numbers or expressions are followed by ² or ³
    exp = exp.replaceAllMapped(RegExp(r'(\d+)²'), (match) {
      return '(${match.group(1)})^2';
    });
    exp = exp.replaceAllMapped(RegExp(r'(\([^)]+\))²'), (match) {
      String content = match.group(1)!;
      return '($content)^2';
    });
    exp = exp.replaceAllMapped(RegExp(r'(\d+)³'), (match) {
      return '(${match.group(1)})^3';
    });
    exp = exp.replaceAllMapped(RegExp(r'(\([^)]+\))³'), (match) {
      String content = match.group(1)!;
      return '($content)^3';
    });

    // Handle absolute value - convert |number| to abs(number) format
    // This handles expressions like |−25| → abs(-25)
    exp = exp.replaceAllMapped(RegExp(r'\|([^|]+)\|'), (match) {
      String content = match.group(1)!;
      return 'abs($content)';
    });

    // Handle factorial by expanding it last (after other processing to avoid conflicts)
    // 1. Handle factorials of parenthesized expressions: (5+2)!
    exp = exp.replaceAllMapped(RegExp(r'(\([^)]+\))!'), (match) {
      String inside = match.group(1)!;
      // Evaluate what's inside the parentheses first
      try {
        double val = _evaluateParsedExpression(inside.substring(1, inside.length - 1));
        if (val < 0 || val != val.floor()) return "Error";
        int intVal = val.floor();
        if (intVal > 170) return "Infinity";
        return _formatForParser(_factorial(intVal));
      } catch (e) {
        return "Error";
      }
    });

    // 2. Handle standard factorials: 5!
    exp = exp.replaceAllMapped(RegExp(r'(\d+(?:\.\d+)?)!'), (match) {
      final value = double.tryParse(match.group(1)!);
      if (value != null &&
          value >= 0 &&
          value == value.floor()) {
        int intVal = value.floor();
        if (intVal > 170) return "Infinity";
        return _formatForParser(_factorial(intVal));
      }
      return "Error";
    });

    // Additional protection: check if expression ends with '!' and has only one character
    if (exp == '!') {
      throw Exception("Invalid expression");
    }

    return exp;
  }

  // Helper to format a number into something the math_expressions parser can handle
  // Specifically converts scientific notation "5e+10" to "(5 * 10^10)"
  static String _formatForParser(double value) {
    if (value.isInfinite) return "Infinity";
    if (value.isNaN) return "Error";

    String s = value.toString();
    if (s.contains('e') || s.contains('E')) {
      // Convert e notation to (mantissa * 10^exponent)
      s = s.toLowerCase();
      List<String> parts = s.split('e');
      return "(${parts[0]} * 10^(${parts[1]}))";
    }
    return s;
  }

  static String _convertTrigFunctionsToDegrees(String exp) {
    // Handle regular trigonometric functions - convert degrees to radians for math_expressions
    // Note: Inverse trig functions are handled separately and replaced with numerical values
    exp = exp.replaceAllMapped(RegExp(r'sin\(([^)]*)\)'), (match) {
      String arg = match.group(1)!;
      return 'sin(($arg) * pi / 180)';
    });
    exp = exp.replaceAllMapped(RegExp(r'cos\(([^)]*)\)'), (match) {
      String arg = match.group(1)!;
      return 'cos(($arg) * pi / 180)';
    });
    exp = exp.replaceAllMapped(RegExp(r'tan\(([^)]*)\)'), (match) {
      String arg = match.group(1)!;
      // Special handling for tan(90) and tan(270) - these are undefined
      if (arg.trim() == '90' || arg.trim() == '270') {
        throw Exception('Invalid input');
      }
      return 'tan(($arg) * pi / 180)';
    });

    return exp;
  }

  static double _factorial(int n) {
    if (n < 0) {
      throw Exception("Invalid factorial");
    }
    if (n == 0 || n == 1) return 1.0;
    double result = 1.0;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  static bool isExpressionComplete(String exp) {
    if (exp.isEmpty) return false;

    // Operator pe end nahi hona chahiye
    if (RegExp(r'[+\-×÷^.]$').hasMatch(exp)) return false;

    // Factorial alone should not be evaluated
    if (exp == '!') return false;

    // Factorial at the end without a number or bracket before it
    if (exp.endsWith('!') && !RegExp(r'(\d|\))!$').hasMatch(exp)) return false;

    // Open bracket zyada ho to
    if ('('.allMatches(exp).length != ')'.allMatches(exp).length) return false;

    // Check for incomplete absolute value (odd number of | symbols)
    int absCount = '|'.allMatches(exp).length;
    if (absCount % 2 != 0) return false;

    // Function incomplete
    if (RegExp(r'(sin|cos|tan|asin|acos|atan|log|ln|√|∛)\($').hasMatch(exp)) {
      return false;
    }

    // Check if expression ends with an absolute value opening bracket
    if (exp.endsWith('|') && !exp.endsWith('||')) {
      // Check if there's an opening absolute value bracket before the last one
      int lastAbsIndex = exp.lastIndexOf('|');
      if (lastAbsIndex > 0) {
        String beforeLastAbs = exp.substring(0, lastAbsIndex);
        int prevAbsCount = '|'.allMatches(beforeLastAbs).length;
        if (prevAbsCount % 2 == 0) {
          // If even number of previous absolute value brackets,
          // then the last | is an opening bracket without a closing one
          return false;
        }
      }
    }

    return true;
  }

  // Add the missing formatResult method
  static String formatResult(double result, {int maxDecimals = 9}) {
    if (result.isNaN) {
      return 'Error';
    }
    if (result.isInfinite) {
      return 'Infinity';
    }

    // Special handling for π - limit to maxDecimals places
    if ((result - pi).abs() < 1e-10) {
      return pi.toStringAsFixed(maxDecimals);
    }

    // Use scientific notation for very large or very small numbers
    double absVal = result.abs();
    if (absVal != 0 && (absVal >= 1e12 || absVal < 1e-4)) {
      // Clean up scientific notation (e.g., 7.257000e+306 -> 7.257e+306)
      String scientific = result.toStringAsExponential(maxDecimals);
      scientific = scientific.replaceFirst(RegExp(r'0+e'), 'e');
      scientific = scientific.replaceFirst(RegExp(r'\.e'), 'e');
      return scientific;
    }

    // Standard formatting
    String formatted = result.toString();
    if (formatted.contains('.')) {
      List<String> parts = formatted.split('.');
      if (parts[1].length > maxDecimals) {
        formatted = result.toStringAsFixed(maxDecimals);
      }
      // Remove trailing zeros
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }

    return formatted;
  }
}
