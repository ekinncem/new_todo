import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({Key? key}) : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _professionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedPhotoUrl;
  IconData? _selectedIcon;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final userData = context.read<UserData>();
    _nameController.text = userData.name ?? '';
    _surnameController.text = userData.surname ?? '';
    _professionController.text = userData.profession ?? '';
    _emailController.text = userData.email ?? '';
    _phoneController.text = userData.phone ?? '';
    _selectedPhotoUrl = userData.photoUrl;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedPhotoUrl = pickedFile.path;
      });
    }
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select an Icon'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.user),
                      onPressed: () {
                        setState(() {
                          _selectedIcon = FontAwesomeIcons.user;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.home),
                      onPressed: () {
                        setState(() {
                          _selectedIcon = FontAwesomeIcons.home;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.cog),
                      onPressed: () {
                        setState(() {
                          _selectedIcon = FontAwesomeIcons.cog;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: _selectedPhotoUrl != null
                      ? ClipOval(
                          child: Image.file(
                            File(_selectedPhotoUrl!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _selectedIcon != null
                          ? FaIcon(
                              _selectedIcon,
                              size: 40,
                              color: Colors.grey[800],
                            )
                          : Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey[800],
                            ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _showIconPicker,
                child: const Text('Select Icon'),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _surnameController,
                decoration: const InputDecoration(
                  labelText: 'Surname',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _professionController,
                decoration: const InputDecoration(
                  labelText: 'Profession',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
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
                      context.read<UserData>().updateProfile(
                            name: _nameController.text,
                            surname: _surnameController.text,
                            profession: _professionController.text,
                            email: _emailController.text,
                            phone: _phoneController.text,
                            photoUrl: _selectedPhotoUrl,
                            icon: _selectedIcon,
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
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _professionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
} 