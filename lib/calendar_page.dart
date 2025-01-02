import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
  }

  void _addEvent(BuildContext context, String title, bool isTodo) {
    if (_selectedDay != null) {
      Provider.of<AppData>(context, listen: false).addEvent(_selectedDay!, title, isTodo);
    }
  }

  void _removeEvent(BuildContext context, DateTime date, int index) {
    Provider.of<AppData>(context, listen: false).removeEvent(date, index);
  }

  List<dynamic> _getEventsForDay(BuildContext context, DateTime day) {
    return Provider.of<AppData>(context).events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Takvim',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFFD4AC0D),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
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
            eventLoader: (day) => _getEventsForDay(context, day),
          ),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDay!),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          if (_selectedDay != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddDialog(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('To-Do Ekle'),
                ),
                ElevatedButton(
                  onPressed: () => _showAddDialog(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Not Ekle'),
                ),
              ],
            ),
          if (_selectedDay != null)
            Expanded(
              child: Consumer<AppData>(
                builder: (context, appData, child) {
                  return ListView.builder(
                    itemCount: _getEventsForDay(context, _selectedDay!).length,
                    itemBuilder: (context, index) {
                      final event = _getEventsForDay(context, _selectedDay!)[index];
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          leading: Icon(
                            event['isTodo'] ? Icons.check_box_outline_blank : Icons.note,
                            color: const Color(0xFF8B4513),
                          ),
                          title: Text(event['title']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _removeEvent(context, _selectedDay!, index);
                            },
                          ),
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

  void _showAddDialog(BuildContext context, bool isTodo) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTodo ? 'Yeni To-Do' : 'Yeni Not'),
        content: TextField(
          controller: controller,
          textAlign: TextAlign.center, // Yazıyı ortalamak için
          decoration: InputDecoration(
            hintText: isTodo ? 'To-Do girin' : 'Not girin',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addEvent(context, controller.text, isTodo);
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
} 