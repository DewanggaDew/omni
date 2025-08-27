/// Simple currency exchange rate service
/// For production, this would connect to a real exchange rate API
class CurrencyExchangeService {
  // Mock exchange rates (1 unit of currency to IDR)
  // In production, these would be fetched from an API like ExchangeRate-API or Fixer.io
  static const Map<String, double> _exchangeRates = {
    'IDR': 1.0,
    'USD': 15300.0, // 1 USD = 15,300 IDR (approximate)
    'EUR': 16800.0, // 1 EUR = 16,800 IDR (approximate)
    'GBP': 19500.0, // 1 GBP = 19,500 IDR (approximate)
    'SGD': 11400.0, // 1 SGD = 11,400 IDR (approximate)
    'MYR': 3500.0, // 1 MYR = 3,500 IDR (approximate)
  };

  /// Converts amount from one currency to another
  /// [amountMinor] - Amount in minor units (cents)
  /// [fromCurrency] - Source currency code
  /// [toCurrency] - Target currency code
  /// Returns converted amount in minor units
  static int convert({
    required int amountMinor,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) {
      return amountMinor; // No conversion needed
    }

    final fromRate = _exchangeRates[fromCurrency];
    final toRate = _exchangeRates[toCurrency];

    if (fromRate == null || toRate == null) {
      // If currency not supported, return original amount
      return amountMinor;
    }

    // Convert to IDR first, then to target currency
    final amountInIDR = (amountMinor / 100.0) * fromRate;
    final convertedAmount = amountInIDR / toRate;

    return (convertedAmount * 100).round();
  }

  /// Gets the exchange rate between two currencies
  static double getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return 1.0;

    final fromRate = _exchangeRates[fromCurrency] ?? 1.0;
    final toRate = _exchangeRates[toCurrency] ?? 1.0;

    return fromRate / toRate;
  }

  /// Checks if a currency is supported
  static bool isCurrencySupported(String currency) {
    return _exchangeRates.containsKey(currency);
  }

  /// Gets all supported currencies
  static List<String> getSupportedCurrencies() {
    return _exchangeRates.keys.toList();
  }
}
