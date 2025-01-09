class Note {
  final String id;
  final String text;
  final DateTime date;

  Note({
    required this.text,
    required this.date,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'date': date,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      text: map['text'],
      date: map['date'],
    );
  }
} 