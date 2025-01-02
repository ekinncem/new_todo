import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _textController = TextEditingController();
  DateTime? _selectedDate;
  bool _isCalendarOpen = false;

  void _addTodo(BuildContext context) {
    if (_textController.text.isNotEmpty) {
      Provider.of<AppData>(context, listen: false).addTodo(_textController.text, date: _selectedDate);
      _textController.clear();
      _selectedDate = null;
      _isCalendarOpen = false;
    }
  }

  void _removeTodo(BuildContext context, int index) {
    Provider.of<AppData>(context, listen: false).removeTodo(index, date: _selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yapılacaklar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF6750A4),
      ),
      body: Padding(
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
                    hintText: 'Yeni bir yapılacak ekle',
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
                    _addTodo(context);
                  } else {
                    _showCalendarDialog(context);
                  }
                  setState(() {
                    _isCalendarOpen = !_isCalendarOpen;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  _isCalendarOpen ? 'Ekle' : 'Takvime Ekle',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<AppData>(
                builder: (context, appData, child) {
                  return ListView.builder(
                    itemCount: appData.todos.length,
                    itemBuilder: (context, index) {
                      final todo = appData.todos[index];
                      final eventDate = appData.events.entries.firstWhere(
                        (element) => element.value.any((e) => e['title'] == todo),
                        orElse: () => MapEntry(null, []),
                      ).key;
                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            todo,
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: eventDate != null
                              ? Text(
                                  DateFormat('dd MMMM yyyy', 'tr_TR').format(eventDate),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                )
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeTodo(context, index),
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