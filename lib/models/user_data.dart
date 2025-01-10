import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';

class UserData with ChangeNotifier {
  Database? _db;
  String? _name;
  String? _surname;
  String? _profession;
  String? _email;
  String? _phone;
  String? _photoUrl;

  String? get name => _name;
  String? get surname => _surname;
  String? get profession => _profession;
  String? get email => _email;
  String? get phone => _phone;
  String? get photoUrl => _photoUrl;

  Future<void> init() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_profile.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            surname TEXT,
            profession TEXT,
            email TEXT,
            phone TEXT,
            photo_url TEXT
          )
        ''');
      },
    );

    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    final List<Map<String, dynamic>> profiles = await _db!.query('user_profile');
    if (profiles.isNotEmpty) {
      final profile = profiles.first;
      _name = profile['name'];
      _surname = profile['surname'];
      _profession = profile['profession'];
      _email = profile['email'];
      _phone = profile['phone'];
      _photoUrl = profile['photo_url'];
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? surname,
    String? profession,
    String? email,
    String? phone,
    String? photoUrl,
  }) async {
    final profile = {
      'name': name ?? _name,
      'surname': surname ?? _surname,
      'profession': profession ?? _profession,
      'email': email ?? _email,
      'phone': phone ?? _phone,
      'photo_url': photoUrl ?? _photoUrl,
    };

    final profiles = await _db!.query('user_profile');
    if (profiles.isEmpty) {
      await _db!.insert('user_profile', profile);
    } else {
      await _db!.update(
        'user_profile',
        profile,
        where: 'id = ?',
        whereArgs: [profiles.first['id']],
      );
    }

    _name = name ?? _name;
    _surname = surname ?? _surname;
    _profession = profession ?? _profession;
    _email = email ?? _email;
    _phone = phone ?? _phone;
    _photoUrl = photoUrl ?? _photoUrl;
    notifyListeners();
  }
} 