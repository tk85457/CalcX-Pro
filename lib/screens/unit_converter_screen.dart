import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  String _selectedCategory = 'Length';
  String _fromUnit = 'Meter';
  String _toUnit = 'Kilometer';
  final _inputController = TextEditingController();
  double _result = 0;
  Timer? _historyTimer;

  final Map<String, Map<String, double>> _conversionFactors = {
    'Length': {
      'Nanometer': 0.000000001,
      'Micrometer': 0.000001,
      'Millimeter': 0.001,
      'Centimeter': 0.01,
      'Decimeter': 0.1,
      'Meter': 1.0,
      'Decameter': 10.0,
      'Hectometer': 100.0,
      'Kilometer': 1000.0,
      'Megameter': 1000000.0,
      'Inch': 0.0254,
      'Foot': 0.3048,
      'Yard': 0.9144,
      'Mile': 1609.344,
      'Nautical Mile': 1852.0,
      'Light Year': 9460730472580800.0,
      'Parsec': 30856775814913673.0,
    },
    'Weight': {
      'Microgram': 0.000001,
      'Milligram': 0.001,
      'Gram': 1.0,
      'Kilogram': 1000.0,
      'Metric Ton': 1000000.0,
      'Pound': 453.592,
      'Ounce': 28.3495,
      'Stone': 6350.293,
      'Short Ton (US)': 907184.74,
      'Long Ton (UK)': 1016046.9088,
      'Carat': 0.2,
      'Grain': 0.06479891,
    },
    'Temperature': {'Celsius': 1.0, 'Fahrenheit': 1.0, 'Kelvin': 1.0},
    'Area': {
      'Square Millimeter': 0.000001,
      'Square Centimeter': 0.0001,
      'Square Meter': 1.0,
      'Square Kilometer': 1000000.0,
      'Square Inch': 0.00064516,
      'Square Foot': 0.092903,
      'Square Yard': 0.836127,
      'Acre': 4046.856,
      'Hectare': 10000.0,
      'Square Mile': 2589988.11,
    },
    'Volume': {
      'Cubic Millimeter': 0.000000001,
      'Cubic Centimeter': 0.000001,
      'Milliliter': 0.000001,
      'Liter': 0.001,
      'Cubic Meter': 1.0,
      'Cubic Inch': 0.000016387,
      'Cubic Foot': 0.0283168,
      'Fluid Ounce (US)': 0.0000295735,
      'Cup (US)': 0.000236588,
      'Pint (US)': 0.000473176,
      'Quart (US)': 0.000946353,
      'Gallon (US)': 0.00378541,
      'Gallon (UK)': 0.00454609,
      'Barrel (Oil)': 0.158987,
    },
    'Time': {
      'Nanosecond': 0.000000001,
      'Microsecond': 0.000001,
      'Millisecond': 0.001,
      'Second': 1.0,
      'Minute': 60.0,
      'Hour': 3600.0,
      'Day': 86400.0,
      'Week': 604800.0,
      'Month (30 days)': 2592000.0,
      'Year': 31536000.0,
      'Decade': 315360000.0,
      'Century': 3153600000.0,
    },
    'Speed': {
      'Millimeter per Second': 0.001,
      'Meter per Second': 1.0,
      'Kilometer per Hour': 0.277778,
      'Mile per Hour': 0.44704,
      'Foot per Second': 0.3048,
      'Knot': 0.514444,
      'Mach': 343.0,
      'Speed of Light': 299792458.0,
    },
    'Digital Storage': {
      'Bit': 0.125,
      'Byte': 1.0,
      'Kilobyte': 1024.0,
      'Megabyte': 1048576.0,
      'Gigabyte': 1073741824.0,
      'Terabyte': 1099511627776.0,
      'Petabyte': 1125899906842624.0,
      'Kilobit': 128.0,
      'Megabit': 131072.0,
      'Gigabit': 134217728.0,
      'Terabit': 137438953472.0,
    },
    'Energy': {
      'Joule': 1.0,
      'Kilojoule': 1000.0,
      'Calorie': 4.184,
      'Kilocalorie': 4184.0,
      'Watt Hour': 3600.0,
      'Kilowatt Hour': 3600000.0,
      'Electron Volt': 1.602176634e-19,
      'Foot Pound': 1.35582,
      'BTU': 1055.06,
    },
    'Pressure': {
      'Pascal': 1.0,
      'Kilopascal': 1000.0,
      'Bar': 100000.0,
      'Atmosphere': 101325.0,
      'Torr': 133.322,
      'PSI': 6894.76,
      'mmHg': 133.322,
    },
    'Frequency': {
      'Hertz': 1.0,
      'Kilohertz': 1000.0,
      'Megahertz': 1000000.0,
      'Gigahertz': 1000000000.0,
      'Terahertz': 1000000000000.0,
      'RPM': 0.0166667,
    },
  };

  void _convert() {
    if (_inputController.text.isEmpty) {
      _historyTimer?.cancel();
      setState(() => _result = 0);
      return;
    }
    final input = double.tryParse(_inputController.text) ?? 0;
    final category = _conversionFactors[_selectedCategory]!;

    if (_selectedCategory == 'Temperature') {
      _result = _convertTemperature(input, _fromUnit, _toUnit);
    } else {
      final fromFactor = category[_fromUnit]!;
      final toFactor = category[_toUnit]!;
      _result = input * fromFactor / toFactor;
    }

    if (_inputController.text.isNotEmpty) {
      _debounceSaveToHistory();
    }
    setState(() {});
  }

  void _debounceSaveToHistory() {
    _historyTimer?.cancel();
    _historyTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted && _inputController.text.isNotEmpty) {
        _saveToHistory();
      }
    });
  }

  double _convertTemperature(double value, String from, String to) {
    double celsius;
    // Convert to Celsius first
    switch (from) {
      case 'Celsius':
        celsius = value;
        break;
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      default:
        celsius = value;
    }

    // Convert from Celsius to target unit
    switch (to) {
      case 'Celsius':
        return celsius;
      case 'Fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'Kelvin':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = _conversionFactors[_selectedCategory]!.keys.toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Unit Converter')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            top: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _conversionFactors.keys.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _fromUnit = _conversionFactors[_selectedCategory]!
                                .keys
                                .first;
                            _toUnit = _conversionFactors[_selectedCategory]!
                                .keys
                                .elementAt(1);
                          });
                          _convert();
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              decoration: const InputDecoration(
                                labelText: 'Value',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _convert(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _fromUnit,
                              decoration: const InputDecoration(
                                labelText: 'From',
                                border: OutlineInputBorder(),
                              ),
                              items: units.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(
                                    unit,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _fromUnit = value!;
                                });
                                _convert();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _result.toStringAsFixed(9),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _toUnit,
                              decoration: const InputDecoration(
                                labelText: 'To',
                                border: OutlineInputBorder(),
                              ),
                              items: units.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(
                                    unit,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _toUnit = value!;
                                });
                                _convert();
                              },
                            ),
                          ),
                        ],
                      ),
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

  void _saveToHistory() {
    if (!mounted || _inputController.text.isEmpty || _result == 0) return;
    final historyProvider = context.read<HistoryProvider>();
    final expression = '${_inputController.text} $_fromUnit';
    final result = '${_result.toStringAsFixed(4)} $_toUnit';
    historyProvider.addEntry(expression, result, 'unit');
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    _inputController.dispose();
    super.dispose();
  }
}
