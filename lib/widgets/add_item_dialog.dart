import 'package:flutter/material.dart';
import 'package:todo_app/widgets/custom_text_field.dart';

class AddItemDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String text, String type) onAdd;

  const AddItemDialog({
    Key? key,
    required this.selectedDate,
    required this.onAdd,
  }) : super(key: key);

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final TextEditingController _controller = TextEditingController();
  String _selectedType = 'todo';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Ekle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _controller,
            hintText: 'Metin girin...',
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: _selectedType,
            items: const [
              DropdownMenuItem(value: 'todo', child: Text('Yapılacak')),
              DropdownMenuItem(value: 'note', child: Text('Not')),
            ],
            onChanged: (value) {
              setState(() => _selectedType = value!);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onAdd(_controller.text, _selectedType);
              Navigator.pop(context);
            }
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 