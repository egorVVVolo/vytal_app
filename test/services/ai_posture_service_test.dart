import 'package:flutter_test/flutter_test.dart';
import 'package:vytal_app/services/ai_posture_service.dart';

void main() {
  group('AiPostureResult.fromJson', () {
    test('correctly parses a fully populated JSON map', () {
      final json = {
        'overall': 85,
        'kyphosis': 90,
        'lordosis': 80,
        'head_posture': 75,
        'lost_height': 1.5,
        'advice': 'Strengthen core muscles.',
      };

      final result = AiPostureResult.fromJson(json);

      expect(result.overallScore, 85);
      expect(result.kyphosisScore, 90);
      expect(result.lordosisScore, 80);
      expect(result.headPostureScore, 75);
      expect(result.lostHeight, 1.5);
      expect(result.advice, 'Strengthen core muscles.');
    });

    test('uses fallback values for an empty JSON map', () {
      final json = <String, dynamic>{};

      final result = AiPostureResult.fromJson(json);

      expect(result.overallScore, 0);
      expect(result.kyphosisScore, 0);
      expect(result.lordosisScore, 0);
      expect(result.headPostureScore, 0);
      expect(result.lostHeight, 0.0);
      expect(result.advice, 'No recommendations');
    });

    test(
      'uses fallback values for missing keys in a partially populated JSON map',
      () {
        final json = {
          'overall': 70,
          // 'kyphosis' is missing
          'lordosis': 60,
          // 'head_posture' is missing
          'lost_height': 2.0,
          // 'advice' is missing
        };

        final result = AiPostureResult.fromJson(json);

        expect(result.overallScore, 70);
        expect(result.kyphosisScore, 0); // fallback
        expect(result.lordosisScore, 60);
        expect(result.headPostureScore, 0); // fallback
        expect(result.lostHeight, 2.0);
        expect(result.advice, 'No recommendations'); // fallback
      },
    );

    test('handles lost_height correctly when it is an integer', () {
      final json = {
        'overall': 70,
        'kyphosis': 80,
        'lordosis': 60,
        'head_posture': 50,
        'lost_height': 2, // int instead of double
        'advice': 'Test advice',
      };

      final result = AiPostureResult.fromJson(json);

      expect(result.lostHeight, 2.0); // should be parsed as double
    });
  });
}
