import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF17171A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF2C2C2E),
        secondary: Color(0xFF48484A),
        surface: Color(0xFF2C2C2E),
        background: Color(0xFF17171A),
      ),
      cardColor: Color(0xFF2C2C2E),
      
      // AppBar teması
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1C1E),
        elevation: 0,
      ),
      
      // Bottom Navigation teması
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1C1C1E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
      
      // Card teması
      cardTheme: CardTheme(
        color: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // FloatingActionButton teması
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF48484A),
        foregroundColor: Colors.white,
      ),
      
      // Dialog teması
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // TextField teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF48484A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      
      // Calendar teması için özel renkler
      extensions: const <ThemeExtension<dynamic>>[
        CalendarColors(
          selectedDay: Color(0xFF48484A),
          todayColor: Colors.blue,
          eventIndicatorColor: Color(0xFF48484A),
          appointmentColors: {
            'default': Color(0xFFFFFFFF),
            'dentist': Color(0xFFFFFFFF),
            'pilates': Color(0xFFFF9999),
            'dinner': Color(0xFFFFD700),
          },
        ),
      ],
    );
  }
}

// Takvim için özel renkler
class CalendarColors extends ThemeExtension<CalendarColors> {
  final Color selectedDay;
  final Color todayColor;
  final Color eventIndicatorColor;
  final Map<String, Color> appointmentColors;

  const CalendarColors({
    required this.selectedDay,
    required this.todayColor,
    required this.eventIndicatorColor,
    required this.appointmentColors,
  });

  @override
  ThemeExtension<CalendarColors> copyWith({
    Color? selectedDay,
    Color? todayColor,
    Color? eventIndicatorColor,
    Map<String, Color>? appointmentColors,
  }) {
    return CalendarColors(
      selectedDay: selectedDay ?? this.selectedDay,
      todayColor: todayColor ?? this.todayColor,
      eventIndicatorColor: eventIndicatorColor ?? this.eventIndicatorColor,
      appointmentColors: appointmentColors ?? this.appointmentColors,
    );
  }

  @override
  ThemeExtension<CalendarColors> lerp(
    covariant ThemeExtension<CalendarColors>? other,
    double t,
  ) {
    if (other is! CalendarColors) {
      return this;
    }
    return CalendarColors(
      selectedDay: Color.lerp(selectedDay, other.selectedDay, t)!,
      todayColor: Color.lerp(todayColor, other.todayColor, t)!,
      eventIndicatorColor: Color.lerp(eventIndicatorColor, other.eventIndicatorColor, t)!,
      appointmentColors: appointmentColors,
    );
  }
} 