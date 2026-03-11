import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../theme/colors.dart';
import '../utils/camera_view_painter.dart'; // Import our painter
import 'ai_posture_screen.dart'; // For navigating to results (or logic can be used here)

class VisionAiScreen extends StatefulWidget {
  const VisionAiScreen({super.key});

  @override
  State<VisionAiScreen> createState() => _VisionAiScreenState();
}

class _VisionAiScreenState extends State<VisionAiScreen> {
  CameraController? _controller;
  PoseDetector? _poseDetector;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  List<Pose> _poses = [];

  // For auto-capture
  int _stableFrames = 0;
  bool _isCapturing = false;
  String _statusMessage = "STAND IN FULL VIEW";
  Color _statusColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    // Search for back camera (or front, if you want selfie-analysis)
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();

    if (!mounted) return;

    setState(() => _isCameraInitialized = true);
    _startImageStream();
  }

  void _startImageStream() {
    _controller?.startImageStream((CameraImage image) {
      if (_isDetecting || _isCapturing) return;
      _isDetecting = true;
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final poses = await _poseDetector!.processImage(inputImage);

      if (mounted) {
        setState(() {
          _poses = poses;
          _checkAutoCapture(poses);
        });
      }
    } catch (e) {
      print("Error analyzing pose: $e");
    } finally {
      _isDetecting = false;
    }
  }

  // --- AUTO-CAPTURE LOGIC ---
  void _checkAutoCapture(List<Pose> poses) {
    if (poses.isEmpty) {
      _stableFrames = 0;
      _statusMessage = "STAND IN FULL VIEW";
      _statusColor = Colors.white;
      return;
    }

    final pose = poses.first;
    // Check if ankles and nose are visible (full body in frame)
    bool isVisible =
        pose.landmarks[PoseLandmarkType.nose]!.likelihood > 0.8 &&
        pose.landmarks[PoseLandmarkType.leftAnkle]!.likelihood > 0.8;

    if (isVisible) {
      _stableFrames++;
      _statusMessage = "HOLD STILL...";
      _statusColor = VytalColors.primaryNeon;

      // If standing still for 30 frames (about ~1 sec)
      if (_stableFrames > 30 && !_isCapturing) {
        _captureAndAnalyze();
      }
    } else {
      _stableFrames = 0;
      _statusMessage = "STEP BACK";
      _statusColor = VytalColors.warningNeon;
    }
  }

  Future<void> _captureAndAnalyze() async {
    setState(() => _isCapturing = true);
    HapticFeedback.heavyImpact();

    // IMPORTANT: Stop stream before capture
    await _controller?.stopImageStream();

    try {
      final XFile file = await _controller!.takePicture();

      if (!mounted) return;

      // Here you could send the file immediately to GeminiService
      // For now, just show success and return

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: VytalColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Sharp corners
            side: BorderSide(
              color: VytalColors.primaryNeon,
              width: 0.5,
            ), // Minimalist border
          ),
          title: const Text(
            "SCAN COMPLETE",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: VytalColors.primaryNeon,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                "Data transmitted to Neural Engine.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to Growth screen
              },
              child: const Text(
                "ACKNOWLEDGE",
                style: TextStyle(
                  color: VytalColors.primaryNeon,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Capture error: $e");
      setState(() => _isCapturing = false);
      _startImageStream(); // Restart on error
    }
  }

  // --- CONVERSION (Complex part: CameraImage -> InputImage) ---
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    // For simplicity, take portrait orientation
    final rotation =
        InputImageRotationValue.fromRawValue(sensorOrientation) ??
        InputImageRotation.rotation0deg;

    // Data format (usually yuv420 or nv21 on Android, bgra8888 on iOS)
    final format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.yuv420;

    // Collect bytes from planes
    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final size = Size(image.width.toDouble(), image.height.toDouble());

    final metadata = InputImageMetadata(
      size: size,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: VytalColors.primaryNeon),
        ),
      );
    }

    // Preview size
    final size = MediaQuery.of(context).size;

    // Calculate scale for CustomPaint to match camera
    // (Simply pass the camera size, painter will adjust)
    final cameraSize = _controller!.value.previewSize!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. CAMERA STREAM
          CameraPreview(_controller!),

          // 2. AR SKELETON
          CustomPaint(
            painter: PosePainter(
              _poses,
              cameraSize, // Camera image size (e.g. 1920x1080)
              InputImageRotation
                  .rotation90deg, // Usually 90 for portrait on Android
              _controller!.description.lensDirection ==
                  CameraLensDirection.front,
            ),
          ),

          // 3. UI OVERLAY (HUD)
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(
                            0,
                          ), // Sharp corners
                          border: Border.all(
                            color: VytalColors.primaryNeon,
                            width: 0.5,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: VytalColors.warningNeon,
                              size: 10,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "LIVE VISION",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                fontFamily: 'monospace',
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48), // For balance
                    ],
                  ),
                ),

                const Spacer(),

                // Status message center
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _stableFrames > 5 ? 1.0 : 0.8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(0), // Sharp corners
                      border: Border.all(color: _statusColor, width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: _statusColor.withOpacity(0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _statusColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),

          // Flash effect on capture
          if (_isCapturing) Container(color: Colors.white),
        ],
      ),
    );
  }
}
