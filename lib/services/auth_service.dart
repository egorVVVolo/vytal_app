import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Текущий пользователь
  static User? get currentUser => _auth.currentUser;

  // Уникальный ID пользователя (или пустая строка, если не вошел)
  static String get userId => _auth.currentUser?.uid ?? '';

  // Тихий вход при запуске
  static Future<void> loginSilently() async {
    if (currentUser == null) {
      try {
        await _auth.signInAnonymously();
        debugPrint("✅ LOGGED IN ANONYMOUSLY: $userId");
      } catch (e) {
        debugPrint("🛑 AUTH ERROR: $e");
      }
    } else {
      debugPrint("ℹ️ ALREADY LOGGED IN: $userId");
    }
  }

  // Выход (для тестов)
  static Future<void> logout() async {
    await _auth.signOut();
  }
}