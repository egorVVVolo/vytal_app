import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptics
import 'package:pedometer/pedometer.dart';
// Удален импорт permission_handler из этого файла, так как он теперь обрабатывается внутри сервиса
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'sleep_hgh_screen.dart';
import '../theme/colors.dart';
import '../services/storage_service.dart';
import '../models/habit.dart';
import '../utils/l10n.dart';
import '../models/posture_log.dart';
import '../data/mock_data.dart';
import '../widgets/glass_container.dart';
import 'wiki_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ВАЖНО: Добавляем импорт правильного сервиса и УДАЛЯЕМ дубликат класса PedometerService
import '../services/pedometer_service.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _name = "User";
  List<Habit> _todayHabits = [];

  int _streak = 0;
  double _growthVelocity = 0.0;

  // Baseline Data
  PostureLog? _baselineLog;
  double _startHeight = 0;
  String _startDateStr = "---";

  int _steps = 0;
  String _motionStatus = L10n.t('calibrating');
  final int _stepGoal = 5000;

  // Делаем подписки nullable, так как на эмуляторе они могут не инициализироваться
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;
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
        // Безопасная проверка и подписка на шаги
        if (_pedometerService.stepStream != null) {
          _stepSubscription = _pedometerService.stepStream!.listen(
            (event) {
              if (mounted) {
                setState(() => _steps = event.steps);
                _checkStepGoal(event.steps);
              }
            },
            onError: (error) {
              debugPrint("Step Error (Sensor missing?): $error");
              if (mounted) {
                setState(() {
                  _motionStatus = "EMULATOR";
                  _steps = 2500; // Mock data for emulator fallback
                });
              }
            },
            cancelOnError: true,
          );
        }

        // Безопасная проверка и подписка на статус
        if (_pedometerService.statusStream != null) {
          _statusSubscription = _pedometerService.statusStream!.listen(
            (event) {
              if (mounted) {
                setState(
                  () => _motionStatus = event.status == 'walking'
                      ? L10n.t('active')
                      : L10n.t('idle'),
                );
              }
            },
            onError: (error) {
              debugPrint("Status Error: $error");
            },
            cancelOnError: true,
          );
        }
      } else {
        // Fallback for missing permissions, emulator, or init failure
        if (mounted) {
          setState(() {
            _motionStatus = "EMULATOR";
            _steps = 2500; // Mock data for emulator fallback
          });
        }
      }
    } catch (e) {
      debugPrint("🛑 Critical Pedometer Error (Emulator?): $e");
      if (mounted) {
        setState(() {
          _motionStatus = "EMULATOR";
          _steps = 2500; // Mock data for emulator fallback
        });
      }
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
    // Безопасная отмена подписок
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
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
      backgroundColor: VytalColors.surface,
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
                        L10n.t('good_morning'),
                        style: TextStyle(
                          color: VytalColors.textSecondary.withValues(
                            alpha: 0.6,
                          ),
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
                  Tooltip(
                    message: 'Notifications',
                    child: GestureDetector(
                      onTap: _showNotifications,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.notifications_none,
                          color: VytalColors.textPrimary,
                        ),
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
                      color: Colors.orangeAccent.withValues(alpha: 0.05),
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
                    child: ValueListenableBuilder(
                      valueListenable: Hive.box('settingsBox').listenable(),
                      builder: (context, box, child) {
                        // Recalculate based on current Hive state
                        final date = DateTime.now();
                        final key =
                            "history_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                        final completedIds = box.get(
                          key,
                          defaultValue: <String>[],
                        );
                        final int completedCount = completedIds.length;
                        final double currentProgress = _todayHabits.isEmpty
                            ? 0
                            : completedCount / _todayHabits.length;
                        final int currentPercentage = (currentProgress * 100)
                            .toInt();

                        return GlassContainer(
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
                                  value: currentProgress,
                                  color: VytalColors.primaryAccent,
                                  backgroundColor: VytalColors.textSecondary,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    L10n.t('daily_plan'),
                                    style: const TextStyle(
                                      color: VytalColors.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "$currentPercentage% ${L10n.t('done')}",
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
                        );
                      },
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. BASELINE WIDGET
              Text(
                L10n.t('growth_metrics'),
                style: const TextStyle(
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
                          Text(
                            L10n.t('velocity'),
                            style: const TextStyle(
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
                          Text(
                            L10n.t('baseline'),
                            style: const TextStyle(
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
                                  ? VytalColors.primaryAccent.withValues(
                                      alpha: 0.2,
                                    )
                                  : VytalColors.textSecondary,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              _baselineLog != null
                                  ? L10n.t('scan_ok')
                                  : L10n.t('no_scan'),
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
              Semantics(
                button: true,
                label: 'Sleep HGH Module',
                child: GestureDetector(
                  onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SleepHghScreen(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0038FF).withValues(alpha: 0.05),
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
                          shape: BoxShape.rectangle,
                        ),
                        child: const Icon(
                          Icons.bedtime_rounded,
                          color: Color(0xFF00D1FF),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.t('hgh_sleep'),
                            style: const TextStyle(
                              color: VytalColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            L10n.t('hormone_optimization'),
                            style: const TextStyle(
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
              ),

              const SizedBox(height: 32),

              // 5. MOTION SENSOR
              Text(
                L10n.t('activity'),
                style: const TextStyle(
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
                            strokeWidth: 2,
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
                          "$_steps ${L10n.t('steps')}",
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
              Semantics(
                button: true,
                label: 'Knowledge Base',
                child: GestureDetector(
                  onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const WikiScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) =>
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
                      Text(
                        L10n.t('knowledge_base'),
                        style: const TextStyle(
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
              ),
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
      ..strokeWidth = 1
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
