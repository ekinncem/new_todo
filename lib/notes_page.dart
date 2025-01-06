import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _textController = TextEditingController();
  DateTime? _selectedDate;
  bool _isCalendarOpen = false;

  void _addNote(BuildContext context) {
    if (_textController.text.isNotEmpty) {
      Provider.of<AppData>(context, listen: false).addNote(_textController.text, date: _selectedDate);
      _textController.clear();
      _selectedDate = null;
      _isCalendarOpen = false;
    }
  }

  void _removeNote(BuildContext context, int index) {
    final appData = Provider.of<AppData>(context, listen: false);
    final note = appData.notes[index];
    DateTime? eventDate;
    for (var date in appData.events.keys) {
      if (appData.events[date]!.any((event) => event['title'] == note)) {
        eventDate = date;
        break;
      }
    }
    appData.removeNote(index, date: eventDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notlar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.85),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _textController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Yeni bir not ekle',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_selectedDate != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Seçilen Tarih: ${DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate!)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isCalendarOpen) {
                      _addNote(context);
                    } else {
                      _showCalendarDialog(context);
                    }
                    setState(() {
                      _isCalendarOpen = !_isCalendarOpen;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _isCalendarOpen ? 'Ekle' : 'Takvime Ekle',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<AppData>(
                  builder: (context, appData, child) {
                    return ListView.builder(
                      itemCount: appData.notes.length,
                      itemBuilder: (context, index) {
                        final note = appData.notes[index];
                        DateTime? eventDate;
                        for (var date in appData.events.keys) {
                          if (appData.events[date]!.any((event) => event['title'] == note)) {
                            eventDate = date;
                            break;
                          }
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListTile(
                            title: Text(note),
                            subtitle: eventDate != null
                                ? Text(
                                    DateFormat('dd MMMM yyyy', 'tr_TR').format(eventDate),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeNote(context, index),
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
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        DateTime _focusedDay = DateTime.now();
        DateTime? _selectedDay;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tarih Seç'),
              content: SizedBox(
                width: 300,
                height: 350,
                child: TableCalendar(
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
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () {
                    if (_selectedDay != null) {
                      setState(() {
                        _selectedDate = _selectedDay;
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Seç'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}