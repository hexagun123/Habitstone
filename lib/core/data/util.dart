// core/data/util.dart
// all the date time utilities
// a helper class

class DateUtil {
  // get all the date time function here
  // get now straight from here to avoid any utc errors
  static DateTime temp = DateTime.now().toUtc();
  static DateTime now() => DateTime(temp.year, temp.month, temp.day); // goes straight to days, w~
}
