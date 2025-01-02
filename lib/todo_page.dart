import 'package:flutter/material.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<String> todos = [];
  final TextEditingController _textController = TextEditingController();

  void _addTodo() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        todos.add(_textController.text);
        _textController.clear();
      });
    }
  }

  void _removeTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To-Do',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFFD4AC0D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Yeni bir yapılacak ekle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTodo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Ekle',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        todos[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeTodo(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 