import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String? name;
  String? surname;
  String? profession;
  String? photoUrl;

  void updateUserInfo({
    String? name,
    String? surname,
    String? profession,
    String? photoUrl,
  }) {
    this.name = name ?? this.name;
    this.surname = surname ?? this.surname;
    this.profession = profession ?? this.profession;
    this.photoUrl = photoUrl ?? this.photoUrl;
    notifyListeners();
  }

  String get fullName => 
    (name?.isNotEmpty == true || surname?.isNotEmpty == true) 
      ? '${name ?? ''} ${surname ?? ''}'.trim()
      : 'Guest User';
} 