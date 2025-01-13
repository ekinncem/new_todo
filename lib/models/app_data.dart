import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';

class AppData with ChangeNotifier {
  Database? _db;
  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> _notes = [];
  final Map<DateTime, List<String>> _events = {};

  List<Map<String, dynamic>> get todos => _todos;
  List<Map<String, dynamic>> get notes => _notes;
  Map<DateTime, List<String>> get events => _events;

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
            content TEXT,
            date INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE events(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            date INTEGER
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
        notifyListeners();
      }
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

  Future<void> addEvent(DateTime selectedDate, String title) async {
    if (_db == null) return;

    // Normalize the date to remove time component
    final DateTime normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    await _db!.insert('events', {
      'title': title,
      'date': normalizedDate.millisecondsSinceEpoch,
    });

    if (!_events.containsKey(normalizedDate)) {
      _events[normalizedDate] = [];
    }
    _events[normalizedDate]!.add(title);
    notifyListeners();
  }

  List<Map<String, dynamic>> getEventsForDate(DateTime date) {
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    final events = _events[normalizedDate] ?? [];
    return events.map((title) => {
      'title': title,
      'date': normalizedDate,
    }).toList();
  }

  Future<void> loadEvents() async {
    if (_db == null) return;

    final eventsList = await _db!.query('events');
    _events.clear();

    for (var event in eventsList) {
      final date = DateTime.fromMillisecondsSinceEpoch(event['date'] as int);
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (!_events.containsKey(normalizedDate)) {
        _events[normalizedDate] = [];
      }
      _events[normalizedDate]!.add(event['title'] as String);
    }
    notifyListeners();
  }

  Future<void> removeEvent(DateTime date, String title) async {
    if (_db == null) return;

    final DateTime normalizedDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    await _db!.delete(
      'events',
      where: 'date = ? AND title = ?',
      whereArgs: [normalizedDate.millisecondsSinceEpoch, title],
    );

    if (_events.containsKey(normalizedDate)) {
      _events[normalizedDate]!.remove(title);
      if (_events[normalizedDate]!.isEmpty) {
        _events.remove(normalizedDate);
      }
    }
    notifyListeners();
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
