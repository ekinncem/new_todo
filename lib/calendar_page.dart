import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:todo_app/utils/date_formatter.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendarHeader(),
        _buildCalendar(),
        const SizedBox(height: 20),
        _buildEventsList(),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormatter.formatMonthYear(_focusedDay),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(color: Colors.white),
        weekendTextStyle: const TextStyle(color: Colors.white70),
        selectedDecoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        todayDecoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        markersAlignment: Alignment.bottomCenter,
        markerDecoration: BoxDecoration(
          color: const Color(0xFF8E2DE2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      headerVisible: false,
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.white70),
        weekendStyle: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildEventsList() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Consumer<AppData>(
          builder: (context, appData, child) {
            final events = _getEventsForSelectedDay(appData);
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildEventTile(event);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventTile(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8E2DE2).withOpacity(0.1),
            const Color(0xFF4A00E0).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['text'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatTime(event['date']),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForSelectedDay(AppData appData) {
    if (_selectedDay == null) return [];
    
    final events = <Map<String, dynamic>>[];
    
    for (var todo in appData.todos) {
      if (DateFormatter.isSameDay(todo['date'], _selectedDay)) {
        events.add(todo);
      }
    }
    
    for (var note in appData.notes) {
      if (DateFormatter.isSameDay(note['date'], _selectedDay)) {
        events.add(note);
      }
    }
    
    return events;
  }
}