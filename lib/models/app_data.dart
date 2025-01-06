import 'package:flutter/material.dart';
import 'package:todo_app/database_helper.dart';

class AppData extends ChangeNotifier {
  List<String> _todos = [];
  List<String> _notes = [];
  Map<DateTime?, List<dynamic>> _events = {};
  final dbHelper = DatabaseHelper();

  AppData() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final todos = await dbHelper.getTodos();
      _todos = todos.map((todo) => todo['title'] as String).toList();

      final notes = await dbHelper.getNotes();
      _notes = notes.map((note) => note['title'] as String).toList();

      final events = await dbHelper.getEvents();
      _events = {};
      for (var event in events) {
        final date = DateTime.tryParse(event['date'] ?? '');
        if (date != null) {
          if (_events[date] == null) {
            _events[date] = [];
          }
          _events[date]!.add({
            'title': event['title'],
            'type': event['isTodo'] == 1 ? 'todo' : 'note',
          });
        }
      }
    } catch (e) {
      print('Veri yüklenirken hata oluştu: $e');
    }
    notifyListeners();
  }

  List<String> get todos => _todos;
  List<String> get notes => _notes;
  Map<DateTime?, List<dynamic>> get events => _events;

  void addTodo(String todo, {DateTime? date}) async {
    try {
      final id = await dbHelper.insertTodo(todo, date);
      _todos.add(todo);
      if (date != null) {
        addEvent(date, todo, type: 'todo');
      }
      notifyListeners();
    } catch (e) {
      print('To-Do eklenirken hata oluştu: $e');
    }
  }

  void removeTodo(int index, {DateTime? date}) async {
    try {
      String todo = _todos[index];
      _todos.removeAt(index);
      final todoId = await dbHelper.getTodos();
      final id = todoId.firstWhere((element) => element['title'] == todo)['id'];
      await dbHelper.deleteTodo(id);
      if (date != null) {
        removeEventByTitle(date, todo);
      } else {
        _events.forEach((key, value) {
          value.removeWhere((element) => element['title'] == todo);
          if (value.isEmpty) {
            _events.remove(key);
          }
        });
      }
      notifyListeners();
    } catch (e) {
      print('To-Do silinirken hata oluştu: $e');
    }
  }

  void addNote(String note, {DateTime? date}) async {
    try {
      final id = await dbHelper.insertNote(note, date);
      _notes.add(note);
      if (date != null) {
        addEvent(date, note, type: 'note');
      }
      notifyListeners();
    } catch (e) {
      print('Not eklenirken hata oluştu: $e');
    }
  }

  void removeNote(int index, {DateTime? date}) async {
    try {
      String note = _notes[index];
      _notes.removeAt(index);
      final noteId = await dbHelper.getNotes();
      final id = noteId.firstWhere((element) => element['title'] == note)['id'];
      await dbHelper.deleteNote(id);
      if (date != null) {
        removeEventByTitle(date, note);
      } else {
        _events.forEach((key, value) {
          value.removeWhere((element) => element['title'] == note);
          if (value.isEmpty) {
            _events.remove(key);
          }
        });
      }
      notifyListeners();
    } catch (e) {
      print('Not silinirken hata oluştu: $e');
    }
  }

  void addEvent(DateTime date, String title, {String type = 'event'}) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (events[normalizedDate] == null) {
      events[normalizedDate] = [];
    }
    events[normalizedDate]!.add({'title': title, 'type': type});
    notifyListeners();
  }

  void removeEvent(DateTime date, int index) async {
    try {
      if (_events[date] != null) {
        final event = _events[date]![index];
        _events[date]!.removeAt(index);
        final eventId = await dbHelper.getEvents();
        final id = eventId.firstWhere((element) => element['title'] == event['title'] && DateTime.tryParse(element['date']) == date)['id'];
        await dbHelper.deleteEvent(id);
        if (_events[date]!.isEmpty) {
          _events.remove(date);
        }
        if (event['type'] == 'todo') {
          _todos.remove(event['title']);
        } else if (event['type'] == 'note') {
          _notes.remove(event['title']);
        }
      }
      notifyListeners();
    } catch (e) {
      print('Etkinlik silinirken hata oluştu: $e');
    }
  }

  void removeEventByTitle(DateTime? date, String title) async {
    try {
      if (date == null || _events[date] == null) {
        return;
      }
      _events[date]!.removeWhere((event) => event['title'] == title);
      final eventId = await dbHelper.getEvents();
      final id = eventId.firstWhere((element) => element['title'] == title && DateTime.tryParse(element['date']) == date)['id'];
      await dbHelper.deleteEvent(id);
      if (_events[date]!.isEmpty) {
        _events.remove(date);
      }
      if (_events[date]!.any((event) => event['type'] == 'todo')) {
        _todos.remove(title);
      } else if (_events[date]!.any((event) => event['type'] == 'note')) {
        _notes.remove(title);
      }
      notifyListeners();
    } catch (e) {
      print('Etkinlik başlığına göre silinirken hata oluştu: $e');
    }
  }
}