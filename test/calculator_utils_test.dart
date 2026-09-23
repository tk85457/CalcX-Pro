import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:calcxpro/utils/calculator_utils.dart';

void main() {
  group('CalculatorUtils Standard Scientific Evaluation', () {
    test('Degree Mode Trigonometry', () {
      expect(CalculatorUtils.evaluate('sin(30)', isRadian: false), '0.5');
      expect(CalculatorUtils.evaluate('cos(60)', isRadian: false), '0.5');
      expect(CalculatorUtils.evaluate('tan(45)', isRadian: false), '1');
      expect(CalculatorUtils.evaluate('cos(90)', isRadian: false), '0');
      expect(CalculatorUtils.evaluate('sin(90)', isRadian: false), '1');
      expect(CalculatorUtils.evaluate('tan(90)', isRadian: false), 'Math Error');
    });

    test('Radian Mode Trigonometry', () {
      expect(CalculatorUtils.evaluate('sin(π/2)', isRadian: true), '1');
      expect(CalculatorUtils.evaluate('cos(π)', isRadian: true), '-1');
    });

    test('Implicit Multiplication', () {
      // 5sin(30) => 2.5
      expect(CalculatorUtils.evaluate('5sin(30)', isRadian: false), '2.5');
      // 2(3) => 6
      expect(CalculatorUtils.evaluate('2(3)'), '6');
      // (2)(3) => 6
      expect(CalculatorUtils.evaluate('(2)(3)'), '6');
      // 2π
      final piVal = CalculatorUtils.evaluateExpression('2π');
      expect((piVal - 2 * pi).abs() < 1e-6, isTrue);
      // 2√9 => 6
      expect(CalculatorUtils.evaluate('2√9'), '6');
      // 2√(9) => 6
      expect(CalculatorUtils.evaluate('2√(9)'), '6');
    });

    test('Percentage Operations', () {
      // 100 + 10% = 110
      expect(CalculatorUtils.evaluate('100 + 10%'), '110');
      // 100 - 20% = 80
      expect(CalculatorUtils.evaluate('100 - 20%'), '80');
      // 50% = 0.5
      expect(CalculatorUtils.evaluate('50%'), '0.5');
      // 50% * 200 = 100
      expect(CalculatorUtils.evaluate('50% * 200'), '100');
    });

    test('Roots and Powers', () {
      expect(CalculatorUtils.evaluate('√(16)'), '4');
      expect(CalculatorUtils.evaluate('√16'), '4');
      expect(CalculatorUtils.evaluate('∛(27)'), '3');
      expect(CalculatorUtils.evaluate('∛27'), '3');
      expect(CalculatorUtils.evaluate('2^3'), '8');
      expect(CalculatorUtils.evaluate('5²'), '25');
      expect(CalculatorUtils.evaluate('110²'), '12100');
      expect(CalculatorUtils.evaluate('210^3'), '9261000');
      expect(CalculatorUtils.evaluate('2³'), '8');
    });

    test('Special Functions: log, ln, fact, abs', () {
      expect(CalculatorUtils.evaluate('log(100)'), '2');
      expect(CalculatorUtils.evaluate('5!'), '120');
      expect(CalculatorUtils.evaluate('fact(5)'), '120');
      expect(CalculatorUtils.evaluate('|-5|'), '5');
      expect(CalculatorUtils.evaluate('10ˣ(3)'), '1000');
      expect(CalculatorUtils.evaluate('5(10ˣ(2))'), '500');
      final e1 = CalculatorUtils.evaluateExpression('eˣ(1)');
      expect((e1 - e).abs() < 1e-6, isTrue);
      final e2 = CalculatorUtils.evaluateExpression('2eˣ(1)');
      expect((e2 - 2 * e).abs() < 1e-6, isTrue);
    });

    test('Auto-Close Brackets & Preview', () {
      expect(CalculatorUtils.autoCloseBrackets('sin(30'), 'sin(30)');
      expect(CalculatorUtils.autoCloseBrackets('5*(2+(3*4'), '5*(2+(3*4))');
      expect(CalculatorUtils.autoCloseBrackets('|-5'), '|-5|');

      expect(CalculatorUtils.getAutoCalculationPreview('5sin(30', isRadian: false), '2.5');
      expect(CalculatorUtils.getAutoCalculationPreview('100 + 10%'), '110');
      expect(CalculatorUtils.getAutoCalculationPreview('5 + '), isNull);
    });

    test('Scientific notation in nested function evaluation', () {
      expect(CalculatorUtils.evaluate('log(10ˣ(5))'), '5');
      final val =
          CalculatorUtils.evaluateExpression('sin(asin(0.00001))', isRadian: true);
      expect((val - 0.00001).abs() < 1e-9, isTrue);
    });

    test('Chained percentage expressions and formatResult tests', () {
      expect(CalculatorUtils.evaluate('100 + 10% + 5%'), '115.5');
      expect(CalculatorUtils.evaluate('200 - 10% - 5%'), '171');
      expect(CalculatorUtils.evaluate('50%'), '0.5');
      expect(CalculatorUtils.evaluate('100 * 20%'), '20');
      expect(CalculatorUtils.evaluate('(100 + 20)%'), '1.2');

      // Scientific notation marker 'E' emitted by formatResult
      final sciVal = CalculatorUtils.evaluateExpression('1E-7 * 10');
      expect((sciVal - 1e-6).abs() < 1e-12, isTrue);

      // Raw user-input e expressions like 2e3 continue to use the e constant
      final eVal = CalculatorUtils.evaluateExpression('2e3');
      expect((eVal - (2 * e * 3)).abs() < 1e-9, isTrue);

      // formatResult preserves integer digits when maxDecimals is 0
      expect(CalculatorUtils.formatResult(100.0, maxDecimals: 0), '100');
      expect(CalculatorUtils.formatResult(250.0, maxDecimals: 0), '250');
    });
  });
}
