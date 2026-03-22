import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
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

      // Instead of using Pedometer.pedestrianStatusStream directly (which has a bug on Android
      // where it throws unhandled exceptions if the sensor is missing), we implement a safe wrapper.
      _pedestrianStatusStream = _getSafePedestrianStatusStream().handleError((error) {
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

  Stream<PedestrianStatus> _getSafePedestrianStatusStream() {
    // If it's Android, we can just use the EventChannel directly to see if it errors out immediately
    // or we can use stepCountStream's error handler to flag if the sensor is missing,
    // and just not initialize pedestrianStatusStream.
    // However, the cleanest way without losing the feature on real devices is to intercept the EventChannel error.

    // Wait, the EventChannel creates a new stream on receiveBroadcastStream.
    // We can't catch the error in _androidStream's listen because it's inside the plugin.
    // But we CAN provide a wrapper that uses `runZonedGuarded` to catch the unhandled asynchronous exception when listening to the stream!

    StreamController<PedestrianStatus> controller = StreamController<PedestrianStatus>.broadcast();

    runZonedGuarded(() {
      StreamSubscription<PedestrianStatus>? subscription;
      controller.onListen = () {
        try {
          subscription = Pedometer.pedestrianStatusStream.listen(
            (status) => controller.add(status),
            onError: (error) => controller.addError(error),
            cancelOnError: true,
          );
        } catch (e) {
          controller.addError(e);
        }
      };

      controller.onCancel = () {
        subscription?.cancel();
      };
    }, (error, stackTrace) {
      // This catches the unhandled PlatformException thrown by the plugin's _androidStream missing onError!
      controller.addError(error);
    });

    return controller.stream;
  }
}