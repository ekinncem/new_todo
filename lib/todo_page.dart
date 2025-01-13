import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/app_data.dart';
import 'package:intl/intl.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _textController = TextEditingController();
  DateTime? _selectedDate;

  void _addTodo() {
    if (_textController.text.isNotEmpty) {
      context.read<AppData>().addTodo(
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
        title: const Text('Yapılacaklar'),
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
                      hintText: 'Yeni görev ekle...',
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
                  onPressed: _addTodo,
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
                  itemCount: appData.todos.length,
                  itemBuilder: (context, index) {
                    final todo = appData.todos[index];
                    return ListTile(
                      leading: Checkbox(
                        value: todo['completed'],
                        onChanged: (_) {
                          appData.toggleTodo(index);
                        },
                      ),
                      title: Text(
                        todo['text'],
                        style: TextStyle(
                          decoration: todo['completed']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: todo['date'] != null
                          ? Text(
                              DateFormat('dd/MM/yyyy').format(todo['date']),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          appData.removeTodo(index);
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