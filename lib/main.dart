import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_app/todo_page.dart';
import 'package:todo_app/notes_page.dart';
import 'package:todo_app/calendar_page.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todo_app/themes/app_theme.dart';
import 'package:todo_app/screens/home/home_screen.dart';

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
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
