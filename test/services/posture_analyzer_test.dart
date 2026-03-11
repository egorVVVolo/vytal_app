import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:vytal_app/services/posture_analyzer.dart';
import '../mock_pose_provider.dart';

void main() {
  group('PostureAnalyzer.getAveragePose', () {
    test('returns a Pose with empty landmarks for an empty buffer', () {
      final buffer = <Pose>[];
      final averagePose = PostureAnalyzer.getAveragePose(buffer);

      expect(averagePose.landmarks, isEmpty);
    });

    test('returns a Pose identical to the input for a single pose in the buffer', () {
      final landmark = createMockLandmark(
        type: PoseLandmarkType.rightEar,
        x: 100.0,
        y: 200.0,
        z: 50.0,
        likelihood: 0.9,
      );
      final pose = createMockPose({PoseLandmarkType.rightEar: landmark});
      final buffer = [pose];

      final averagePose = PostureAnalyzer.getAveragePose(buffer);

      expect(averagePose.landmarks.length, 1);
      final averagedLandmark = averagePose.landmarks[PoseLandmarkType.rightEar]!;
      expect(averagedLandmark.x, 100.0);
      expect(averagedLandmark.y, 200.0);
      expect(averagedLandmark.z, 50.0);
      expect(averagedLandmark.likelihood, 0.9);
    });

    test('correctly averages coordinates and likelihood for multiple identical poses', () {
      final landmark = createMockLandmark(
        type: PoseLandmarkType.rightShoulder,
        x: 150.0,
        y: 300.0,
        z: -10.0,
        likelihood: 0.8,
      );
      final pose = createMockPose({PoseLandmarkType.rightShoulder: landmark});
      final buffer = [pose, pose, pose];

      final averagePose = PostureAnalyzer.getAveragePose(buffer);

      final averagedLandmark = averagePose.landmarks[PoseLandmarkType.rightShoulder]!;
      expect(averagedLandmark.x, 150.0);
      expect(averagedLandmark.y, 300.0);
      expect(averagedLandmark.z, -10.0);
      expect(averagedLandmark.likelihood, 0.8);
    });

    test('correctly averages different coordinates and likelihoods', () {
      final landmark1 = createMockLandmark(
        type: PoseLandmarkType.rightHip,
        x: 100.0,
        y: 200.0,
        z: 0.0,
        likelihood: 0.6,
      );
      final landmark2 = createMockLandmark(
        type: PoseLandmarkType.rightHip,
        x: 200.0,
        y: 300.0,
        z: 10.0,
        likelihood: 0.8,
      );

      final buffer = [
        createMockPose({PoseLandmarkType.rightHip: landmark1}),
        createMockPose({PoseLandmarkType.rightHip: landmark2}),
      ];

      final averagePose = PostureAnalyzer.getAveragePose(buffer);

      final averagedLandmark = averagePose.landmarks[PoseLandmarkType.rightHip]!;
      expect(averagedLandmark.x, 150.0);
      expect(averagedLandmark.y, 250.0);
      expect(averagedLandmark.z, 5.0);
      expect(averagedLandmark.likelihood, closeTo(0.7, 0.0001));
    });

    test('averages only the poses that contain a specific landmark', () {
      final ear = createMockLandmark(
        type: PoseLandmarkType.rightEar,
        x: 10.0, y: 10.0, z: 10.0, likelihood: 1.0,
      );
      final shoulder = createMockLandmark(
        type: PoseLandmarkType.rightShoulder,
        x: 20.0, y: 20.0, z: 20.0, likelihood: 0.8,
      );

      // Pose 1 has ear and shoulder
      final pose1 = createMockPose({
        PoseLandmarkType.rightEar: ear,
        PoseLandmarkType.rightShoulder: shoulder,
      });
      // Pose 2 has only shoulder (different coordinates)
      final pose2 = createMockPose({
        PoseLandmarkType.rightShoulder: createMockLandmark(
          type: PoseLandmarkType.rightShoulder,
          x: 40.0, y: 40.0, z: 40.0, likelihood: 0.4,
        ),
      });

      final buffer = [pose1, pose2];

      final averagePose = PostureAnalyzer.getAveragePose(buffer);

      // Ear should be averaged from only 1 pose
      final averagedEar = averagePose.landmarks[PoseLandmarkType.rightEar]!;
      expect(averagedEar.x, 10.0);
      expect(averagedEar.likelihood, 1.0);

      // Shoulder should be averaged from 2 poses
      final averagedShoulder = averagePose.landmarks[PoseLandmarkType.rightShoulder]!;
      expect(averagedShoulder.x, 30.0); // (20 + 40) / 2
      expect(averagedShoulder.likelihood, closeTo(0.6, 0.0001)); // (0.8 + 0.4) / 2
    });
  });
}
