import '../theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size sourceSize; // Размер картинки (например 640x480)
  final Size screenSize; // Размер экрана
  final bool isFrontCamera;

  PosePainter(this.poses, this.sourceSize, this.screenSize, this.isFrontCamera);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 6.0
      ..color = Colors.greenAccent;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = VytalColors.textPrimary.withValues(alpha: 0.8);

    for (final pose in poses) {
      // Рисуем связи
      final connections = [
        [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
        [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
        [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
        [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
        [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
        [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
        [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
        [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
        [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
        [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
        [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
        [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
      ];

      for (final pair in connections) {
        _paintLine(pair[0], pair[1], pose, canvas, linePaint);
      }

      // Рисуем точки
      pose.landmarks.forEach((_, lm) {
        // Трансформируем каждую точку
        final offset = _translate(lm.x, lm.y);
        canvas.drawCircle(offset, 4, paint);
      });
    }
  }

  void _paintLine(
    PoseLandmarkType t1,
    PoseLandmarkType t2,
    Pose pose,
    Canvas canvas,
    Paint paint,
  ) {
    final p1 = pose.landmarks[t1];
    final p2 = pose.landmarks[t2];
    if (p1 != null && p2 != null) {
      canvas.drawLine(_translate(p1.x, p1.y), _translate(p2.x, p2.y), paint);
    }
  }

  // ГЛАВНАЯ ФУНКЦИЯ ПЕРЕВОДА КООРДИНАТ
  Offset _translate(double x, double y) {
    // На Android в портретном режиме оси перепутаны местами, так как сенсор landscape.
    // X картинки -> Y экрана
    // Y картинки -> X экрана

    if (!kIsWeb && Platform.isAndroid) {
      // 1. Поворот: меняем X и Y местами
      // 2. Зеркалирование: для фронталки зеркалим "новую X" (которая была Y)

      // Считаем масштаб по "inverted" размерам
      double scaleX = screenSize.width / sourceSize.height;
      double scaleY = screenSize.height / sourceSize.width;

      // Центрируем (BoxFit.cover) - берем scale по большей стороне
      // Но обычно в камере scaleX ≈ scaleY

      double screenX;
      double screenY;

      if (isFrontCamera) {
        // Для фронталки на Android:
        // Y картинки (0..480) превращается в X экрана. Зеркалим его.
        // X картинки (0..640) превращается в Y экрана.
        screenX = screenSize.width - (y * scaleX);
        screenY = x * scaleY;
      } else {
        // Для задней камеры
        screenX = y * scaleX;
        screenY = x * scaleY;
      }

      return Offset(screenX, screenY);
    } else {
      // iOS (там координаты обычно приходят уже "normal" относительно портрета)
      double scaleX = screenSize.width / sourceSize.width;
      double scaleY = screenSize.height / sourceSize.height;

      double screenX = x * scaleX;
      double screenY = y * scaleY;

      if (isFrontCamera) {
        screenX = screenSize.width - screenX;
      }

      return Offset(screenX, screenY);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) => true;
}
