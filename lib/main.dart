import 'package:flutter/material.dart';
import 'package:todo_app/todo_page.dart';
import 'package:todo_app/notes_page.dart';
import 'package:todo_app/calendar_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do & Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4AC0D)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  
  final List<Widget> _pages = [
    const TodoPage(),
    const NotesPage(),
    const CalendarPage(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    setState(() {
      if (index > _selectedIndex) {
        _offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
      } else {
        _offsetAnimation = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
      }
      _selectedIndex = index;
      _controller.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlideTransition(
        position: _offsetAnimation,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'To-Do',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Takvim',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B4513),
        onTap: _onItemTapped,
      ),
    );
  }
}
