import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _user != null;

  /// Lưu session
  Future<void> saveSession(User user, String token) async {
    _user = user;
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    await prefs.setString('token', token);

    notifyListeners();
  }

  /// Load session khi mở app
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = prefs.getString('user');
    final token = prefs.getString('token');

    if (userJson != null && token != null) {
      _user = User.fromMap(jsonDecode(userJson));
      _token = token;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> deleteSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _user = null;
    _token = null;
    notifyListeners();
  }
}
