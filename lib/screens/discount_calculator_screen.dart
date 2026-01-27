import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';

class DiscountCalculatorScreen extends StatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  State<DiscountCalculatorScreen> createState() =>
      _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen> {
  final _originalPriceController = TextEditingController();
  final _discountPercentController = TextEditingController();

  double _discountAmount = 0;
  double _finalPrice = 0;

  void _calculateDiscount() {
    final originalPrice = double.tryParse(_originalPriceController.text) ?? 0;
    final discountPercent =
        double.tryParse(_discountPercentController.text) ?? 0;

    if (originalPrice > 0 && discountPercent >= 0 && discountPercent <= 100) {
      final discountAmount = originalPrice * (discountPercent / 100);
      final finalPrice = originalPrice - discountAmount;

      setState(() {
        _discountAmount = discountAmount;
        _finalPrice = finalPrice;
        _saveToHistory();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Calculator'),
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
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Original Price (₹)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateDiscount(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _discountPercentController,
                      decoration: const InputDecoration(
                        labelText: 'Discount Percentage (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateDiscount(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_finalPrice > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildResultRow(
                        'Original Price',
                        '₹${(double.tryParse(_originalPriceController.text) ?? 0).toStringAsFixed(2)}',
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Discount Amount',
                        '₹${_discountAmount.toStringAsFixed(2)}',
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Final Price',
                        '₹${_finalPrice.toStringAsFixed(2)}',
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
        'Original Price: ₹${_originalPriceController.text}, Discount: ${_discountPercentController.text}%';
    final result =
        'Final Price: ₹${_finalPrice.toStringAsFixed(2)}, Saved: ₹${_discountAmount.toStringAsFixed(2)}';
    historyProvider.addEntry(expression, result, 'discount');
  }

  @override
  void dispose() {
    _originalPriceController.dispose();
    _discountPercentController.dispose();
    super.dispose();
  }
}
