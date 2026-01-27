import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';

class EMICalculatorScreen extends StatefulWidget {
  const EMICalculatorScreen({super.key});

  @override
  State<EMICalculatorScreen> createState() => _EMICalculatorScreenState();
}

class _EMICalculatorScreenState extends State<EMICalculatorScreen> {
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();

  double _emi = 0;
  double _totalAmount = 0;
  double _totalInterest = 0;

  void _calculateEMI() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final tenure = int.tryParse(_tenureController.text) ?? 0;

    if (principal > 0 && rate > 0 && tenure > 0) {
      // Monthly interest rate
      final monthlyRate = rate / 12 / 100;

      // EMI formula: [P × R × (1+R)^N] / [(1+R)^N − 1]
      final emi =
          (principal * monthlyRate * pow(1 + monthlyRate, tenure)) /
          (pow(1 + monthlyRate, tenure) - 1);

      final totalAmount = emi * tenure;
      final totalInterest = totalAmount - principal;

      setState(() {
        _emi = emi;
        _totalAmount = totalAmount;
        _totalInterest = totalInterest;
        _saveToHistory();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI Calculator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _principalController,
                      decoration: const InputDecoration(
                        labelText: 'Principal Amount (₹)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateEMI(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _rateController,
                      decoration: const InputDecoration(
                        labelText: 'Annual Interest Rate (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateEMI(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tenureController,
                      decoration: const InputDecoration(
                        labelText: 'Tenure (Months)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateEMI(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_emi > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildResultRow(
                        'Monthly EMI',
                        '₹${_emi.toStringAsFixed(2)}',
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Total Amount',
                        '₹${_totalAmount.toStringAsFixed(2)}',
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Total Interest',
                        '₹${_totalInterest.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  void _saveToHistory() {
    final historyProvider = context.read<HistoryProvider>();
    final expression =
        'Principal: ₹${_principalController.text}, Rate: ${_rateController.text}%, Tenure: ${_tenureController.text} months';
    final result =
        'EMI: ₹${_emi.toStringAsFixed(2)}, Total: ₹${_totalAmount.toStringAsFixed(2)}';
    historyProvider.addEntry(expression, result, 'emi');
  }

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }
}
