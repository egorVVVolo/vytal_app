import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class PedometerService {
  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;

  // Инициализация и запрос прав
  Future<bool> init() async {
    // Запрашиваем разрешение на "Physical activity"
    var status = await Permission.activityRecognition.request();

    if (status.isGranted) {
      // Catch errors directly at the source to prevent unhandled platform exceptions
      _stepCountStream = Pedometer.stepCountStream.handleError((error) {
        debugPrint("🛑 Caught Step Stream Error: $error");
      });

      _pedestrianStatusStream = Pedometer.pedestrianStatusStream.handleError((error) {
        debugPrint("🛑 Caught Status Stream Error: $error");
      });

      return true;
    } else {
      debugPrint("🛑 Pedometer permission denied");
      return false;
    }
  }

  // Поток шагов
  Stream<StepCount>? get stepStream => _stepCountStream;

  // Поток статуса (Идет/Стоит) - для красоты UI
  Stream<PedestrianStatus>? get statusStream => _pedestrianStatusStream;
}