import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:todo_app/utils/date_formatter.dart';
import 'package:todo_app/widgets/add_item_dialog.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  int _currentImageIndex = 0;
  Timer? _imageTimer;

  final List<String> _backgroundImages = [
    'assets/images/image1.jpg',
    'assets/images/image2.jpg',
    'assets/images/image3.jpg',
    'assets/images/image4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = null;
    _startImageTimer();
  }

  void _startImageTimer() {
    _imageTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
      });
    });
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    super.dispose();
  }

  void _showAddDialog(BuildContext context, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        selectedDate: selectedDate,
        onAdd: (text, type, priority) {
          final appData = context.read<AppData>();
          if (type == 'todo') {
            appData.addTodo(text, date: selectedDate, priority: priority);
          } else {
            appData.addNote(text, date: selectedDate, priority: priority);
          }
        },
      ),
    );
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
        // Takvim kısmı
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(8),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => 
                _selectedDay != null && isSameDay(_selectedDay!, day),
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
        ),
        const SizedBox(height: 20),
        // Seçili tarih ve ekleme butonu
        if (_selectedDay != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.formatDate(_selectedDay!),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF8E2DE2),
                    size: 28,
                  ),
                  onPressed: () => _showAddDialog(context, _selectedDay!),
                ),
              ],
            ),
          ),
        // Alt kısım (Liste ve arka plan)
        Expanded(
          child: Stack(
            children: [
              // Arka plan resmi
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: Image.asset(
                    _backgroundImages[_currentImageIndex],
                    key: ValueKey<int>(_currentImageIndex),
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.4), // Transparanlığı azalttık
                  ),
                ),
              ),
              // Event listesi
              Consumer<AppData>(
                builder: (context, appData, child) {
                  final events = _selectedDay != null 
                      ? _getEventsForDay(_selectedDay!, appData)
                      : [];

                  if (_selectedDay == null) {
                    return Center(
                      child: Text(
                        'Select a date to see events',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    );
                  }

                  return events.isEmpty
                      ? Center(
                          child: Text(
                            'No events for ${DateFormatter.formatDate(_selectedDay!)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        )
                      : ListView.builder(
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
            ],
          ),
        ),
      ],
    );
  }
}