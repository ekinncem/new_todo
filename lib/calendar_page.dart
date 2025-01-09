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

  List<Map<String, dynamic>> _getEventsForDay(DateTime day, AppData appData) {
    final List<Map<String, dynamic>> events = [];

    // To-do'ları ekle
    for (var todo in appData.todos) {
      if (DateFormatter.isSameDay(todo['date'], day)) {
        events.add({
          ...todo,
          'type': 'todo',
        });
      }
    }

    // Notları ekle
    for (var note in appData.notes) {
      if (DateFormatter.isSameDay(note['date'], day)) {
        events.add({
          ...note,
          'type': 'note',
        });
      }
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
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
          eventLoader: (day) {
            return _getEventsForDay(day, Provider.of<AppData>(context, listen: false));
          },
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Consumer<AppData>(
            builder: (context, appData, child) {
              final events = _selectedDay != null 
                  ? _getEventsForDay(_selectedDay!, appData)
                  : [];

              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Icon(
                        event['type'] == 'todo' ? Icons.check_circle_outline : Icons.note,
                        color: event['type'] == 'todo' ? Colors.blue : Colors.green,
                      ),
                      title: Text(
                        event['text'],
                        style: TextStyle(
                          decoration: event['type'] == 'todo' && event['completed'] == true
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        DateFormatter.formatTime(event['date']),
                      ),
                      trailing: event['type'] == 'todo'
                          ? Checkbox(
                              value: event['completed'] ?? false,
                              onChanged: (bool? value) {
                                final todoIndex = appData.todos.indexWhere(
                                  (todo) => todo['text'] == event['text'] &&
                                          DateFormatter.isSameDay(todo['date'], event['date']),
                                );
                                if (todoIndex != -1) {
                                  appData.toggleTodo(todoIndex);
                                }
                              },
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}