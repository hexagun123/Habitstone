// util.dart
class DateUtil {
  static DateTime toMidnight(DateTime date) =>
      DateTime(date.year, date.month, date.day).toUtc();

  static bool isSameDay(DateTime a, DateTime b) =>
      toMidnight(a) == toMidnight(b);

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().toUtc().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
}
