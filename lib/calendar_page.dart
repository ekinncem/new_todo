import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    Intl.defaultLocale = 'tr_TR';
    initializeDateFormatting('tr_TR', null);
  }

  void _addEvent(BuildContext context) {
    if (_selectedDay != null && _eventController.text.isNotEmpty) {
      Provider.of<AppData>(context, listen: false).addEvent(_selectedDay!, _eventController.text, type: 'event');
      _eventController.clear();
    }
  }

  void _removeEvent(BuildContext context, DateTime date, int index) {
    Provider.of<AppData>(context, listen: false).removeEvent(date, index);
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
        backgroundColor: const Color(0xFF9C27B0).withOpacity(0.85),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                return Provider.of<AppData>(context).events[day] ?? [];
              },
            ),
            const SizedBox(height: 20),
            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Seçilen Tarih: ${DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDay!)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _eventController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Yeni bir etkinlik ekle',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () => _addEvent(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Ekle'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<AppData>(
                builder: (context, appData, child) {
                  if (_selectedDay == null) {
                    return const Center(child: Text('Lütfen bir tarih seçin.'));
                  }
                  final events = appData.events[_selectedDay] ?? [];
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListTile(
                          title: Text(event['title']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeEvent(context, _selectedDay!, index),
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
      ),
    );
  }
}