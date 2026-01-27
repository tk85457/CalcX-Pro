class Calculation {
  final String expression;
  final String result;
  final String type;

  Calculation({
    required this.expression,
    required this.result,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
      'result': result,
      'type': type,
    };
  }

  factory Calculation.fromJson(Map<String, dynamic> json) {
    return Calculation(
      expression: json['expression'],
      result: json['result'],
      type: json['type'],
    );
  }
}

class AdvancedCalculation {
  final String title;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> results;

  AdvancedCalculation({
    required this.title,
    required this.inputs,
    required this.results,
  });
}

class UnitConversion {
  final String fromUnit;
  final String toUnit;
  final double value;
  final double result;
  final String category;

  UnitConversion({
    required this.fromUnit,
    required this.toUnit,
    required this.value,
    required this.result,
    required this.category,
  });
}
