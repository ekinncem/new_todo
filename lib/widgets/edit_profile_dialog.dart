import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/user_data.dart';
import 'package:todo_app/widgets/custom_text_field.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({Key? key}) : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _professionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userData = context.read<UserData>();
    _nameController.text = userData.name ?? '';
    _surnameController.text = userData.surname ?? '';
    _professionController.text = userData.profession ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _nameController,
              hintText: 'Name',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _surnameController,
              hintText: 'Surname',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _professionController,
              hintText: 'Profession',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserData>().updateUserInfo(
                      name: _nameController.text,
                      surname: _surnameController.text,
                      profession: _professionController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _professionController.dispose();
    super.dispose();
  }
} 