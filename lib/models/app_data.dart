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
          'isTodo': event['isTodo'] == 1,
        });
      }
    }
    notifyListeners();
  }

  List<String> get todos => _todos;
  List<String> get notes => _notes;
  Map<DateTime?, List<dynamic>> get events => _events;

  void addTodo(String todo, {DateTime? date}) async {
    final id = await dbHelper.insertTodo(todo, date);
    _todos.add(todo);
    if (date != null) {
      addEvent(date, todo, true);
    }
    notifyListeners();
  }

  void removeTodo(int index, {DateTime? date}) async {
    String todo = _todos[index];
    _todos.removeAt(index);
    final todoId = await dbHelper.getTodos();
    final id = todoId.firstWhere((element) => element['title'] == todo)['id'];
    await dbHelper.deleteTodo(id);
    if (date != null) {
      removeEventByTitle(date, todo);
    }
    notifyListeners();
  }

  void addNote(String note, {DateTime? date}) async {
    final id = await dbHelper.insertNote(note, date);
    _notes.add(note);
    if (date != null) {
      addEvent(date, note, false);
    }
    notifyListeners();
  }

  void removeNote(int index, {DateTime? date}) async {
    String note = _notes[index];
    _notes.removeAt(index);
    final noteId = await dbHelper.getNotes();
    final id = noteId.firstWhere((element) => element['title'] == note)['id'];
    await dbHelper.deleteNote(id);
    if (date != null) {
      removeEventByTitle(date, note);
    }
    notifyListeners();
  }

  void addEvent(DateTime date, String title, bool isTodo) async {
    await dbHelper.insertEvent(title, date, isTodo);
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

  void removeEvent(DateTime date, int index) async {
    if (_events[date] != null) {
      final event = _events[date]![index];
      _events[date]!.removeAt(index);
      final eventId = await dbHelper.getEvents();
      final id = eventId.firstWhere((element) => element['title'] == event['title'] && DateTime.tryParse(element['date']) == date)['id'];
      await dbHelper.deleteEvent(id);
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

  void removeEventByTitle(DateTime? date, String title) async {
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
    if (_todos.contains(title)) {
      _todos.remove(title);
    } else if (_notes.contains(title)) {
      _notes.remove(title);
    }
    notifyListeners();
  }
} 