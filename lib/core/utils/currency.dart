import 'dart:ui';

String defaultCurrencyForLocale(Locale locale) {
  final countryCode = locale.countryCode?.toUpperCase();
  if (countryCode == 'ID') return 'IDR';
  if (countryCode == 'MY') return 'MYR';
  // Fallback by language
  final lang = locale.languageCode.toLowerCase();
  if (lang == 'id') return 'IDR';
  if (lang == 'ms') return 'MYR';
  return 'IDR';
}

