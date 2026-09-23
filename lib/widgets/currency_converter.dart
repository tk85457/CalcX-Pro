import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/currency_service.dart';
import '../providers/settings_provider.dart';

class CurrencyConverterWidget extends StatefulWidget {
  const CurrencyConverterWidget({super.key});

  @override
  State<CurrencyConverterWidget> createState() =>
      _CurrencyConverterWidgetState();
}

class _CurrencyConverterWidgetState extends State<CurrencyConverterWidget> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  final TextEditingController _inputController = TextEditingController();
  String _result = '0.00';
  Map<String, double> _exchangeRates = {};
  bool _isLoading = true;
  String _lastUpdated = '';
  String? _errorMessage;

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
    'SEK',
    'NZD',
    'KRW',
    'SGD',
    'NOK',
    'MXN',
    'INR',
    'RUB',
    'BRL',
    'ZAR',
    'TRY',
    'AED',
    'SAR',
    'HKD',
    'THB',
    'PLN',
    'CZK',
    'DKK',
    'HUF',
    'ILS',
    'CLP',
    'PHP',
  ];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only initialize once when dependencies are ready
    if (!_hasInitialized) {
      _hasInitialized = true;
      // Check immediately - no delay needed
      _checkApiKeyAndLoadRates();
    }
  }

  Future<void> _checkApiKeyAndLoadRates() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    // First check if API key is configured
    if (settingsProvider.currencyApiKey.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please configure your Currency API key in Settings to use this feature.';
      });
      return;
    }

    // API key is present, proceed to load rates automatically
    await _loadExchangeRates();
  }

  Future<void> _loadExchangeRates() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    // Check API key again before loading
    if (settingsProvider.currencyApiKey.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please configure your Currency API key in Settings to use this feature.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await CurrencyService.getExchangeRates(
          settingsProvider.currencyApiKey);
      if (mounted) {
        setState(() {
          _exchangeRates = result.rates;
          _lastUpdated = result.lastUpdated;
          _isLoading = false;
          _performConversion();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load rates. Please check your API key and try again.';
        });
      }
    }
  }

  void _onInputChanged() {
    // Trigger rebuild for dynamic font size
    setState(() {});
    _performConversion();
  }

  void _performConversion() {
    final inputText = _inputController.text.trim();

    if (inputText.isEmpty || _exchangeRates.isEmpty) {
      setState(() => _result = '0.00');
      return;
    }

    try {
      final value = double.parse(inputText);

      if (value < 0) {
        setState(() => _result = 'Invalid amount');
        return;
      }

      final fromRate = _exchangeRates[_fromCurrency] ?? 1.0;
      final toRate = _exchangeRates[_toCurrency] ?? 1.0;

      if (fromRate <= 0) {
        setState(() => _result = 'Invalid rate');
        return;
      }

      // Convert: (value / fromRate) * toRate
      // Since rates are relative to USD, we first convert to USD then to target
      final result = (value / fromRate) * toRate;

      setState(() {
        _result = _formatResult(result);
      });
    } catch (e) {
      setState(() => _result = 'Invalid input');
    }
  }

  double _getDynamicFontSize(String text) {
    final length = text.length;
    if (length <= 5) {
      return 24.0;
    } else if (length <= 10) {
      return 20.0;
    } else if (length <= 15) {
      return 16.0;
    } else {
      return 14.0;
    }
  }

  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }

    // Format based on magnitude
    if (value >= 1000000) {
      return value.toStringAsFixed(2);
    } else if (value >= 100) {
      return value.toStringAsFixed(2);
    } else if (value >= 1) {
      return value.toStringAsFixed(4);
    } else {
      return value.toStringAsFixed(6);
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _performConversion();
    });
  }

  double _getExchangeRate() {
    if (_exchangeRates.isEmpty) return 0.0;
    final fromRate = _exchangeRates[_fromCurrency] ?? 1.0;
    final toRate = _exchangeRates[_toCurrency] ?? 1.0;
    return toRate / fromRate;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with refresh button
              _buildHeader(),
              const SizedBox(height: 16),

              // Error message
              if (_errorMessage != null) _buildErrorBanner(),

              // Main conversion card
              _buildConversionCard(),
              const SizedBox(height: 16),

              // Exchange rate info
              if (!_isLoading && _exchangeRates.isNotEmpty)
                _buildExchangeRateInfo(),
              const SizedBox(height: 16),

              // Popular pairs
              if (!_isLoading && _exchangeRates.isNotEmpty)
                _buildPopularPairs(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _lastUpdated.isNotEmpty ? 'Updated: $_lastUpdated' : 'Loading...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _isLoading ? null : _loadExchangeRates,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh, size: 18),
          label: const Text('Refresh'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Input amount field
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: TextStyle(
                fontSize: _getDynamicFontSize(_inputController.text),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Currency selectors with swap button
            Row(
              children: [
                Expanded(
                  child: _buildCurrencyDropdown(
                    label: 'From',
                    value: _fromCurrency,
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value!;
                        _performConversion();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Swap currencies',
                  iconSize: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCurrencyDropdown(
                    label: 'To',
                    value: _toCurrency,
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value!;
                        _performConversion();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Result display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Converted Amount',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          '$_result $_toCurrency',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: _currencies.map((currency) {
        return DropdownMenuItem(
          value: currency,
          child: Text(
            currency,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  Widget _buildExchangeRateInfo() {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 20,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '1 $_fromCurrency = ${_getExchangeRate().toStringAsFixed(4)} $_toCurrency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularPairs() {
    final pairs = [
      ['USD', 'EUR'],
      ['USD', 'GBP'],
      ['USD', 'JPY'],
      ['EUR', 'GBP'],
      ['GBP', 'INR'],
      ['USD', 'INR'],
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Convert',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pairs
                  .map((pair) => _buildQuickPairButton(pair[0], pair[1]))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPairButton(String from, String to) {
    final fromRate = _exchangeRates[from] ?? 1.0;
    final toRate = _exchangeRates[to] ?? 1.0;
    final rate = (toRate / fromRate).toStringAsFixed(3);

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _fromCurrency = from;
          _toCurrency = to;
          _performConversion();
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$from → $to',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            rate,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
