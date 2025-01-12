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
    _imageTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
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
          'title': todo['text'],
          'content': 'Todo Content', // İçerik ekleyin
          'type': 'todo',
          'date': todo['date'],
        });
      }
    }

    // Notları ekle
    for (var note in appData.notes) {
      if (DateFormatter.isSameDay(note['date'], day)) {
        events.add({
          'title': note['text'],
          'content': 'Note Content', // İçerik ekleyin
          'type': 'note',
          'date': note['date'],
        });
      }
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Takvim
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1F25).withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => 
                _selectedDay != null && isSameDay(_selectedDay!, day),
            onDaySelected: (selectedDay, focusedDay) {
              try {
                debugPrint('Seçilen tarih: $selectedDay');
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              } catch (e, stackTrace) {
                debugPrint('Tarih seçme hatası: $e');
                debugPrint('Stack trace: $stackTrace');
              }
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              return _getEventsForDay(day, Provider.of<AppData>(context, listen: false));
            },
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              outsideDaysVisible: false,
              
              defaultTextStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              
              weekendTextStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF8E2DE2),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              
              todayDecoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF8E2DE2),
                  width: 1.5,
                ),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),

              markerDecoration: const BoxDecoration(
                color: Color(0xFF8E2DE2),
                shape: BoxShape.circle,
              ),
              markerSize: 4,
              markersMaxCount: 1,
              
              outsideTextStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            
            headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              formatButtonVisible: false,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white70, size: 28),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white70, size: 28),
            ),
            
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            availableGestures: AvailableGestures.horizontalSwipe,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            daysOfWeekHeight: 40,
            rowHeight: 48,
            sixWeekMonthsEnforced: true,
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
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        // Event listesi
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
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
                          color: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Icon(
                              event['type'] == 'todo' 
                                  ? Icons.check_circle_outline 
                                  : Icons.note,
                              color: event['type'] == 'todo' 
                                  ? const Color(0xFF8E2DE2) 
                                  : Colors.green,
                              size: 28,
                            ),
                            title: Text(
                              event['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                decoration: event['type'] == 'todo' && event['completed'] == true
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              event['content'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (event['type'] == 'todo')
                                  Transform.scale(
                                    scale: 1.2,
                                    child: Checkbox(
                                      value: event['completed'] ?? false,
                                      activeColor: const Color(0xFF8E2DE2),
                                      checkColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (bool? value) {
                                        final todoIndex = appData.todos.indexWhere(
                                          (todo) => todo['text'] == event['title'] &&
                                                  DateFormatter.isSameDay(todo['date'], event['date']),
                                        );
                                        if (todoIndex != -1) {
                                          appData.toggleTodo(todoIndex);
                                        }
                                      },
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Event'),
                                        content: Text(
                                          'Are you sure you want to delete this ${event['type']}?'
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (event['type'] == 'todo') {
                                                appData.deleteTodo(event['id']);
                                              } else {
                                                appData.deleteNote(event['id']);
                                              }
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
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