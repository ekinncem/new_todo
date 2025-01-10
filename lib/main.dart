import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:todo_app/models/user_data.dart';
import 'package:todo_app/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // SQLite başlatma
  if (Platform.isWindows || Platform.isLinux) {
    // Windows/Linux için FFI başlatma
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // AppData ve UserData'yı başlat
  final appData = AppData();
  await appData.init(); // Veritabanını başlat
  
  final userData = UserData();
  await userData.init(); // Kullanıcı verilerini başlat

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => appData),
        ChangeNotifierProvider(create: (_) => userData),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1F25),
        cardColor: const Color(0xFF2D2F39),
      ),
      home: const HomeScreen(),
    );
  }
}
