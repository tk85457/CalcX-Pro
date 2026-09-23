import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaxCalculatorScreen extends StatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  State<TaxCalculatorScreen> createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends State<TaxCalculatorScreen> {
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _taxRateController = TextEditingController();
  String _result = '';
  String _taxAmount = '';
  String _netIncome = '';

  @override
  void dispose() {
    _incomeController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  void _calculateTax() {
    if (_incomeController.text.isNotEmpty &&
        _taxRateController.text.isNotEmpty) {
      try {
        final income = double.tryParse(_incomeController.text) ?? 0;
        final taxRate = double.tryParse(_taxRateController.text) ?? 0;

        if (taxRate < 0 || taxRate > 100) {
          _showErrorDialog('Tax rate must be between 0 and 100');
          return;
        }

        if (income <= 0) {
          _showErrorDialog('Income must be greater than 0');
          return;
        }

        if (income.isInfinite || income.isNaN) {
          _showErrorDialog('Income value is invalid');
          return;
        }

        final taxAmount = income * (taxRate / 100);
        final netIncome = income - taxAmount;

        // Format numbers to prevent overflow display issues
        setState(() {
          _taxAmount = _formatNumber(taxAmount);
          _netIncome = _formatNumber(netIncome);
          _result = _formatPercentage((netIncome / income) * 100);
        });
      } catch (e) {
        _showErrorDialog('Please enter valid numbers');
      }
    }
  }

  String _formatNumber(double value) {
    if (value.isInfinite || value.isNaN) {
      return '0.00';
    }

    // Handle very large numbers by using scientific notation or limiting decimal places
    if (value.abs() > 1e15) {
      return value.toStringAsExponential(2);
    } else if (value.abs() > 1e9) {
      return value.toStringAsFixed(2);
    } else {
      return value.toStringAsFixed(2);
    }
  }

  String _formatPercentage(double value) {
    if (value.isInfinite || value.isNaN) {
      return '0.00';
    }

    return value.toStringAsFixed(2);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Tax Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _incomeController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'))
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Gross Income',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _taxRateController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'))
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Tax Rate (%)',
                          suffixText: '%',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _calculateTax,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Calculate Tax',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_result.isNotEmpty)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildResultCard(
                            'Tax Amount', '₹ $_taxAmount', Colors.red.shade100),
                        const SizedBox(height: 12),
                        _buildResultCard('Net Income', '₹ $_netIncome',
                            Colors.green.shade100),
                        const SizedBox(height: 12),
                        _buildResultCard(
                            'Net Income %', '$_result%', Colors.blue.shade100),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
