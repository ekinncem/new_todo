import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:todo_app/utils/date_formatter.dart';
import 'package:todo_app/widgets/add_item_dialog.dart';
import 'package:todo_app/calendar_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, size: 20, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildHomeContent() : const CalendarPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Events for today',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _showAddDialog(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<AppData>(
            builder: (context, appData, child) {
              final today = DateTime.now();
              final events = _getEventsForDay(today, appData);
              
              return events.isEmpty
                  ? Center(
                      child: Text(
                        'No events for today',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return EventCard(event: event);
                      },
                    );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        selectedDate: DateTime.now(),
        onAdd: (text, type) {
          final appData = context.read<AppData>();
          if (type == 'todo') {
            appData.addTodo(text, date: DateTime.now());
          } else {
            appData.addNote(text, date: DateTime.now());
          }
        },
      ),
    );
  }

  List<EventItem> _getEventsForDay(DateTime day, AppData appData) {
    final List<EventItem> events = [];

    // To-do'ları ekle
    for (var todo in appData.todos) {
      if (DateFormatter.isSameDay(todo['date'], day)) {
        events.add(EventItem(
          title: todo['text'],
          time: DateFormatter.formatTime(todo['date']),
          type: 'todo',
          tags: ['ME TIME'],
        ));
      }
    }

    // Notları ekle
    for (var note in appData.notes) {
      if (DateFormatter.isSameDay(note['date'], day)) {
        events.add(EventItem(
          title: note['text'],
          time: DateFormatter.formatTime(note['date']),
          type: 'note',
          tags: ['FAMILY'],
        ));
      }
    }

    return events;
  }
}

class EventCard extends StatelessWidget {
  final EventItem event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: event.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getTagColor(tag),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
            if (event.type == 'todo')
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  icon: const Icon(Icons.check, color: Colors.white70),
                  onPressed: () {
                    // Todo tamamlama işlemi
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toUpperCase()) {
      case 'ME TIME':
        return const Color(0xFFFF8DA1);
      case 'FITNESS':
        return const Color(0xFF4CAF50);
      case 'FAMILY':
        return const Color(0xFFFFB300);
      case 'FRIENDS':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }
}

class EventItem {
  final String title;
  final String time;
  final String type;
  final List<String> tags;

  EventItem({
    required this.title,
    required this.time,
    required this.type,
    required this.tags,
  });
} 