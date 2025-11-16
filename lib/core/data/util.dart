/// A utility class for handling common date and time operations.
/// This class standardizes how dates are retrieved to ensure consistency
/// in date-based logic, such as streak calculations, by ignoring time components.

class DateUtil {
  /// Returns a `DateTime` object representing the current date at midnight UTC.
  ///
  /// This method make time easier to deal with, as now there is only equal comparasents.
  static DateTime now() {
    DateTime temp = DateTime.now().toUtc(); // Get current time in UTC.
    return DateTime(temp.year, temp.month, temp.day); // Return date part only.
  }
}