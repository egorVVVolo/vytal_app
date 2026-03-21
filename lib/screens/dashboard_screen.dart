import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptics
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'sleep_hgh_screen.dart';
import '../theme/colors.dart';
import '../services/storage_service.dart';
import '../models/habit.dart';
import '../models/posture_log.dart';
import '../data/mock_data.dart';
import '../widgets/glass_container.dart';
import '../services/pedometer_service.dart';
import 'wiki_screen.dart';


class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _name = "User";
  List<Habit> _todayHabits = [];
  int _completedCount = 0;

  int _streak = 0;
  double _growthVelocity = 0.0;

  // Baseline Data
  PostureLog? _baselineLog;
  double _startHeight = 0;
  String _startDateStr = "---";

  int _steps = 0;
  String _motionStatus = "CALIBRATING...";
  final int _stepGoal = 5000;
  late StreamSubscription<StepCount> _stepSubscription;
  late StreamSubscription<PedestrianStatus> _statusSubscription;
  final PedometerService _pedometerService = PedometerService();

  @override
  void initState() {
    super.initState();
    _loadData();
    _initPedometer();
  }

  void _initPedometer() async {
    try {
      bool granted = await _pedometerService.init();
      if (granted) {
        _stepSubscription = _pedometerService.stepStream!.listen(
              (event) {
            if (mounted) {
              setState(() => _steps = event.steps);
              _checkStepGoal(event.steps);
            }
          },
          onError: (error) {
            debugPrint("Step Error: $error");
            if (mounted) setState(() => _motionStatus = "SENSOR UNAVAILABLE");
          },
          cancelOnError: true, // Forces the stream to close on error to prevent crashes
        );

        _statusSubscription = _pedometerService.statusStream!.listen(
              (event) {
            if (mounted) {
              setState(
                    () => _motionStatus = event.status == 'walking'
                    ? "Active"
                    : "IDLE",
              );
            }
          },
          onError: (error) {
            debugPrint("Status Error: $error");
            if (mounted) setState(() => _motionStatus = "SENSOR UNAVAILABLE");
          },
          cancelOnError: true, // Forces the stream to close on error to prevent crashes
        );
      } else {
        if (mounted) setState(() => _motionStatus = "PERMISSION DENIED");
      }
    } catch (e) {
      debugPrint("Pedometer Init Error: $e");
      if (mounted) setState(() => _motionStatus = "SENSOR UNAVAILABLE");
    }
  }

  void _checkStepGoal(int steps) async {
    if (steps >= _stepGoal) {
      final now = DateTime.now();
      bool alreadyShown = await StorageService.isStepGoalShown(now);

      if (!alreadyShown) {
        await StorageService.setStepGoalShown(now);
        await StorageService.addXP(50);

        if (StorageService.getSetting('haptic')) {
          HapticFeedback.heavyImpact();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: VytalColors.secondaryAccent,
              content: Text(
                "STEP GOAL MET: +50 XP",
                style: TextStyle(
                  color: VytalColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadData();
        }
      }
    }
  }

  @override
  void dispose() {
    try {
      _stepSubscription.cancel();
      _statusSubscription.cancel();
    } catch (e) {
      // ignore: empty_catches
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    final savedName = await StorageService.getUserName();
    var allHabits = await StorageService.getHabits();
    if (allHabits.isEmpty) {
      allHabits = MockData.initialHabits;
      await StorageService.saveHabits(allHabits);
    }

    final now = DateTime.now();
    final completedIds = await StorageService.getCompletedHabitIds(now);
    final streak = await StorageService.calculateStreak();
    final velocity = await StorageService.calculateGrowthVelocity();

    // Load Baseline
    final baselineScan = await StorageService.getBaselinePostureLog();
    final heightLogs = await StorageService.getHeightLogs();

    double startH = 175;
    String startD = "---";

    if (heightLogs.isNotEmpty) {
      heightLogs.sort((a, b) => a.date.compareTo(b.date));
      startH = heightLogs.first.value;
      startD =
          "${heightLogs.first.date.month}/${heightLogs.first.date.day}/${heightLogs.first.date.year}";
    }

    final actualHabits = allHabits.map((h) {
      return h.copyWith(isCompleted: completedIds.contains(h.id));
    }).toList();

    if (mounted) {
      setState(() {
        _name = savedName.isNotEmpty ? savedName : widget.userName;
        _todayHabits = actualHabits;
        _completedCount = actualHabits.where((h) => h.isCompleted).length;
        _streak = streak;
        _growthVelocity = velocity;

        _baselineLog = baselineScan;
        _startHeight = startH;
        _startDateStr = startD;
      });
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: VytalColors.surface, // Minimal black
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ), // Sharp edges
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SYSTEM LOG",
              style: TextStyle(
                color: VytalColors.primaryAccent,
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,

              ),
            ),
            const SizedBox(height: 20),
            _notifItem("System Online", "All modules active", "2 min ago"),
            _notifItem(
              "HGH Protocol",
              "Awaiting execution (22:00)",
              "1 hr ago",
            ),
            if (_streak > 3)
              _notifItem(
                "Winning Streak",
                "$_streak days sequence! Good job.",
                "Yesterday",
              ),
          ],
        ),
      ),
    );
  }

  Widget _notifItem(String title, String sub, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: VytalColors.secondaryAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: VytalColors.textPrimary,
                    fontWeight: FontWeight.bold,

                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    color: VytalColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: VytalColors.textSecondary,
              fontSize: 10,

            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalProgress = _todayHabits.isEmpty
        ? 0
        : _completedCount / _todayHabits.length;
    int percentage = (totalProgress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good morning,",
                        style: TextStyle(
                          color: VytalColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Hero(
                        tag: 'userName',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            _name.toUpperCase(),
                            style: const TextStyle(
                              color: VytalColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _showNotifications,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.notifications_none,
                        color: VytalColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

              const SizedBox(height: 32),

              // 2. STREAK + DAILY PROGRESS
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withValues(alpha: 0.05), // Minimalist
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.orangeAccent.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.orangeAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$_streak",
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,

                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              value: totalProgress,
                              color: VytalColors.primaryAccent,
                              backgroundColor: VytalColors.textSecondary,
                              strokeWidth: 2, // Thinner
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Daily Plan",
                                style: TextStyle(
                                  color: VytalColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "$percentage% DONE",
                                style: const TextStyle(
                                  color: VytalColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,

                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. BASELINE WIDGET
              const Text(
                "Growth Metrics",
                style: TextStyle(
                  color: VytalColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,

                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  // Velocity Block
                  Expanded(
                    flex: 3,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Velocity",
                            style: TextStyle(
                              color: VytalColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "+${_growthVelocity.toStringAsFixed(1)}",
                                style: const TextStyle(
                                  color: VytalColors.secondaryAccent,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,

                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6.0, left: 4),
                                child: Text(
                                  "cm/mo",
                                  style: TextStyle(
                                    color: VytalColors.secondaryAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,

                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 20,
                            width: double.infinity,
                            child: CustomPaint(painter: _VelocityWavePainter()),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(width: 12),
                  // Baseline Block
                  Expanded(
                    flex: 2,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Baseline",
                            style: TextStyle(
                              color: VytalColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${_startHeight.toInt()} cm",
                            style: const TextStyle(
                              color: VytalColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,

                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _startDateStr,
                            style: const TextStyle(
                              color: VytalColors.textSecondary,
                              fontSize: 10,

                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _baselineLog != null
                                  ? VytalColors.primaryAccent.withValues(alpha: 0.2)
                                  : VytalColors.textSecondary,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              _baselineLog != null ? "SCAN: OK" : "NO SCAN",
                              style: TextStyle(
                                color: _baselineLog != null
                                    ? VytalColors.primaryAccent
                                    : VytalColors.textSecondary,
                                fontSize: 8,
                                fontWeight: FontWeight.w500,

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),

              const SizedBox(height: 32),

              // 4. SLEEP WIDGET
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SleepHghScreen(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF0038FF,
                    ).withValues(alpha: 0.05), // Minimalist solid
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF0038FF).withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0038FF).withValues(alpha: 0.1),
                          shape: BoxShape.rectangle, // Square corners
                        ),
                        child: const Icon(
                          Icons.bedtime_rounded,
                          color: Color(0xFF00D1FF),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "HGH SLEEP",
                            style: TextStyle(
                              color: VytalColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1,

                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Hormone optimization",
                            style: TextStyle(
                              color: VytalColors.textSecondary,
                              fontSize: 10,

                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: VytalColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ).animate().slideY(delay: 600.ms, begin: 0.2).fadeIn(),
              ),

              const SizedBox(height: 32),

              // 5. MOTION SENSOR
              const Text(
                "Activity",
                style: TextStyle(
                  color: VytalColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,

                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: (_steps / _stepGoal).clamp(0.0, 1.0),
                            backgroundColor: VytalColors.textSecondary,
                            color: _steps >= _stepGoal
                                ? VytalColors.secondaryAccent
                                : VytalColors.primaryAccent,
                            strokeWidth: 2, // Thinner
                          ),
                        ),
                        Icon(
                          _motionStatus.contains("ACTIVE")
                              ? Icons.directions_run
                              : Icons.accessibility_new,
                          color: VytalColors.textPrimary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _motionStatus,
                          style: const TextStyle(
                            color: VytalColors.primaryAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$_steps STEPS",
                          style: const TextStyle(
                            color: VytalColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 32),

              // 6. WIKI
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const WikiScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                child: GlassContainer(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.science_rounded,
                        color: VytalColors.tertiaryAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Knowledge Base",
                        style: TextStyle(
                          color: VytalColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 2,

                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: VytalColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _VelocityWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VytalColors.secondaryAccent.withValues(alpha: 0.6)
      ..strokeWidth =
          1 // Thinner line
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);
    for (double i = 0; i < size.width; i += 5) {
      path.lineTo(i, size.height / 2 + (i % 20 == 0 ? -10 : 10) * 0.4);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
