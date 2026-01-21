// core/data/util.dart


class Util {
  /// Returns a `DateTime` object representing the current date at midnight UTC.
  ///
  /// This method make time easier to deal with, as now there is only equal comparasents.
  static DateTime now() {
    DateTime temp = DateTime.now().toUtc(); // Get current time in UTC.
    return DateTime(temp.year, temp.month, temp.day); // Return date part only.
  }
}