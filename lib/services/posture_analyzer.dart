import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum PostureIssue { forwardHead, kyphosis, lordosis, good }

class PostureReport {
  final List<PostureIssue> issues;
  PostureReport({required this.issues});
}

class PostureAnalyzer {
  // --- МАГИЯ УСРЕДНЕНИЯ ---
  // Берет список последних 10 поз и создает одну "stable"
  static Pose getAveragePose(List<Pose> buffer) {
    if (buffer.isEmpty) return Pose(landmarks: {});

    Map<PoseLandmarkType, PoseLandmark> averagedLandmarks = {};

    // Проходимся по всем возможным точкам тела
    for (var type in PoseLandmarkType.values) {
      double sumX = 0;
      double sumY = 0;
      double sumZ = 0;
      double sumProb = 0;
      int count = 0;

      for (var pose in buffer) {
        final lm = pose.landmarks[type];
        if (lm != null) {
          sumX += lm.x;
          sumY += lm.y;
          sumZ += lm.z;
          sumProb += lm.likelihood;
          count++;
        }
      }

      if (count > 0) {
        averagedLandmarks[type] = PoseLandmark(
          type: type,
          x: sumX / count,
          y: sumY / count,
          z: sumZ / count,
          likelihood: sumProb / count,
        );
      }
    }

    return Pose(landmarks: averagedLandmarks);
  }

  // --- ПРОВЕРКА: СТОИТ ЛИ БОКОМ? ---
  static bool isSideViewDetected(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || rightHip == null)
      return false;

    // Считаем ширину плеч
    double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    // Считаем высоту торса
    double torsoHeight = (rightShoulder.y - rightHip.y).abs();

    // Если ширина плеч больше 40% от высоты тела - значит стоит ПРЯМО (видим оба плеча широко)
    // Нам нужно, чтобы было меньше (стоит боком)
    bool isFacingCamera = shoulderWidth > (torsoHeight * 0.4);

    // Доп. проверка: видим ли ухо и ногу уверенно
    final ear = pose.landmarks[PoseLandmarkType.rightEar];
    final ankle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (ear == null ||
        ankle == null ||
        ear.likelihood < 0.6 ||
        ankle.likelihood < 0.6) {
      return false;
    }

    return !isFacingCamera;
  }

  // --- АНАЛИЗ (ТЕПЕРЬ РАБОТАЕТ С ОДНОЙ СТАБИЛЬНОЙ ПОЗОЙ) ---
  static PostureReport analyze(Pose pose) {
    List<PostureIssue> issues = [];

    final ear = pose.landmarks[PoseLandmarkType.rightEar];
    final shoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final hip = pose.landmarks[PoseLandmarkType.rightHip];
    final ankle = pose.landmarks[PoseLandmarkType.rightAnkle];

    // Если каких-то точек нет - возвращаем пустой отчет (или ошибку)
    if (ear == null || shoulder == null || hip == null || ankle == null) {
      return PostureReport(issues: [PostureIssue.good]);
    }

    // 1. Шея (Ear Forward)
    // Используем относительные координаты
    if ((ear.x - shoulder.x) > 20.0) issues.add(PostureIssue.forwardHead);

    // 2. Сутулость (Shoulder Forward)
    if ((shoulder.x - hip.x) > 15.0) issues.add(PostureIssue.kyphosis);

    // 3. Таз (Swayback)
    if ((hip.x - ankle.x).abs() > 25.0) issues.add(PostureIssue.lordosis);

    if (issues.isEmpty) issues.add(PostureIssue.good);

    return PostureReport(issues: issues);
  }
}
