import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toMonthKey() {
    return DateFormat('yyyy-MM').format(this);
  }

  String toFormattedDate({String locale = 'en'}) {
    return DateFormat.yMMMd(locale).format(this);
  }

  String toFormattedDayMonth({String locale = 'en'}) {
    return DateFormat.MMMd(locale).format(this);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension DoubleExtensions on double {
  String toCurrency({String symbol = '৳', String locale = 'en'}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(this);
  }

  String toCleanString() {
    if (this == truncateToDouble()) {
      return truncate().toString();
    }
    return toStringAsFixed(1);
  }
}

extension StringNumeralExtension on String {
  String toBanglaNumerals() {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    
    String result = this;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bangla[i]);
    }
    return result;
  }

  String toEnglishNumerals() {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    String result = this;
    for (int i = 0; i < bangla.length; i++) {
      result = result.replaceAll(bangla[i], english[i]);
    }
    return result;
  }
}
