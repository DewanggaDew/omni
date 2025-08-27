import 'package:intl/intl.dart';

class CurrencyFormatter {
  static const String _defaultCurrency = 'IDR';
  static const String _defaultLocale = 'id_ID';

  /// Formats an amount in minor units (cents) to currency string
  /// [amountMinor] - Amount in minor units (e.g., 123456 for IDR 1,234.56)
  /// [currencyCode] - Currency code (e.g., 'IDR', 'USD')
  /// [locale] - Locale for formatting (e.g., 'id_ID', 'en_US')
  /// [showSymbol] - Whether to show currency symbol
  static String format(
    int amountMinor, {
    String? currencyCode,
    String? locale,
    bool showSymbol = true,
  }) {
    final currency = currencyCode ?? _defaultCurrency;
    final localeCode = locale ?? _defaultLocale;
    final amount = amountMinor / 100.0;

    try {
      final formatter = NumberFormat.currency(
        locale: localeCode,
        symbol: showSymbol ? currency : '',
        decimalDigits: 2,
      );

      return formatter.format(amount);
    } catch (e) {
      // Fallback to simple formatting if locale is not supported
      return _formatFallback(amount, currency, showSymbol);
    }
  }

  /// Formats amount with sign prefix for expense/income display
  static String formatWithSign(
    int amountMinor,
    String type, {
    String? currencyCode,
    String? locale,
    bool showSymbol = true,
  }) {
    final formattedAmount = format(
      amountMinor,
      currencyCode: currencyCode,
      locale: locale,
      showSymbol: showSymbol,
    );

    final sign = type == 'expense' ? '-' : '+';
    return '$sign$formattedAmount';
  }

  /// Compact formatting for large amounts (e.g., 1.2K, 1.5M)
  static String formatCompact(
    int amountMinor, {
    String? currencyCode,
    String? locale,
    bool showSymbol = true,
  }) {
    final currency = currencyCode ?? _defaultCurrency;
    final localeCode = locale ?? _defaultLocale;
    final amount = amountMinor / 100.0;

    // For smaller amounts (under 100K), use regular formatting
    if (amount.abs() < 100000) {
      return format(
        amountMinor,
        currencyCode: currencyCode,
        locale: locale,
        showSymbol: showSymbol,
      );
    }

    try {
      final symbol = showSymbol ? getCurrencySymbol(currency) : '';
      final formatter = NumberFormat.compactCurrency(
        locale: localeCode,
        symbol: symbol,
        decimalDigits: 1,
      );

      return formatter.format(amount);
    } catch (e) {
      return _formatFallback(amount, currency, true);
    }
  }

  /// Parse currency string back to minor units
  static int? parseToMinorUnits(String currencyString) {
    try {
      // Remove currency symbols and spaces
      final cleanString = currencyString
          .replaceAll(RegExp(r'[^\d.,\-+]'), '')
          .replaceAll(',', '');

      final amount = double.tryParse(cleanString);
      if (amount != null) {
        return (amount * 100).round();
      }
    } catch (e) {
      // Parsing failed
    }
    return null;
  }

  /// Fallback formatting when locale is not supported
  static String _formatFallback(
    double amount,
    String currency,
    bool showSymbol,
  ) {
    final formattedNumber = amount.toStringAsFixed(2);
    final parts = formattedNumber.split('.');

    // Add thousand separators
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );

    final formatted = '$formattedInteger.$decimalPart';
    return showSymbol ? '$currency $formatted' : formatted;
  }

  /// Get currency symbol for a given currency code
  static String getCurrencySymbol(String currencyCode) {
    final commonSymbols = {
      'IDR': 'Rp',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'SGD': 'S\$',
      'MYR': 'RM',
    };

    return commonSymbols[currencyCode] ?? currencyCode;
  }

  /// Get popular currencies list
  static List<Map<String, String>> getPopularCurrencies() {
    return [
      {'code': 'IDR', 'name': 'Indonesian Rupiah', 'symbol': 'Rp'},
      {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
      {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
      {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
      {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': 'S\$'},
      {'code': 'MYR', 'name': 'Malaysian Ringgit', 'symbol': 'RM'},
      {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
      {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
      {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
      {'code': 'THB', 'name': 'Thai Baht', 'symbol': '฿'},
    ];
  }
}
