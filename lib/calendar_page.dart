import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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
  String _selectedType = 'todo'; // Varsayılan olarak todo seçili

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _eventController,
              decoration: const InputDecoration(
                hintText: 'Metin girin...',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(
                  value: 'todo',
                  child: Text('Yapılacak'),
                ),
                DropdownMenuItem(
                  value: 'note',
                  child: Text('Not'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (_eventController.text.isNotEmpty && _selectedDay != null) {
                if (_selectedType == 'todo') {
                  context.read<AppData>().addTodo(
                        _eventController.text,
                        date: _selectedDay,
                      );
                } else {
                  context.read<AppData>().addNote(
                        _eventController.text,
                        date: _selectedDay,
                      );
                }
                _eventController.clear();
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final appData = context.read<AppData>();
    final List<Map<String, dynamic>> events = [];

    // To-do'ları ekle
    for (var todo in appData.todos) {
      if (isSameDay(todo['date'], day)) {
        events.add({...todo, 'type': 'todo'});
      }
    }

    // Notları ekle
    for (var note in appData.notes) {
      if (isSameDay(note['date'], day)) {
        events.add({...note, 'type': 'note'});
      }
    }

    return events;
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
            eventLoader: (day) => _getEventsForDay(day),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Consumer<AppData>(
              builder: (context, appData, child) {
                final events = _selectedDay != null
                    ? _getEventsForDay(_selectedDay!)
                    : [];
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final bool isTodo = event['type'] == 'todo';

                    return ListTile(
                      leading: isTodo
                          ? Checkbox(
                              value: event['completed'] ?? false,
                              onChanged: (_) {
                                final todoIndex = appData.todos.indexWhere(
                                  (todo) => todo['text'] == event['text'] && 
                                          isSameDay(todo['date'], event['date']),
                                );
                                if (todoIndex != -1) {
                                  appData.toggleTodo(todoIndex);
                                }
                              },
                            )
                          : const Icon(Icons.note),
                      title: Text(
                        event['text'],
                        style: TextStyle(
                          decoration: (isTodo && event['completed'] == true)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        '${isTodo ? 'Yapılacak' : 'Not'} - ${DateFormat('dd/MM/yyyy').format(event['date'])}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          if (isTodo) {
                            final todoIndex = appData.todos.indexWhere(
                              (todo) => todo['text'] == event['text'] && 
                                      isSameDay(todo['date'], event['date']),
                            );
                            if (todoIndex != -1) {
                              appData.removeTodo(todoIndex);
                            }
                          } else {
                            final noteIndex = appData.notes.indexWhere(
                              (note) => note['text'] == event['text'] && 
                                      isSameDay(note['date'], event['date']),
                            );
                            if (noteIndex != -1) {
                              appData.removeNote(noteIndex);
                            }
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }
}