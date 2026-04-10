import '../theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final bool isFrontCamera;

  PosePainter(
    this.poses,
    this.absoluteImageSize,
    this.rotation,
    this.isFrontCamera,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;

    final paintJoint = Paint()
      ..style = PaintingStyle.fill
      ..color = VytalColors.textPrimary;

    for (final pose in poses) {
      // Рисуем связи (кости)
      void paintLine(PoseLandmarkType type1, PoseLandmarkType type2) {
        final joint1 = pose.landmarks[type1];
        final joint2 = pose.landmarks[type2];
        if (joint1 == null || joint2 == null) return;

        // Трансформация координат
        final p1 = _translatePoint(
          joint1.x,
          joint1.y,
          size,
          absoluteImageSize,
          rotation,
          isFrontCamera,
        );
        final p2 = _translatePoint(
          joint2.x,
          joint2.y,
          size,
          absoluteImageSize,
          rotation,
          isFrontCamera,
        );

        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, paint);
        }
      }

      // Отрисовка основных линий тела
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);

      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);

      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);

      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

      // Рисуем суставы (точки)
      for (final landmark in pose.landmarks.values) {
        final point = _translatePoint(
          landmark.x,
          landmark.y,
          size,
          absoluteImageSize,
          rotation,
          isFrontCamera,
        );
        if (point != null) {
          canvas.drawCircle(point, 4, paintJoint);
        }
      }
    }
  }

  // --- МАТЕМАТИКА ТРАНСФОРМАЦИИ КООРДИНАТ ---
  Offset? _translatePoint(
    double x,
    double y,
    Size screenSize,
    Size imageSize,
    InputImageRotation rotation,
    bool isFront,
  ) {
    // В вертикальном режиме (Portrait) оси меняются местами для камеры
    double imageW = imageSize.width;
    double imageH = imageSize.height;

    // Определяем масштаб
    double scaleX = screenSize.width / imageW;
    double scaleY = screenSize.height / imageH;

    // Если камера повернута (обычно на 90 или 270 градусов в портрете)
    if (rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg) {
      imageW = imageSize.height;
      imageH = imageSize.width;
      scaleX = screenSize.width / imageW;
      scaleY = screenSize.height / imageH;
    }

    // Растягиваем по большей стороне (BoxFit.cover)
    // double scale = scaleX > scaleY ? scaleX : scaleY; // Если нужно cover

    // Но для точности нам нужно просто мапить
    double finalX = x * scaleX;
    double finalY = y * scaleY;

    if (rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg) {
      // X и Y меняются местами в исходных данных ML Kit при повороте
      finalX =
          x * scaleX; // Тут надо быть осторожным, часто x это на самом деле y.
      // Для упрощения: в Flutter Camera плагин + ML Kit:
      // x - это горизонталь на картинке. Если картинка повернута, x становится y экрана.

      // Давай используем проверенную формулу для портрета:
      return Offset(
        isFront ? screenSize.width - (x * scaleX) : x * scaleX,
        y * scaleY,
      );
    }

    return Offset(isFront ? screenSize.width - finalX : finalX, finalY);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) => true;
}
