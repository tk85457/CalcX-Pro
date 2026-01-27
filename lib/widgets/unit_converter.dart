import 'package:flutter/material.dart';
import '../utils/unit_converter.dart';

class UnitConverterWidget extends StatefulWidget {
  const UnitConverterWidget({super.key});

  @override
  State<UnitConverterWidget> createState() => _UnitConverterWidgetState();
}

class _UnitConverterWidgetState extends State<UnitConverterWidget> {
  String _selectedCategory = 'Length';
  String _fromUnit = 'm';
  String _toUnit = 'km';
  String _inputValue = '';
  String _result = '0';

  @override
  Widget build(BuildContext context) {
    final categories = UnitConverter.getCategories();
    final fromUnits = UnitConverter.getUnits(_selectedCategory.toLowerCase());
    final toUnits = UnitConverter.getUnits(_selectedCategory.toLowerCase());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Category selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                          _fromUnit = UnitConverter.getUnits(
                            newValue.toLowerCase(),
                          ).first;
                          _toUnit = UnitConverter.getUnits(
                            newValue.toLowerCase(),
                          )[1];
                          _result = '0';
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Conversion inputs
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Input field
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter value',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _inputValue = value;
                        _performConversion();
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Unit selection row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _fromUnit,
                          decoration: const InputDecoration(
                            labelText: 'From',
                            border: OutlineInputBorder(),
                          ),
                          items: fromUnits.map((String unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _fromUnit = newValue;
                                _performConversion();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.swap_horiz),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _toUnit,
                          decoration: const InputDecoration(
                            labelText: 'To',
                            border: OutlineInputBorder(),
                          ),
                          items: toUnits.map((String unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _toUnit = newValue;
                                _performConversion();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Result display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Result',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          _result,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Convert button
          ElevatedButton.icon(
            onPressed: _performConversion,
            icon: const Icon(Icons.calculate),
            label: const Text('Convert'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performConversion() {
    if (_inputValue.isEmpty) {
      setState(() {
        _result = '0';
      });
      return;
    }

    try {
      final value = double.parse(_inputValue);
      final result = UnitConverter.convert(
        _selectedCategory.toLowerCase(),
        value,
        _fromUnit,
        _toUnit,
      );
      setState(() {
        _result = _formatResult(result);
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }

    // Format the result to avoid very long decimal numbers
    String formatted = value.toString();
    if (formatted.contains('.')) {
      // Limit to 6 decimal places max
      final parts = formatted.split('.');
      if (parts[1].length > 6) {
        formatted = value.toStringAsFixed(6);
      }
      // Remove trailing zeros
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }

    return formatted;
  }
}
