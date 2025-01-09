import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:todo_app/utils/date_formatter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 15,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AppData>(
              builder: (context, appData, child) {
                final today = DateTime.now();
                final events = _getEventsForDay(today, appData);
                
                return ListView.builder(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Navigation logic
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: event.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: _getTagColor(tag),
                    labelStyle: const TextStyle(color: Colors.white),
                  )).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toUpperCase()) {
      case 'ME TIME':
        return Colors.pink.shade200;
      case 'FITNESS':
        return Colors.green;
      case 'FAMILY':
        return Colors.amber;
      case 'FRIENDS':
        return Colors.purple.shade200;
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