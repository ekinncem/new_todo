import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
  }

  void _addEvent(String title, bool isTodo) {
    if (_selectedDay != null) {
      setState(() {
        if (_events[_selectedDay!] != null) {
          _events[_selectedDay!]!.add({'title': title, 'isTodo': isTodo});
        } else {
          _events[_selectedDay!] = [{'title': title, 'isTodo': isTodo}];
        }
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
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
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 20),
          if (_selectedDay != null) ...[
            Text(
              DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDay!),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddDialog(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('To-Do Ekle'),
                ),
                ElevatedButton(
                  onPressed: () => _showAddDialog(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Not Ekle'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _getEventsForDay(_selectedDay!).length,
                itemBuilder: (context, index) {
                  final event = _getEventsForDay(_selectedDay!)[index];
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
                          setState(() {
                            _events[_selectedDay!]?.removeAt(index);
                            if (_events[_selectedDay!]?.isEmpty ?? false) {
                              _events.remove(_selectedDay!);
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddDialog(bool isTodo) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTodo ? 'Yeni To-Do' : 'Yeni Not'),
        content: TextField(
          controller: controller,
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
                _addEvent(controller.text, isTodo);
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