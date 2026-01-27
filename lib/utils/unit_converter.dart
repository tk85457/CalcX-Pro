class UnitConverter {
  // Length conversions (base unit: meters)
  static const Map<String, double> _lengthConversions = {
    'mm': 0.001,
    'cm': 0.01,
    'm': 1.0,
    'km': 1000.0,
    'in': 0.0254,
    'ft': 0.3048,
    'yd': 0.9144,
    'mi': 1609.344,
  };

  // Weight conversions (base unit: kilograms)
  static const Map<String, double> _weightConversions = {
    'mg': 0.000001,
    'g': 0.001,
    'kg': 1.0,
    't': 1000.0,
    'oz': 0.0283495,
    'lb': 0.453592,
    'st': 6.35029,
  };

  // Temperature conversions
  static double convertTemperature(double value, String from, String to) {
    // Convert to Celsius first
    double celsius;
    switch (from) {
      case 'C':
        celsius = value;
        break;
      case 'F':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'K':
        celsius = value - 273.15;
        break;
      default:
        throw Exception('Unsupported temperature unit');
    }

    // Convert from Celsius to target unit
    switch (to) {
      case 'C':
        return celsius;
      case 'F':
        return celsius * 9 / 5 + 32;
      case 'K':
        return celsius + 273.15;
      default:
        throw Exception('Unsupported temperature unit');
    }
  }

  // Area conversions (base unit: square meters)
  static const Map<String, double> _areaConversions = {
    'mm²': 0.000001,
    'cm²': 0.0001,
    'm²': 1.0,
    'km²': 1000000.0,
    'in²': 0.00064516,
    'ft²': 0.092903,
    'yd²': 0.836127,
    'ac': 4046.86,
    'ha': 10000.0,
  };

  static double convert(String category, double value, String from, String to) {
    switch (category.toLowerCase()) {
      case 'length':
        return _convertUnit(value, from, to, _lengthConversions);
      case 'weight':
        return _convertUnit(value, from, to, _weightConversions);
      case 'area':
        return _convertUnit(value, from, to, _areaConversions);
      case 'temperature':
        return convertTemperature(value, from, to);
      default:
        throw Exception('Unsupported conversion category');
    }
  }

  static double _convertUnit(
    double value,
    String from,
    String to,
    Map<String, double> conversions,
  ) {
    if (!conversions.containsKey(from) || !conversions.containsKey(to)) {
      throw Exception('Unsupported unit conversion');
    }

    // Convert to base unit first
    final baseValue = value * conversions[from]!;

    // Convert from base unit to target unit
    return baseValue / conversions[to]!;
  }

  static List<String> getUnits(String category) {
    switch (category.toLowerCase()) {
      case 'length':
        return _lengthConversions.keys.toList();
      case 'weight':
        return _weightConversions.keys.toList();
      case 'temperature':
        return ['C', 'F', 'K'];
      case 'area':
        return _areaConversions.keys.toList();
      default:
        return [];
    }
  }

  static List<String> getCategories() {
    return ['Length', 'Weight', 'Temperature', 'Area'];
  }
}
