// core/data/util.dart
// all the date time utilities
// a helper class

class DateUtil {

    // get all the date time function here
    // get now straight from here to avoid any utc errors
    static DateTime now() =>
        DateTime.now().toUtc()
    // put a date to midnight for easy comparasent between dates
    // most be utc
  static DateTime toMidnight(DateTime date) =>
      DateTime(date.year, date.month, date.day);

    // check whether if two date are on the same day
    // prefered utc
  static bool isSameDay(DateTime a, DateTime b) =>
      toMidnight(a) == toMidnight(b);

    // check if a time is yesterday
    // the date passed in must be in utc aswell
  static bool isYesterday(DateTime date) {
    final yesterday = DateUtil.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
}
