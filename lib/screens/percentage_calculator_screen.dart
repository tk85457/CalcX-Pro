import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';

class PercentageCalculatorScreen extends StatefulWidget {
  const PercentageCalculatorScreen({super.key});

  @override
  State<PercentageCalculatorScreen> createState() =>
      _PercentageCalculatorScreenState();
}

class _PercentageCalculatorScreenState
    extends State<PercentageCalculatorScreen> {
  final _value1Controller = TextEditingController();
  final _value2Controller = TextEditingController();
  Timer? _historyTimer;

  String _selectedCalculation = 'percentage_of';
  double _result = 0;
  String _resultText = '';

  void _calculate() {
    final value1 = double.tryParse(_value1Controller.text) ?? 0;
    final value2 = double.tryParse(_value2Controller.text) ?? 0;

    if (value1 == 0 && value2 == 0) {
      _historyTimer?.cancel();
      setState(() {
        _result = 0;
        _resultText = '';
      });
      return;
    }

    double result;
    String resultText;

    switch (_selectedCalculation) {
      case 'percentage_of':
        // What is X% of Y?
        result = (value1 / 100) * value2;
        resultText =
            '${value1.toStringAsFixed(2)}% of ${value2.toStringAsFixed(2)} = ${result.toStringAsFixed(2)}';
        break;
      case 'what_percentage':
        // X is what percentage of Y?
        if (value2 != 0) {
          result = (value1 / value2) * 100;
          resultText =
              '${value1.toStringAsFixed(2)} is ${result.toStringAsFixed(2)}% of ${value2.toStringAsFixed(2)}';
        } else {
          result = 0;
          resultText = 'Cannot divide by zero';
        }
        break;
      case 'percentage_change':
        // Percentage change from X to Y
        if (value1 != 0) {
          result = ((value2 - value1) / value1) * 100;
          final changeType = result >= 0 ? 'increase' : 'decrease';
          resultText =
              'Change from ${value1.toStringAsFixed(2)} to ${value2.toStringAsFixed(2)} is ${result.abs().toStringAsFixed(2)}% $changeType';
        } else {
          result = 0;
          resultText = 'Cannot calculate change from zero';
        }
        break;
      default:
        result = 0;
        resultText = '';
    }

    setState(() {
      _result = result;
      _resultText = resultText;
    });
    _debounceSaveToHistory(resultText);
  }

  void _debounceSaveToHistory(String result) {
    _historyTimer?.cancel();
    _historyTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted &&
          _resultText == result &&
          result.isNotEmpty &&
          !result.startsWith('Cannot')) {
        _saveToHistory(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Percentage Calculator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Select Calculation Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCalculation,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'percentage_of',
                          child: Text('What is X% of Y?'),
                        ),
                        DropdownMenuItem(
                          value: 'what_percentage',
                          child: Text('X is what % of Y?'),
                        ),
                        DropdownMenuItem(
                          value: 'percentage_change',
                          child: Text('Percentage change from X to Y'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCalculation = value!;
                          _calculate();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _value1Controller,
                      decoration: InputDecoration(
                        labelText: _getLabel1(),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _value2Controller,
                      decoration: InputDecoration(
                        labelText: _getLabel2(),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculate(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_resultText.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Result',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _resultText,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_result != 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Value: ${_result.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  String _getLabel1() {
    switch (_selectedCalculation) {
      case 'percentage_of':
        return 'Percentage (%)';
      case 'what_percentage':
        return 'Value (X)';
      case 'percentage_change':
        return 'Original Value (X)';
      default:
        return 'Value 1';
    }
  }

  String _getLabel2() {
    switch (_selectedCalculation) {
      case 'percentage_of':
        return 'Total Value (Y)';
      case 'what_percentage':
        return 'Total Value (Y)';
      case 'percentage_change':
        return 'New Value (Y)';
      default:
        return 'Value 2';
    }
  }

  void _saveToHistory(String result) {
    if (result.isEmpty) return;
    final historyProvider = context.read<HistoryProvider>();
    final expression =
        '${_getLabel1()}: ${_value1Controller.text}, ${_getLabel2()}: ${_value2Controller.text}';
    historyProvider.addEntry(expression, result, 'percentage');
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    _value1Controller.dispose();
    _value2Controller.dispose();
    super.dispose();
  }
}
