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
        print("✅ LOGGED IN ANONYMOUSLY: $userId");
      } catch (e) {
        print("🛑 AUTH ERROR: $e");
      }
    } else {
      print("ℹ️ ALREADY LOGGED IN: $userId");
    }
  }

  // Выход (для тестов)
  static Future<void> logout() async {
    await _auth.signOut();
  }
}