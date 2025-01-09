import 'package:flutter/foundation.dart';

class AppData extends ChangeNotifier {
  final List<Map<String, dynamic>> _todos = [];
  final List<Map<String, dynamic>> _notes = [];
  final Map<DateTime, List<String>> _events = {};

  List<Map<String, dynamic>> get todos => _todos;
  List<Map<String, dynamic>> get notes => _notes;
  Map<DateTime, List<String>> get events => _events;

  void addTodo(String text, {required DateTime date}) {
    _todos.add({
      'text': text,
      'completed': false,
      'date': date,
    });
    notifyListeners();
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

  void addNote(String text, {required DateTime date}) {
    _notes.add({
      'text': text,
      'date': date,
    });
    notifyListeners();
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
}