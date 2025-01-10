import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String? _name;
  String? _photoUrl;

  String? get name => _name;
  String? get photoUrl => _photoUrl;

  Future<void> init() async {
    // Başlangıç değerlerini yükle
    _name = '';
    _photoUrl = null;
    notifyListeners();
  }

  String? surname;
  String? profession;

  void updateUserInfo({
    String? name,
    String? surname,
    String? profession,
    String? photoUrl,
  }) {
    this._name = name ?? this._name;
    this.surname = surname ?? this.surname;
    this.profession = profession ?? this.profession;
    this._photoUrl = photoUrl ?? this._photoUrl;
    notifyListeners();
  }

  String get fullName => 
    (name?.isNotEmpty == true || surname?.isNotEmpty == true) 
      ? '${name ?? ''} ${surname ?? ''}'.trim()
      : 'Guest User';
} 