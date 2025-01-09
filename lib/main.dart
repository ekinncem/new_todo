import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_app/todo_page.dart';
import 'package:todo_app/notes_page.dart';
import 'package:todo_app/calendar_page.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // SQLite başlatma
    if (defaultTargetPlatform == TargetPlatform.android) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    // Tarih formatlaması başlatma
    await initializeDateFormatting('tr_TR', null);
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppData()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Uygulama başlatma hatası: $e');
    debugPrint('Hata detayı: $stackTrace');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do & Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
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
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  
  final List<Widget> _pages = [
    const TodoPage(),
    const NotesPage(),
    const CalendarPage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Container(
            color: Colors.white.withOpacity(0.85),
            child: SlideTransition(
              position: _offsetAnimation,
              child: _pages[_selectedIndex],
            ),
          ),
        ),
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
