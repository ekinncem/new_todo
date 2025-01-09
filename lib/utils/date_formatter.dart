import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static bool isSameDay(DateTime? dateA, DateTime? dateB) {
    if (dateA == null || dateB == null) return false;
    return dateA.year == dateB.year &&
        dateA.month == dateB.month &&
        dateA.day == dateB.day;
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
} 