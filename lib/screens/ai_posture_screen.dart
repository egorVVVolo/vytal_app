
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart'; // <--- Imprt storage
import '../models/posture_log.dart'; // <--- Import model
import 'posture_history_screen.dart'; // <--- Import history screen

class AiPostureScreen extends StatefulWidget {
  const AiPostureScreen({super.key});

  @override
  State<AiPostureScreen> createState() => _AiPostureScreenState();
}

class _AiPostureScreenState extends State<AiPostureScreen> {
  File? _sidePhoto;
  File? _backPhoto;
  bool _isLoading = false;
  AiPostureResult? _result;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isSide) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF13141B),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: VytalColors.primaryAccent,
              ),
              title: const Text(
                'Camera',
                style: TextStyle(color: VytalColors.textPrimary, ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: VytalColors.secondaryAccent,
              ),
              title: const Text(
                'Gallery',
                style: TextStyle(color: VytalColors.textPrimary, ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (isSide) {
            _sidePhoto = File(image.path);
          } else {
            _backPhoto = File(image.path);
          }
          _result = null;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _analyze() async {
    if (_sidePhoto == null || _backPhoto == null) return;
    setState(() => _isLoading = true);

    // Call API
    final data = await GeminiService.analyzePosture(_sidePhoto!, _backPhoto!);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data != null) _result = data;
      });
    }
  }

  // --- SAVE METHOD ---
  Future<void> _saveResult() async {
    if (_result == null || _backPhoto == null || _sidePhoto == null) return;

    // Create log
    final log = PostureLog(
      date: DateTime.now(),
      overallScore: _result!.overallScore,
      kyphosisScore: _result!.kyphosisScore,
      lordosisScore: _result!.lordosisScore,
      headPostureScore: _result!.headPostureScore,
      lostHeight: _result!.lostHeight,
      advice: _result!.advice,
      backImagePath: _backPhoto!.path,
      sideImagePath: _sidePhoto!.path,
    );

    // Save
    await StorageService.savePostureLog(log);

    // Notify & Navigate
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Result saved to History"),
          backgroundColor: VytalColors.secondaryAccent,
        ),
      );

      // Go to history, replace screen so user cannot hit "save" again by turning back
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PostureHistoryScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios, color: VytalColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "NEURAL SCAN",
          style: TextStyle(

            color: VytalColors.primaryAccent,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // History Button
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history, color: VytalColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PostureHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          SafeArea(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const _LoadingView();
    // SHOW RESULT IF AVAILABLE
    if (_result != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _ResultView(
          result: _result!,
          onRetry: _reset,
          onSave: _saveResult,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "BIOMETRIC UPLOAD",
            style: TextStyle(
              color: VytalColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ).animate().fadeIn().slideY(begin: -0.2),
          const SizedBox(height: 8),
          const Text(
            "Ensure good lighting and contrast background for high AI accuracy.",
            style: TextStyle(color: VytalColors.textSecondary, fontSize: 13, height: 1.5),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: _ScannerSlot(
                  label: "SIDE VIEW",
                  file: _sidePhoto,
                  onTap: () => _pickImage(true),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ScannerSlot(
                  label: "BACK VIEW",
                  file: _backPhoto,
                  onTap: () => _pickImage(false),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
              ),
            ],
          ),

          const SizedBox(height: 50),

          // Start Button
          GestureDetector(
                onTap: (_sidePhoto != null && _backPhoto != null)
                    ? _analyze
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (_sidePhoto != null && _backPhoto != null)
                        ? VytalColors.primaryAccent
                        : VytalColors.textSecondary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: (_sidePhoto != null && _backPhoto != null)
                        ? [
                            BoxShadow(
                              color: VytalColors.primaryAccent.withValues(alpha: 0.6),
                              blurRadius: 20,
                            ),
                          ]
                        : [],
                    border: Border.all(
                      color: (_sidePhoto != null && _backPhoto != null)
                          ? Colors.transparent
                          : VytalColors.textSecondary,
                    ),
                  ),
                  child: Text(
                    "INITIATE SCAN_PROTOCOL",
                    style: TextStyle(

                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: (_sidePhoto != null && _backPhoto != null)
                          ? VytalColors.textPrimary
                          : VytalColors.textSecondary,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms)
              .scale(curve: Curves.easeOutBack, delay: 400.ms),
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      _result = null;
      _sidePhoto = null;
      _backPhoto = null;
    });
  }
}

// --- SCANNER SLOT ---
class _ScannerSlot extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;

  const _ScannerSlot({
    required this.label,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: VytalColors.textSecondary,
              image: file != null
                  ? DecorationImage(
                      image: FileImage(file!),
                      fit: BoxFit.cover,
                      opacity: 0.8,
                    )
                  : null,
            ),
            child: CustomPaint(
              painter: _CornerPainter(isActive: file != null),
              child: file == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: VytalColors.textPrimary.withValues(alpha: 0.3),
                            size: 40,
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: VytalColors.textPrimary.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: VytalColors.secondaryAccent,
                        ),
                      ).animate().scale(curve: Curves.elasticOut),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: VytalColors.primaryAccent,

              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// --- RESULT VIEW ---
class _ResultView extends StatelessWidget {
  final AiPostureResult result;
  final VoidCallback onRetry;
  final VoidCallback onSave;

  const _ResultView({
    required this.result,
    required this.onRetry,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    bool isBad = result.overallScore < 60;
    Color statusColor = isBad
        ? VytalColors.warningAccent
        : VytalColors.secondaryAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Alert Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            border: Border(left: BorderSide(color: statusColor, width: 4)),
          ),
          child: Row(
            children: [
              Icon(
                isBad
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: statusColor,
                size: 28,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBad ? "ANOMALIES DETECTED" : "SYSTEMS NOMINAL",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,

                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Score: ${result.overallScore}/100",
                    style: const TextStyle(
                      color: VytalColors.textPrimary,
                      fontSize: 12,

                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().slideX(begin: -0.2, end: 0, duration: 400.ms),

        const SizedBox(height: 30),

        // 2. Schematic Spine + Stats
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Schematic spine
            Container(
              width: 100,
              height: 250,
              decoration: BoxDecoration(
                color: VytalColors.textPrimary.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VytalColors.textPrimary.withValues(alpha: 0.05)),
              ),
              child: CustomPaint(
                painter: _SpinePainter(score: result.kyphosisScore),
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(width: 20),
            // Metrics
            Expanded(
              child: Column(
                children: [
                  _MetricRow(
                    label: "KYPHOSIS",
                    score: result.kyphosisScore,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),
                  _MetricRow(
                    label: "LORDOSIS",
                    score: result.lordosisScore,
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 16),
                  _MetricRow(
                    label: "NECK POSTURE",
                    score: result.headPostureScore,
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 24),
                  // Lost Height
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: VytalColors.textPrimary,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: VytalColors.textSecondary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "HEIGHT LOST",
                          style: TextStyle(
                            color: VytalColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "-${result.lostHeight} cm",
                          style: const TextStyle(
                            color: VytalColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // 3. Terminal Recommendation
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: VytalColors.textPrimary,
            border: Border.all(color: VytalColors.primaryAccent.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "> AI_PROTOCOL_RECOMMENDATION:",
                style: TextStyle(
                  color: VytalColors.primaryAccent,
                  fontSize: 10,

                ),
              ),
              const SizedBox(height: 10),
              Text(
                result.advice,
                style: const TextStyle(
                  color: VytalColors.textPrimary,
                  height: 1.5,

                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 700.ms),

        const SizedBox(height: 40),

        // 4. Save Button
        GestureDetector(
              onTap: onSave,
              child: Container(
                width: double.infinity,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: VytalColors.primaryAccent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: VytalColors.primaryAccent.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Text(
                  "DUMP TO HISTORY",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,

                    fontSize: 16,
                    color: VytalColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 800.ms)
            .scale(curve: Curves.easeOutBack, delay: 800.ms),

        const SizedBox(height: 16),

        Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: VytalColors.textSecondary),
            label: const Text(
              "PURGE & RETRY",
              style: TextStyle(
                color: VytalColors.textSecondary,

                letterSpacing: 1,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 900.ms),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final int score;

  const _MetricRow({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    Color color = score < 60
        ? VytalColors.warningAccent
        : VytalColors.primaryAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: VytalColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              "$score%",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,

              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: VytalColors.textSecondary,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// --- PAINTERS ---

class _CornerPainter extends CustomPainter {
  final bool isActive;
  _CornerPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? VytalColors.secondaryAccent : VytalColors.primaryAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double len = 20;

    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, 0)
        ..lineTo(len, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, len),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height)
        ..lineTo(len, size.height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - len),
      paint,
    );

    if (!isActive) {
      final gridPaint = Paint()
        ..color = VytalColors.textPrimary.withValues(alpha: 0.05)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(size.width / 2, 20),
        Offset(size.width / 2, size.height - 20),
        gridPaint,
      );
      canvas.drawLine(
        Offset(20, size.height / 2),
        Offset(size.width - 20, size.height / 2),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SpinePainter extends CustomPainter {
  final int score;
  _SpinePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = score < 60 ? VytalColors.warningAccent : VytalColors.secondaryAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width / 2, 20);

    if (score > 80) {
      path.quadraticBezierTo(
        size.width / 2,
        size.height / 2,
        size.width / 2,
        size.height - 20,
      );
    } else {
      path.cubicTo(
        size.width,
        size.height * 0.3,
        0,
        size.height * 0.7,
        size.width / 2,
        size.height - 20,
      );
    }

    canvas.drawPath(path, paint);

    paint.style = PaintingStyle.fill;
    double step = size.height / 8;
    for (int i = 1; i < 8; i++) {
      double xOffset = (score < 60 && (i == 2 || i == 3)) ? 10 : 0;
      canvas.drawCircle(Offset((size.width / 2) + xOffset, i * step), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VytalColors.textPrimary.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    double step = 40;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: VytalColors.primaryAccent),
          const SizedBox(height: 20),
          Text(
            "AI ANALYZING...",
            style: TextStyle(
              color: VytalColors.primaryAccent.withValues(alpha: 0.8),

              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
