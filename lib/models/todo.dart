class Todo {
  final String id;
  final String text;
  final DateTime date;
  bool completed;

  Todo({
    required this.text,
    required this.date,
    this.completed = false,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'date': date,
      'completed': completed,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      text: map['text'],
      date: map['date'],
      completed: map['completed'] ?? false,
    );
  }
} 