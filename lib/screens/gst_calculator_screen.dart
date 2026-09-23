import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/history_provider.dart';

class GSTCalculatorScreen extends StatefulWidget {
  const GSTCalculatorScreen({super.key});

  @override
  State<GSTCalculatorScreen> createState() => _GSTCalculatorScreenState();
}

class _GSTCalculatorScreenState extends State<GSTCalculatorScreen> {
  final _amountController = TextEditingController();
  double _selectedRate = 18.0;
  bool _isAddGST = true; // true for Add GST, false for Remove GST
  Timer? _historyTimer;

  double _result = 0;

  void _calculateGST() {
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (amount > 0) {
      final gstAmount = amount * (_selectedRate / 100);

      if (_isAddGST) {
        // Add GST to amount
        _result = amount + gstAmount;
      } else {
        // Remove GST from amount (amount includes GST)
        _result = amount / (1 + _selectedRate / 100);
      }

      setState(() {});
      _debounceSaveToHistory();
    } else {
      if (_result != 0) {
        setState(() => _result = 0);
      }
    }
  }

  void _debounceSaveToHistory() {
    _historyTimer?.cancel();
    _historyTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted && _result > 0) {
        _saveToHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Calculator'),
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
                      TextField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText:
                              _isAddGST ? 'Amount (₹)' : 'Amount with GST (₹)',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateGST(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('GST Rate:'),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<double>(
                              initialValue: _selectedRate,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: AppConstants.gstRates.map((rate) {
                                return DropdownMenuItem(
                                  value: rate,
                                  child: Text('${rate.toStringAsFixed(0)}%'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedRate = value);
                                  _calculateGST();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Add GST')),
                          ButtonSegment(value: false, label: Text('Remove GST')),
                        ],
                        selected: {_isAddGST},
                        onSelectionChanged: (selected) {
                          setState(() => _isAddGST = selected.first);
                          _calculateGST();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_result > 0) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildResultRow(
                          _isAddGST ? 'Amount with GST' : 'Original Amount',
                          '₹${_result.toStringAsFixed(2)}',
                        ),
                        if (_isAddGST) ...[
                          const Divider(),
                          _buildResultRow(
                            'GST Amount',
                            '₹${((_result - (double.tryParse(_amountController.text) ?? 0))).toStringAsFixed(2)}',
                          ),
                        ] else ...[
                          const Divider(),
                          _buildResultRow(
                            'GST Amount',
                            '₹${((double.tryParse(_amountController.text) ?? 0) - _result).toStringAsFixed(2)}',
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
    final amount = double.tryParse(_amountController.text) ?? 0;
    final gstAmount = _isAddGST ? (_result - amount) : (amount - _result);
    final expression =
        '${_isAddGST ? "Add" : "Remove"} GST: ₹${amount.toStringAsFixed(2)} at ${_selectedRate.toStringAsFixed(0)}%';
    final result =
        '${_isAddGST ? "Amount with GST" : "Original Amount"}: ₹${_result.toStringAsFixed(2)}, GST: ₹${gstAmount.toStringAsFixed(2)}';
    historyProvider.addEntry(expression, result, 'gst');
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }
}
