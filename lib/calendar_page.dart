import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:todo_app/utils/date_formatter.dart';
import 'package:todo_app/widgets/add_item_dialog.dart';
import 'dart:async';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundOpacity;
  
  final List<String> _backgroundImages = [
    'assets/images/bg1.png',
    'assets/images/bg2.png',
    'assets/images/bg3.png',
    'assets/images/bg4.png',
  ];
  
  int _currentBgIndex = 0;
  String _currentImage = '';
  String _nextImage = '';
  
  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = null;
    
    // Önce controller'ı başlat
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Sonra animation'ı başlat
    _backgroundOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    // En son görsel değişkenlerini ayarla
    _currentImage = _backgroundImages[0];
    _nextImage = _backgroundImages[1];
    
    // Timer'ı başlat ve ilk animasyonu tetikle
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _changeBackground();
    });
    
    // İlk animasyonu başlat
    _backgroundController.forward();
  }

  void _changeBackground() {
    setState(() {
      _currentBgIndex = (_currentBgIndex + 1) % _backgroundImages.length;
      _currentImage = _nextImage;
      _nextImage = _backgroundImages[
        (_currentBgIndex + 1) % _backgroundImages.length
      ];
    });
    
    _backgroundController.reset();
    _backgroundController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
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
    return Stack(
      children: [
        // Mevcut arka plan
        Positioned.fill(
          child: Image.asset(
            _currentImage,
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.15),
          ),
        ),
        // Geçiş yapan arka plan
        FadeTransition(
          opacity: _backgroundOpacity,
          child: Positioned.fill(
            child: Image.asset(
              _nextImage,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.15),
            ),
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
        ),
        // Takvim içeriği
        Column(
          children: [
            TableCalendar(
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
            const SizedBox(height: 20),
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
            Expanded(
              child: Consumer<AppData>(
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
            ),
          ],
        ),
      ],
    );
  }
}