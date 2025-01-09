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
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  List<EventItem> _getEventsForDay(DateTime day, AppData appData) {
    final List<EventItem> events = [];

    // To-do'ları ekle
    for (var todo in appData.todos) {
      if (DateFormatter.isSameDay(todo['date'], day)) {
        events.add(EventItem(
          title: todo['text'],
          time: DateFormatter.formatTime(todo['date']),
          type: 'todo',
          tags: ['ME TIME'],
          isCompleted: todo['completed'] ?? false,
        ));
      }
    }

    // Notları ekle
    for (var note in appData.notes) {
      if (DateFormatter.isSameDay(note['date'], day)) {
        events.add(EventItem(
          title: note['text'],
          time: DateFormatter.formatTime(note['date']),
          type: 'note',
          tags: ['FAMILY'],
          isCompleted: false,
        ));
      }
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        return Column(
          children: [
            _buildCalendarHeader(),
            _buildCalendar(appData),
            const SizedBox(height: 20),
            _buildEventsList(appData),
          ],
        );
      },
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

  Widget _buildCalendar(AppData appData) {
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
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
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
        markerSize: 5,
        markersMaxCount: 1,
      ),
      headerVisible: false,
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.white70),
        weekendStyle: TextStyle(color: Colors.white70),
      ),
      eventLoader: (day) => _getEventsForDay(day, appData),
    );
  }

  Widget _buildEventsList(AppData appData) {
    final events = _selectedDay != null ? _getEventsForDay(_selectedDay!, appData) : [];

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: events.isEmpty
            ? Center(
                child: Text(
                  'No events for this day',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventTile(event, appData);
                },
              ),
      ),
    );
  }

  Widget _buildEventTile(EventItem event, AppData appData) {
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
                  event.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: event.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (event.type == 'todo')
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: IconButton(
                icon: Icon(
                  event.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: event.isCompleted ? const Color(0xFF8E2DE2) : Colors.white70,
                ),
                onPressed: () {
                  // Todo tamamlama işlemi
                  final todoIndex = appData.todos.indexWhere(
                    (todo) => todo['text'] == event.title && 
                            DateFormatter.isSameDay(todo['date'], _selectedDay),
                  );
                  if (todoIndex != -1) {
                    appData.toggleTodo(todoIndex);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class EventItem {
  final String title;
  final String time;
  final String type;
  final List<String> tags;
  final bool isCompleted;

  EventItem({
    required this.title,
    required this.time,
    required this.type,
    required this.tags,
    this.isCompleted = false,
  });
}