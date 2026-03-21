import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';
import '../models/height_log.dart';
import '../models/posture_log.dart';
import 'auth_service.dart';

class StorageService {
  // === КОРОБКИ (HIVE BOXES) ===
  static Box<Habit> get _habitsBox => Hive.box<Habit>('habitsBox');
  static Box get _settingsBox => Hive.box('settingsBox');
  static Box<HeightLog> get _heightBox => Hive.box<HeightLog>('heightBox');
  static Box<PostureLog> get _postureBox => Hive.box<PostureLog>('postureBox');

  // === FIREBASE ===
  static DocumentReference get _userCloudDoc {
    final uid = AuthService.userId;
    if (uid.isEmpty) throw Exception("No User ID");
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  // === СИСТЕМНОЕ ===
  static Future<void> clearAll() async {
    await _habitsBox.clear();
    await _settingsBox.clear();
    await _heightBox.clear();
    await _postureBox.clear();
  }

  static Future<String> getLanguage() async {
    return _settingsBox.get('language', defaultValue: 'en');
  }

  static Future<void> saveLanguage(String lang) async {
    await _settingsBox.put('language', lang);
  }

  static Future<bool> isFirstRun() async {
    return !_settingsBox.containsKey('onboarding_complete');
  }

  static Future<void> completeOnboarding() async {
    await _settingsBox.put('onboarding_complete', true);
    _syncToCloud('settings', {'onboarding_complete': true});
  }

  // === ПРОФИЛЬ ПОЛЬЗОВАТЕЛЯ ===
  static Future<void> saveUserName(String name) async {
    await _settingsBox.put('userName', name);
    _syncToCloud('profile', {'name': name});
  }

  static Future<String> getUserName() async {
    return _settingsBox.get('userName', defaultValue: "User");
  }

  static Future<void> saveGoals(List<String> goals) async {
    await _settingsBox.put('userGoals', goals);
    _syncToCloud('profile', {'goals': goals});
  }

  static Future<List<String>> getGoals() async {
    final goals = _settingsBox.get('userGoals', defaultValue: <String>[]);
    return List<String>.from(goals);
  }

  // === ОПЫТ (XP) ===
  static Future<int> getXP() async {
    return _settingsBox.get('userXP', defaultValue: 0);
  }

  static Future<int> addXP(int amount) async {
    int current = _settingsBox.get('userXP', defaultValue: 0);
    int newVal = (current + amount).clamp(0, 999999);
    await _settingsBox.put('userXP', newVal);
    _syncToCloud('stats', {'xp': newVal});
    return newVal;
  }

  // === ПРИВЫЧКИ (HABITS) ===
  static Future<void> saveHabits(List<Habit> habits) async {
    await _habitsBox.clear();
    await _habitsBox.addAll(habits);

    // Конвертируем привычки в JSON для облака
    final habitsJson = habits.map((h) => {
      'id': h.id,
      'title': h.title,
      'subtitle': h.subtitle,
      'type': h.type.index,
      'icon': h.icon,
      'isCompleted': h.isCompleted
    }).toList();

    _syncToCloud('habits_data', {'list': habitsJson});
  }

  static Future<List<Habit>> getHabits() async {
    return _habitsBox.values.toList();
  }

  // === ИСТОРИЯ ПРИВЫЧЕК (ГАЛОЧКИ) ===
  static String _getDateKey(DateTime date) {
    return "history_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static Future<List<String>> getCompletedHabitIds(DateTime date) async {
    final key = _getDateKey(date);
    final ids = _settingsBox.get(key, defaultValue: <String>[]);
    return List<String>.from(ids);
  }

  static Future<void> toggleHabitCompletion(DateTime date, String habitId) async {
    final key = _getDateKey(date);
    final List<String> currentIds = await getCompletedHabitIds(date);

    if (currentIds.contains(habitId)) {
      currentIds.remove(habitId);
    } else {
      currentIds.add(habitId);
    }

    await _settingsBox.put(key, currentIds);
    _userCloudDoc.collection('history').doc(key).set({'completed': currentIds});
  }

  // === ВОДА (HYDRATION) ===
  static String _getWaterKey(DateTime date) {
    return "water_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static Future<int> getWater(DateTime date) async {
    return _settingsBox.get(_getWaterKey(date), defaultValue: 0);
  }

  static Future<void> addWater(DateTime date, int amount) async {
    final key = _getWaterKey(date);
    int current = _settingsBox.get(key, defaultValue: 0);
    int newVal = current + amount;
    await _settingsBox.put(key, newVal);
    _userCloudDoc.collection('history').doc(key).set({'water': newVal}, SetOptions(merge: true));
  }

  static Future<int> calculateStreak() async {
    int streak = 0;
    DateTime date = DateTime.now();
    final todayIds = await getCompletedHabitIds(date);
    if (todayIds.isEmpty) {
      date = date.subtract(const Duration(days: 1));
    }
    for (int i = 0; i < 365; i++) {
      final ids = await getCompletedHabitIds(date);
      if (ids.isNotEmpty) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // === БИОМЕТРИЯ ===
  static Future<void> saveBiometrics({
    required double weight,
    required double height,
    required int age,
    double? targetHeight,
  }) async {
    await _settingsBox.put('weight', weight);
    await _settingsBox.put('height', height);
    await _settingsBox.put('age', age);
    if (targetHeight != null) {
      await _settingsBox.put('targetHeight', targetHeight);
    }

    _syncToCloud('biometrics', {
      'weight': weight,
      'height': height,
      'age': age,
      'targetHeight': targetHeight ?? 0.0,
    });
  }

  static Future<Map<String, dynamic>> getBiometrics() async {
    return {
      'weight': _settingsBox.get('weight', defaultValue: 70.0),
      'height': _settingsBox.get('height', defaultValue: 175.0),
      'age': _settingsBox.get('age', defaultValue: 18),
      'targetHeight': _settingsBox.get('targetHeight', defaultValue: 180.0),
    };
  }

  // === ЛОГИ РОСТА ===
  static Future<void> addHeightLog(double value, bool isMorning) async {
    final newLog = HeightLog(
      date: DateTime.now(),
      value: value,
      isMorning: isMorning,
    );

    await _heightBox.add(newLog);
    await _settingsBox.put('height', value); // Обновляем текущий рост

    _userCloudDoc.collection('growth_logs').add({
      'date': newLog.date.toIso8601String(),
      'value': value,
      'isMorning': isMorning
    });

    _syncToCloud('biometrics', {'height': value});
  }

  static Future<List<HeightLog>> getHeightLogs() async {
    return _heightBox.values.toList();
  }

  // === ИСТОРИЯ ОСАНКИ ===
  static Future<void> savePostureLog(PostureLog log) async {
    await _postureBox.add(log);

    _syncToCloud('posture_history', {
      'last_scan': {
        'date': log.date.toIso8601String(),
        'score': log.overallScore,
        'lost_height': log.lostHeight,
        'advice': log.advice,
      }
    });

    try {
      final uid = AuthService.userId;
      if (uid.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(uid)
            .collection('posture_logs').add({
          'date': log.date.toIso8601String(),
          'overall': log.overallScore,
          'kyphosis': log.kyphosisScore,
          'lordosis': log.lordosisScore,
          'head': log.headPostureScore,
          'lost_height': log.lostHeight,
        });
      }
    } catch(e) {
      debugPrint("Cloud save error: $e");
    }
  }

  static Future<List<PostureLog>> getPostureHistory() async {
    return _postureBox.values.toList();
  }

  // === PRO СТАТУС ===
  static Future<bool> isProUser() async {
    return _settingsBox.get('isPro', defaultValue: false);
  }

  static Future<void> setProStatus(bool status) async {
    await _settingsBox.put('isPro', status);
  }

  // === ФУНКЦИОНАЛ VYTAL 2.0 ===

  static String _getWorkoutCountKey(DateTime date) {
    return "workouts_count_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}";
  }

  static Future<int> getTodayWorkoutCount() async {
    final key = _getWorkoutCountKey(DateTime.now());
    return _settingsBox.get(key, defaultValue: 0);
  }

  static Future<void> incrementTodayWorkoutCount() async {
    final key = _getWorkoutCountKey(DateTime.now());
    int current = await getTodayWorkoutCount();
    await _settingsBox.put(key, current + 1);
  }

  // 1. Флаг показа цели по шагам
  static String _getStepGoalKey(DateTime date) {
    return "steps_goal_shown_${date.year}_${date.month}_${date.day}";
  }

  static Future<bool> isStepGoalShown(DateTime date) async {
    return _settingsBox.get(_getStepGoalKey(date), defaultValue: false);
  }

  static Future<void> setStepGoalShown(DateTime date) async {
    await _settingsBox.put(_getStepGoalKey(date), true);
  }

  // 2. Расчет скорости роста (Velocity)
  static Future<double> calculateGrowthVelocity() async {
    final logs = _heightBox.values.toList();
    if (logs.length < 2) return 0.0;

    logs.sort((a, b) => a.date.compareTo(b.date));

    final latest = logs.last;
    final pastLog = logs.firstWhere(
          (l) => l.date.isAfter(DateTime.now().subtract(const Duration(days: 60))),
      orElse: () => logs.first,
    );

    if (pastLog == latest) return 0.0;

    final diffCm = latest.value - pastLog.value;
    final diffDays = latest.date.difference(pastLog.date).inDays;

    if (diffDays == 0) return 0.0;

    return (diffCm / diffDays) * 30;
  }

  // 3. Последний лог осанки
  static Future<PostureLog?> getLastPostureLog() async {
    if (_postureBox.isEmpty) return null;
    final logs = _postureBox.values.toList();
    logs.sort((a, b) => a.date.compareTo(b.date));
    return logs.last;
  }

  // 4. Базовый лог осанки
  static Future<PostureLog?> getBaselinePostureLog() async {
    if (_postureBox.isEmpty) return null;
    final logs = _postureBox.values.toList();
    logs.sort((a, b) => a.date.compareTo(b.date));
    return logs.first;
  }

  // === НОВЫЙ ФУНКЦИОНАЛ: НАСТРОЙКИ (REAL SETTINGS) ===

  static bool getSetting(String key, {bool defaultValue = true}) {
    return _settingsBox.get('setting_$key', defaultValue: defaultValue);
  }

  static Future<void> saveSetting(String key, bool value) async {
    await _settingsBox.put('setting_$key', value);
  }

  // === НОВЫЙ ФУНКЦИОНАЛ: УСТРОЙСТВА (MOCK CONNECT) ===

  static bool isDeviceConnected(String deviceId) {
    return _settingsBox.get('device_$deviceId', defaultValue: false);
  }

  static Future<void> toggleDeviceConnection(String deviceId) async {
    bool current = isDeviceConnected(deviceId);
    await _settingsBox.put('device_$deviceId', !current);
  }

  // === ВНУТРЕННЯЯ СИНХРОНИЗАЦИЯ ===
  static Future<void> _syncToCloud(String docId, Map<String, dynamic> data) async {
    try {
      final uid = AuthService.userId;
      if (uid.isEmpty) return;
      await _userCloudDoc.collection('app_data').doc(docId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint("☁️ Cloud Sync Error ($docId): $e");
    }
  }
}