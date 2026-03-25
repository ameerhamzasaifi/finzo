import 'package:intl/intl.dart';
import '../models/currency_model.dart';

class Formatters {
  static CurrencyModel _currency = CurrencyModel.supported.first; // INR

  static void setCurrency(CurrencyModel currency) {
    _currency = currency;
    _currencyFmt = NumberFormat.currency(
      locale: currency.locale,
      symbol: currency.symbol,
      decimalDigits: 2,
    );
    _compactFmt = NumberFormat.compact(locale: currency.locale);
  }

  static NumberFormat _currencyFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static NumberFormat _compactFmt = NumberFormat.compact(locale: 'en_IN');
  static final _dateShort = DateFormat('dd MMM');
  static final _dateFull = DateFormat('dd MMM yyyy');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _time = DateFormat('hh:mm a');
  static final _month = DateFormat('MMM');

  static String currency(double amount) => _currencyFmt.format(amount);
  static String compact(double amount) =>
      '${_currency.symbol}${_compactFmt.format(amount)}';
  static String dateShort(DateTime d) => _dateShort.format(d);
  static String dateFull(DateTime d) => _dateFull.format(d);
  static String monthYear(DateTime d) => _monthYear.format(d);
  static String month(DateTime d) => _month.format(d);
  static String time(DateTime d) => _time.format(d);

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return dateFull(date);
  }
}
