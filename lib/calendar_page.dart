import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _addEvent() {
    if (_selectedDay != null && _eventController.text.isNotEmpty) {
      context.read<AppData>().addEvent(_selectedDay!, _eventController.text);
      _eventController.clear();
      setState(() {});
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    return context.read<AppData>().events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
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
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _eventController,
                    decoration: const InputDecoration(
                      hintText: 'Yeni etkinlik ekle...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addEvent,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AppData>(
              builder: (context, appData, child) {
                final events = _selectedDay != null
                    ? appData.events[_selectedDay] ?? []
                    : [];
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(events[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          if (_selectedDay != null) {
                            appData.removeEvent(_selectedDay!, index);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }
}