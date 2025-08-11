// lib/utils/date_utils.dart
import 'package:intl/intl.dart';

/// Utility class for date operations and formatting
class DateUtil {
  /// Get the start of the current week (Monday)
  static DateTime getStartOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - 1;
    if (daysToSubtract < 0) daysToSubtract += 7;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  /// Get the end of the current week (Sunday)
  static DateTime getEndOfWeek(DateTime date) {
    int daysToAdd = 7 - date.weekday;
    if (daysToAdd == 7) daysToAdd = 0;
    return DateTime(date.year, date.month, date.day + daysToAdd, 23, 59, 59);
  }

  /// Get the start of the current month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get the end of the current month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Get the start of the current year
  static DateTime getStartOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Get the end of the current year
  static DateTime getEndOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59);
  }

  /// Get the date n months ago
  static DateTime getDateMonthsAgo(DateTime date, int months) {
    return DateTime(date.year, date.month - months, date.day);
  }

  /// Get the date n days ago
  static DateTime getDateDaysAgo(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  /// Get a human-readable relative date string (Today, Yesterday, etc.)
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    }

    if (isYesterday(date)) {
      return 'Yesterday';
    }

    final now = DateTime.now();

    // Check if it's this week
    final startOfWeek = getStartOfWeek(now);
    if (date.isAfter(startOfWeek)) {
      return DateFormat('EEEE').format(date); // Day name
    }

    // Check if it's this year
    if (date.year == now.year) {
      return DateFormat('MMM d').format(date); // Month and day
    }

    // Otherwise full date
    return DateFormat('MMM d, y').format(date);
  }

  /// Format duration in a human-readable way
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    }

    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }

    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    }

    return '${duration.inSeconds}s';
  }

  /// Get an array of dates for a date range
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    return List.generate(
      days + 1,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
  }

  /// Get month name from month number (1-12)
  static String getMonthName(int month) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  /// Get short month name from month number (1-12)
  static String getShortMonthName(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  /// Get day name from weekday number (1-7, where 1 is Monday)
  static String getDayName(int weekday) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    if (weekday < 1 || weekday > 7) {
      return '';
    }

    return days[weekday - 1];
  }

  /// Get short day name from weekday number (1-7, where 1 is Monday)
  static String getShortDayName(int weekday) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    if (weekday < 1 || weekday > 7) {
      return '';
    }

    return days[weekday - 1];
  }

  /// Get number of days in a month
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Get a date with time set to beginning of day (00:00:00)
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get a date with time set to end of day (23:59:59)
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}
