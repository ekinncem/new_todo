import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  List<String> _todos = [];
  List<String> _notes = [];
  Map<DateTime, List<dynamic>> _events = {};

  List<String> get todos => _todos;
  List<String> get notes => _notes;
  Map<DateTime, List<dynamic>> get events => _events;

  void addTodo(String todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void removeTodo(int index) {
    _todos.removeAt(index);
    notifyListeners();
  }

  void addNote(String note) {
    _notes.add(note);
    notifyListeners();
  }

  void removeNote(int index) {
    _notes.removeAt(index);
    notifyListeners();
  }

  void addEvent(DateTime date, String title, bool isTodo) {
    if (_events[date] != null) {
      _events[date]!.add({'title': title, 'isTodo': isTodo});
    } else {
      _events[date] = [{'title': title, 'isTodo': isTodo}];
    }
    notifyListeners();
  }

  void removeEvent(DateTime date, int index) {
    _events[date]?.removeAt(index);
    if (_events[date]?.isEmpty ?? false) {
      _events.remove(date);
    }
    notifyListeners();
  }
} 