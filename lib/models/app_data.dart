import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  List<String> _todos = [];
  List<String> _notes = [];
  Map<DateTime?, List<dynamic>> _events = {};

  List<String> get todos => _todos;
  List<String> get notes => _notes;
  Map<DateTime?, List<dynamic>> get events => _events;

  void addTodo(String todo, {DateTime? date}) {
    _todos.add(todo);
    if (date != null) {
      addEvent(date, todo, true);
    }
    notifyListeners();
  }

  void removeTodo(int index, {DateTime? date}) {
    String todo = _todos[index];
    _todos.removeAt(index);
    if (date != null) {
      removeEventByTitle(date, todo);
    }
    notifyListeners();
  }

  void addNote(String note, {DateTime? date}) {
    _notes.add(note);
    if (date != null) {
      addEvent(date, note, false);
    }
    notifyListeners();
  }

  void removeNote(int index, {DateTime? date}) {
    String note = _notes[index];
    _notes.removeAt(index);
    if (date != null) {
      removeEventByTitle(date, note);
    }
    notifyListeners();
  }

  void addEvent(DateTime date, String title, bool isTodo) {
    if (_events[date] != null) {
      _events[date]!.add({'title': title, 'isTodo': isTodo});
    } else {
      _events[date] = [{'title': title, 'isTodo': isTodo}];
    }
    if (isTodo) {
      if (!_todos.contains(title)) {
        _todos.add(title);
      }
    } else {
      if (!_notes.contains(title)) {
        _notes.add(title);
      }
    }
    notifyListeners();
  }

  void removeEvent(DateTime date, int index) {
    if (_events[date] != null) {
      final event = _events[date]![index];
      _events[date]!.removeAt(index);
      if (_events[date]!.isEmpty) {
        _events.remove(date);
      }
      if (event['isTodo'] == true) {
        _todos.remove(event['title']);
      } else {
        _notes.remove(event['title']);
      }
    }
    notifyListeners();
  }

  void removeEventByTitle(DateTime? date, String title) {
    if (date == null || _events[date] == null) {
      return;
    }
    _events[date]!.removeWhere((event) => event['title'] == title);
    if (_events[date]!.isEmpty) {
      _events.remove(date);
    }
    if (_todos.contains(title)) {
      _todos.remove(title);
    } else if (_notes.contains(title)) {
      _notes.remove(title);
    }
    notifyListeners();
  }
} 