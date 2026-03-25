class CurrencyModel {
  final String code;
  final String name;
  final String symbol;
  final String locale;

  const CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.locale,
  });

  static const List<CurrencyModel> supported = [
    CurrencyModel(
      code: 'INR',
      name: 'Indian Rupee',
      symbol: '₹',
      locale: 'en_IN',
    ),
    CurrencyModel(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      locale: 'en_US',
    ),
    CurrencyModel(code: 'EUR', name: 'Euro', symbol: '€', locale: 'de_DE'),
    CurrencyModel(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      locale: 'en_GB',
    ),
    CurrencyModel(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      locale: 'ja_JP',
    ),
    CurrencyModel(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      locale: 'en_AU',
    ),
    CurrencyModel(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'C\$',
      locale: 'en_CA',
    ),
    CurrencyModel(
      code: 'CHF',
      name: 'Swiss Franc',
      symbol: 'CHF',
      locale: 'de_CH',
    ),
    CurrencyModel(
      code: 'CNY',
      name: 'Chinese Yuan',
      symbol: '¥',
      locale: 'zh_CN',
    ),
    CurrencyModel(
      code: 'AED',
      name: 'UAE Dirham',
      symbol: 'د.إ',
      locale: 'ar_AE',
    ),
    CurrencyModel(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      locale: 'en_SG',
    ),
    CurrencyModel(
      code: 'SAR',
      name: 'Saudi Riyal',
      symbol: '﷼',
      locale: 'ar_SA',
    ),
    CurrencyModel(
      code: 'BDT',
      name: 'Bangladeshi Taka',
      symbol: '৳',
      locale: 'bn_BD',
    ),
    CurrencyModel(
      code: 'PKR',
      name: 'Pakistani Rupee',
      symbol: '₨',
      locale: 'ur_PK',
    ),
    CurrencyModel(
      code: 'LKR',
      name: 'Sri Lankan Rupee',
      symbol: '₨',
      locale: 'si_LK',
    ),
    CurrencyModel(
      code: 'NPR',
      name: 'Nepalese Rupee',
      symbol: '₨',
      locale: 'ne_NP',
    ),
    CurrencyModel(code: 'THB', name: 'Thai Baht', symbol: '฿', locale: 'th_TH'),
    CurrencyModel(
      code: 'MYR',
      name: 'Malaysian Ringgit',
      symbol: 'RM',
      locale: 'ms_MY',
    ),
    CurrencyModel(
      code: 'KRW',
      name: 'South Korean Won',
      symbol: '₩',
      locale: 'ko_KR',
    ),
    CurrencyModel(
      code: 'ZAR',
      name: 'South African Rand',
      symbol: 'R',
      locale: 'en_ZA',
    ),
  ];

  static CurrencyModel fromCode(String code) {
    return supported.firstWhere(
      (c) => c.code == code,
      orElse: () => supported.first,
    );
  }
}
