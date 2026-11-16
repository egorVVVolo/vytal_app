import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// Helper classes to instantiate Pose and PoseLandmark for testing.
// In practice, if we cannot instantiate them directly, we'd use a mock library or provide a factory.
// Assuming Pose and PoseLandmark have public constructors based on typical ML Kit plugin structure.

Pose createMockPose(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  return Pose(landmarks: landmarks);
}

PoseLandmark createMockLandmark({
  required PoseLandmarkType type,
  required double x,
  required double y,
  required double z,
  required double likelihood,
}) {
  return PoseLandmark(type: type, x: x, y: y, z: z, likelihood: likelihood);
}
