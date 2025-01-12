import 'package:flutter/material.dart';
import 'package:todo_app/widgets/custom_text_field.dart';
import 'package:todo_app/utils/date_formatter.dart';

class AddItemDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String text, String type, String priority) onAdd;

  const AddItemDialog({
    Key? key,
    required this.selectedDate,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _textController = TextEditingController();
  String _selectedType = 'todo';
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _priority = 'normal';

  Widget _buildPriorityButton(String priority, String label, Color color) {
    final isSelected = _priority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = priority),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Event',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Date: ${DateFormatter.formatDate(widget.selectedDate)}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            Row(
              children: [
                _buildTypeButton('todo', 'Task', Icons.task_alt),
                const SizedBox(width: 12),
                _buildTypeButton('note', 'Note', Icons.note_add),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter text...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            const Text(
              'Priority',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPriorityButton('low', 'Low', Colors.green),
                const SizedBox(width: 8),
                _buildPriorityButton('normal', 'Normal', Colors.orange),
                const SizedBox(width: 8),
                _buildPriorityButton('high', 'High', Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) {
                      setState(() => _selectedTime = time);
                    }
                  },
                  child: Text(
                    _selectedTime.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    widget.onAdd(_textController.text, _selectedType, _priority);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: const Color(0xFF8E2DE2),
                ),
                child: const Text(
                  'Add Event',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8E2DE2).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF8E2DE2) : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF8E2DE2) : Colors.grey,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF8E2DE2) : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 