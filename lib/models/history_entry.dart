import 'package:hive/hive.dart';

part 'history_entry.g.dart';

@HiveType(typeId: 0)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final String expression;

  @HiveField(1)
  final String result;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String calculatorType;

  HistoryEntry({
    required this.expression,
    required this.result,
    required this.timestamp,
    required this.calculatorType,
  });

  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
      'calculatorType': calculatorType,
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      expression: json['expression'],
      result: json['result'],
      timestamp: DateTime.parse(json['timestamp']),
      calculatorType: json['calculatorType'],
    );
  }
}
