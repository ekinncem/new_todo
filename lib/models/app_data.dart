import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:todo_app/services/notification_service.dart';

class AppData with ChangeNotifier {
  Database? _db;
  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> _notes = [];
  final Map<DateTime, List<String>> _events = {};

  List<Map<String, dynamic>> get todos => _todos;
  List<Map<String, dynamic>> get notes => _notes;

  Future<void> init() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo_app.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT,
            date INTEGER,
            completed INTEGER DEFAULT 0,
            priority TEXT DEFAULT 'normal'
          )
        ''');
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT,
            date INTEGER,
            priority TEXT DEFAULT 'normal'
          )
        ''');
      },
    );

    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (_db == null) {
        debugPrint('Veritabanı başlatılmamış!');
        return;
      }

      debugPrint('Veritabanından veriler yükleniyor...');
      final List<Map<String, dynamic>> todoList = await _db!.query('todos');
      final List<Map<String, dynamic>> noteList = await _db!.query('notes');
      
      _todos = todoList.map((todo) => {
        ...todo,
        'date': DateTime.fromMillisecondsSinceEpoch(todo['date'] as int),
        'completed': todo['completed'] == 1,
      }).toList();
      
      _notes = noteList.map((note) => {
        ...note,
        'date': DateTime.fromMillisecondsSinceEpoch(note['date'] as int),
      }).toList();
      
      debugPrint('Yüklenen todo sayısı: ${_todos.length}');
      debugPrint('Yüklenen not sayısı: ${_notes.length}');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Veri yükleme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }

  Future<void> addTodo(String text, {required DateTime date, String priority = 'normal'}) async {
    try {
      await Future.microtask(() async {
        final id = await _db?.insert('todos', {
          'text': text,
          'date': date.millisecondsSinceEpoch,
          'completed': 0,
          'priority': priority,
        });
        
        if (id != null) {
          _todos.add({
            'id': id,
            'text': text,
            'date': date,
            'completed': false,
            'priority': priority,
          });
          
          // Bildirim planla
          await NotificationService.instance.scheduleEventNotification(
            id: id,
            title: text,
            eventDate: date,
            type: 'görev',
          );
          
          notifyListeners();
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Todo ekleme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void toggleTodo(int index) {
    if (index >= 0 && index < _todos.length) {
      _todos[index]['completed'] = !_todos[index]['completed'];
      notifyListeners();
    }
  }

  void removeTodo(int index) {
    if (index >= 0 && index < _todos.length) {
      _todos.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> addNote(String text, {required DateTime date, String priority = 'normal'}) async {
    try {
      debugPrint('Not ekleniyor: $text, tarih: $date');
      final id = await _db?.insert('notes', {
        'text': text,
        'date': date.millisecondsSinceEpoch,
        'priority': priority,
      });
      
      if (id != null) {
        _notes.add({
          'id': id,
          'text': text,
          'date': date,
          'priority': priority,
        });
        notifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint('Not ekleme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void removeNote(int index) {
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index);
      notifyListeners();
    }
  }

  void addEvent(DateTime date, String event, {String type = 'event'}) {
    if (_events[date] == null) {
      _events[date] = [];
    }
    _events[date]!.add(event);
    notifyListeners();
  }

  void removeEvent(DateTime date, int index) {
    if (_events[date] != null && index >= 0 && index < _events[date]!.length) {
      _events[date]!.removeAt(index);
      if (_events[date]!.isEmpty) {
        _events.remove(date);
      }
      notifyListeners();
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _db?.delete(
        'todos',
        where: 'id = ?',
        whereArgs: [id],
      );
      _todos.removeWhere((todo) => todo['id'] == id);
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Todo silme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _db?.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );
      _notes.removeWhere((note) => note['id'] == id);
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Not silme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}