import 'package:flutter/material.dart';
import 'dart:async'; // Для таймера
import '../theme/colors.dart';

class ScanSimulationScreen extends StatefulWidget {
  const ScanSimulationScreen({super.key});

  @override
  State<ScanSimulationScreen> createState() => _ScanSimulationScreenState();
}

class _ScanSimulationScreenState extends State<ScanSimulationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Simulated analysis process
  String _statusText = "INITIALIZING SENSORS...";
  double _progress = 0.0;

  final List<String> _logs = [
    "CALIBRATING HORIZON...",
    "LOCATING SHOULDER POINTS...",
    "ANALYZING CERVICAL LORDOSIS...",
    "MEASURING PELVIC TILT...",
    "CALCULATING COMPRESSION...",
    "GENERATING REPORT...",
  ];

  @override
  void initState() {
    super.initState();

    // Анимация сканирующей линии (вверх-вниз)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startSimulation();
  }

  void _startSimulation() async {
    // Симулируем работу AI: меняем текст и прогресс каждые 800мс
    for (var log in _logs) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _statusText = log;
        _progress += 1.0 / _logs.length;
      });
    }

    // Завершение
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _showResult();
  }

  void _showResult() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ScanResultSheet(),
    ).then(
      (_) => Navigator.pop(context),
    ); // Когда закроют отчет, выходим из сканера
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. BACKGROUND (Pure black for minimalism)
          Container(
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.person_outline,
                size: 300,
                color: Colors.white10,
              ),
            ),
          ),

          // 2. HUD INTERFACE (Corners)
          CustomPaint(painter: _GridPainter(), child: Container()),

          // 3. SCANNING LINE
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * _animation.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 1, // Thinner line for minimalism
                  decoration: BoxDecoration(
                    color: VytalColors.primaryNeon,
                    boxShadow: [
                      BoxShadow(
                        color: VytalColors.primaryNeon.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 4. TOP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Minimalist REC indicator
                      border: Border.all(color: Colors.red, width: 0.5),
                    ),
                    child: const Text(
                      "REC",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. BOTTOM STATUS BAR
          Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusText.toUpperCase(),
                  style: const TextStyle(
                    color: VytalColors.primaryNeon,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white10,
                  color: VytalColors.primaryNeon,
                  minHeight: 2, // Thinner progress bar
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// HUD CORNERS PAINTER
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VytalColors.primaryNeon.withOpacity(0.2)
      ..strokeWidth = 1;

    // Draw corners
    final double cornerSize = 40;
    final double stroke = 1; // Thinner border for minimalism
    final cornerPaint = Paint()
      ..color = VytalColors.primaryNeon
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;

    // Левый верхний
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerSize)
        ..lineTo(0, 0)
        ..lineTo(cornerSize, 0),
      cornerPaint,
    );
    // Правый верхний
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, cornerSize),
      cornerPaint,
    );
    // Левый нижний
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerSize)
        ..lineTo(0, size.height)
        ..lineTo(cornerSize, size.height),
      cornerPaint,
    );
    // Правый нижний
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - cornerSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// RESULTS REPORT
class _ScanResultSheet extends StatelessWidget {
  const _ScanResultSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: VytalColors.surface, // minimal surface color, likely deep dark
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ), // sharp corners
        border: Border(
          top: BorderSide(color: VytalColors.primaryNeon, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: VytalColors.primaryNeon, size: 40),
          const SizedBox(height: 20),
          const Text(
            "ANALYSIS COMPLETE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Forward head posture (Text Neck) detected. Estimated height loss: 1.2 cm.",
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: VytalColors.background,
                foregroundColor: VytalColors.primaryNeon,
                side: const BorderSide(
                  color: VytalColors.primaryNeon,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ), // Square edges
                elevation: 0,
              ),
              child: const Text(
                "SAVE TO PROFILE",
                style: TextStyle(fontFamily: 'monospace', letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
