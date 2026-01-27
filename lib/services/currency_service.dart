import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ExchangeRateResult {
  final Map<String, double> rates;
  final String lastUpdated;
  final String? errorMessage;

  ExchangeRateResult({
    required this.rates,
    required this.lastUpdated,
    this.errorMessage,
  });
}

class CurrencyService {
  static Future<ExchangeRateResult> getExchangeRates([String? apiKey]) async {
    // If no API key provided, return default rates
    if (apiKey == null || apiKey.isEmpty) {
      return _getDefaultRatesWithError(
          'No API key provided. Please enter your exchangerate-api.com API key in Settings.');
    }

    try {
      // Using exchangerate-api.com with API key
      final url = 'https://v6.exchangerate-api.com/v6/$apiKey/latest/USD';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the response indicates error
        if (data['result'] != 'success') {
          final errorMessage = data['error-type'] ?? 'Unknown API error';
          return _getDefaultRatesWithError(
              'API Error: $errorMessage. Please check your API key.');
        }

        final Map<String, double> rates = {};

        // Convert the rates from the API response (exchangerate-api.com format)
        final apiRates = data['conversion_rates'] as Map<String, dynamic>;
        apiRates.forEach((key, value) {
          rates[key] = value.toDouble();
        });

        // Format the last updated date
        final now = DateTime.now();
        final formatter = DateFormat('yyyy-MM-dd HH:mm');
        final lastUpdated = formatter.format(now);

        return ExchangeRateResult(rates: rates, lastUpdated: lastUpdated);
      } else if (response.statusCode == 401) {
        return _getDefaultRatesWithError(
            'Invalid API key. Please check your exchangerate-api.com API key in Settings.');
      } else if (response.statusCode == 429) {
        return _getDefaultRatesWithError(
            'API rate limit exceeded. Please try again later.');
      } else {
        return _getDefaultRatesWithError(
            'API request failed (HTTP ${response.statusCode}). Using cached rates.');
      }
    } catch (e) {
      // Network error or other exception
      return _getDefaultRatesWithError(
          'Network error: ${e.toString()}. Please check your internet connection.');
    }
  }

  static ExchangeRateResult _getDefaultRates() {
    // Updated rates based on current approximate values
    final defaultRates = {
      'USD': 1.0,
      'EUR': 0.92, // Euro
      'GBP': 0.79, // British Pound
      'JPY': 154.0, // Japanese Yen
      'CAD': 1.37, // Canadian Dollar
      'AUD': 1.55, // Australian Dollar
      'CHF': 0.91, // Swiss Franc
      'CNY': 7.24, // Chinese Yuan
      'INR': 89.0, // Indian Rupee
      'RUB': 92.5, // Russian Ruble
      'BRL': 4.95, // Brazilian Real
      'ZAR': 18.6, // South African Rand
      'KRW': 1340.0, // South Korean Won
      'SGD': 1.35, // Singapore Dollar
      'HKD': 7.83, // Hong Kong Dollar
      'NZD': 1.68, // New Zealand Dollar
      'TRY': 32.5, // Turkish Lira
      'SEK': 11.0, // Swedish Krona
      'NOK': 11.0, // Norwegian Krone
      'MXN': 17.0, // Mexican Peso
      'AED': 3.67, // UAE Dirham
      'SAR': 3.75, // Saudi Riyal
      'THB': 36.8, // Thai Baht
      'PLN': 3.9, // Polish Zloty
      'CZK': 23.5, // Czech Koruna
      'DKK': 6.9, // Danish Krone
      'HUF': 380.0, // Hungarian Forint
      'ILS': 3.85, // Israeli Shekel
      'CLP': 910.0, // Chilean Peso
      'PHP': 57.5, // Philippine Peso
    };

    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    final lastUpdated = formatter.format(now);

    return ExchangeRateResult(rates: defaultRates, lastUpdated: lastUpdated);
  }

  static ExchangeRateResult _getDefaultRatesWithError(String errorMessage) {
    final defaultResult = _getDefaultRates();
    return ExchangeRateResult(
      rates: defaultResult.rates,
      lastUpdated: defaultResult.lastUpdated,
      errorMessage: errorMessage,
    );
  }
}
