import 'dart:async';
import 'dart:ui';
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
    _setupAnimations();
    _startImageTimer();
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

  void _startImageTimer() {
    _imageTimer?.cancel();
    _imageTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      try {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
      } catch (e) {
        debugPrint('Timer error: $e');
        timer.cancel();
      }
    });
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
    _imageTimer?.cancel();
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
              Text(
                'Upcoming Events',
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Poppins',
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
              final events = _getUpcomingEvents(appData);
              
              return events.isEmpty
                  ? Center(
                      child: Text(
                        'No upcoming events for next week',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return EventCard(
                          event: event,
                          showDate: true,
                          onDelete: (eventItem) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Event'),
                                content: Text(
                                  'Are you sure you want to delete this ${eventItem.type}?'
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (eventItem.type == 'todo') {
                                        appData.deleteTodo(eventItem.id);
                                      } else {
                                        appData.deleteNote(eventItem.id);
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
                        );
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
        onAdd: (text, type, priority) {
          final appData = context.read<AppData>();
          if (type == 'todo') {
            appData.addTodo(text, date: DateTime.now(), priority: priority);
          } else {
            appData.addNote(text, date: DateTime.now(), priority: priority);
          }
        },
      ),
    );
  }

  List<EventItem> _getUpcomingEvents(AppData appData) {
    final List<EventItem> events = [];
    final DateTime now = DateTime.now();
    final DateTime oneWeekLater = now.add(const Duration(days: 7));

    // To-do'ları ekle
    for (var todo in appData.todos) {
      final todoDate = todo['date'] as DateTime;
      if (!todoDate.isBefore(now) && !todoDate.isAfter(oneWeekLater)) {
        events.add(EventItem(
          id: todo['id'],
          title: todo['text'],
          time: todoDate,
          type: 'todo',
          priority: todo['priority'] ?? 'normal',
          tags: const [],
        ));
      }
    }

    // Notları ekle
    for (var note in appData.notes) {
      final noteDate = note['date'] as DateTime;
      if (!noteDate.isBefore(now) && !noteDate.isAfter(oneWeekLater)) {
        events.add(EventItem(
          id: note['id'],
          title: note['text'],
          time: noteDate,
          type: 'note',
          priority: note['priority'] ?? 'normal',
          tags: const [],
        ));
      }
    }

    // Tarihe göre sırala
    events.sort((a, b) => a.time.compareTo(b.time));

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Arka plan resmi
        SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_backgroundImages[_currentImageIndex]),
                fit: BoxFit.cover,
                opacity: 0.25,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.25),
                  BlendMode.softLight,
                ),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.85),
                  Colors.black,
                ],
                stops: const [0.0, 0.3, 0.7],
              ),
            ),
          ),
        ),
        
        // Ana içerik
        Scaffold(
          backgroundColor: Colors.transparent,  // Scaffold arka planı şeffaf
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const EditProfileDialog(),
                    );
                  },
                  child: Consumer<UserData>(
                    builder: (context, userData, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.transparent,
                          child: userData.photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    userData.photoUrl!,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  userData.name?.isNotEmpty == true
                                      ? userData.name![0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          body: IndexedStack( // Sayfalar arası geçişi optimize et
            index: _selectedIndex,
            children: [
              _buildHomeContent(),
              const CalendarPage(),
            ],
          ),
          floatingActionButton: _buildFAB(),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 0.5,
              ),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
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
                if (mounted) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final EventItem event;
  final Function(EventItem) onDelete;
  final bool showDate;

  const EventCard({
    Key? key,
    required this.event,
    required this.onDelete,
    this.showDate = false,
  }) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'normal':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

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
                    showDate
                        ? DateFormatter.formatDate(event.time)
                        : DateFormatter.formatTime(event.time),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(event.priority ?? 'normal').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getPriorityColor(event.priority ?? 'normal').withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          (event.priority ?? 'NORMAL').toUpperCase(),
                          style: TextStyle(
                            color: _getPriorityColor(event.priority ?? 'normal'),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () => onDelete(event),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EventItem {
  final int id;
  final String title;
  final DateTime time;
  final String type;
  final String priority;
  final List<String> tags;

  EventItem({
    required this.id,
    required this.title,
    required this.time,
    required this.type,
    this.priority = 'normal',
    this.tags = const [],
  });
} 