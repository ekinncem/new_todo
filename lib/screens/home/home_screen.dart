import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:todo_app/utils/date_formatter.dart';
import 'package:todo_app/widgets/add_item_dialog.dart';
import 'package:todo_app/calendar_page.dart';
import 'package:todo_app/models/user_data.dart';
import 'package:todo_app/widgets/edit_profile_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  AnimationController? _fabAnimationController;
  Animation<double>? _fabScaleAnimation;
  Animation<double>? _fabRotateAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _fabAnimationController!,
        curve: Curves.easeInOut,
      ),
    );

    _fabRotateAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(
        parent: _fabAnimationController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTapDown: (_) => _fabAnimationController?.forward(),
      onTapUp: (_) {
        _fabAnimationController?.reverse();
        _showAddDialog(context);
      },
      onTapCancel: () => _fabAnimationController?.reverse(),
      child: AnimatedBuilder(
        animation: _fabAnimationController!,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation?.value ?? 1.0,
            child: Transform.rotate(
              angle: (_fabRotateAnimation?.value ?? 0) * 2 * 3.14159,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8E2DE2).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _fabAnimationController?.dispose();
    super.dispose();
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