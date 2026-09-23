import 'package:flutter/material.dart';
import '../widgets/currency_converter.dart';

class CurrencyConverterScreen extends StatelessWidget {
  const CurrencyConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SafeArea(
        top: false,
        child: SingleChildScrollView(child: CurrencyConverterWidget()),
      ),
    );
  }
}
