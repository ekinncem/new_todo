import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _textController = TextEditingController();
  DateTime? _selectedDate;

  void _addNote() {
    if (_textController.text.isNotEmpty) {
      context.read<AppData>().addNote(
        _textController.text, 
        date: _selectedDate ?? DateTime.now(),
      );
      _textController.clear();
      _selectedDate = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Yeni not ekle...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: DateTime(now.year + 5),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNote,
                ),
              ],
            ),
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Seçili tarih: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          Expanded(
            child: Consumer<AppData>(
              builder: (context, appData, child) {
                return ListView.builder(
                  itemCount: appData.notes.length,
                  itemBuilder: (context, index) {
                    final note = appData.notes[index];
                    return ListTile(
                      title: Text(note['text']),
                      subtitle: note['date'] != null
                          ? Text(
                              DateFormat('dd/MM/yyyy').format(note['date']),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          appData.removeNote(index);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}