import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../data/workouts_data.dart';
import '../services/storage_service.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutSessionScreen({super.key, required this.workout});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isSessionFinished = false;

  // --- ЛОГИКА ТАЙМЕРА ---
  Timer? _exerciseTimer;
  int _timeLeft = 0;
  bool _isTimerRunning = false;
  bool _showSuccessMark = false;

  @override
  void initState() {
    super.initState();
    _initCurrentExercise();
  }

  @override
  void dispose() {
    _exerciseTimer?.cancel();
    super.dispose();
  }

  void _initCurrentExercise() {
    final currentEx = widget.workout.exercises[_currentIndex];
    _showSuccessMark = false;

    if (currentEx.type == ExerciseType.timer &&
        currentEx.durationSeconds != null) {
      _timeLeft = currentEx.durationSeconds!;
      _isTimerRunning = true;
      _startTimer();
    } else {
      _timeLeft = 0;
      _isTimerRunning = false;
    }
  }

  void _startTimer() {
    _exerciseTimer?.cancel();
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _timerFinished();
          }
        });
      }
    });
  }

  Future<void> _timerFinished() async {
    _exerciseTimer?.cancel();
    if (StorageService.getSetting('haptic')) HapticFeedback.heavyImpact();

    if (mounted) {
      setState(() => _showSuccessMark = true);
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) _nextExercise();
  }

  void _nextExercise() {
    if (_currentIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _initCurrentExercise();
    } else {
      _finishSession();
    }
  }

  void _manualFinish() {
    if (StorageService.getSetting('haptic')) HapticFeedback.mediumImpact();
    _nextExercise();
  }

  Future<void> _finishSession() async {
    _exerciseTimer?.cancel();
    setState(() => _isSessionFinished = true);
    await StorageService.incrementTodayWorkoutCount();
    await StorageService.addXP(150);
    if (StorageService.getSetting('haptic')) HapticFeedback.heavyImpact();
  }

  void _quit() {
    _exerciseTimer?.cancel();
    Navigator.pop(context);
  }

  String _formatTime(int totalSeconds) {
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (_isSessionFinished) return _buildFinishScreen();

    final currentEx = widget.workout.exercises[_currentIndex];
    final double progress = (_currentIndex) / widget.workout.exercises.length;
    final Color accent = widget.workout.color;

    return Scaffold(
      backgroundColor: VytalColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER (Фиксированная высота)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: VytalColors.textSecondary),
                    onPressed: _quit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: VytalColors.textSecondary,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "${_currentIndex + 1}/${widget.workout.exercises.length}",
                    style: const TextStyle(
                      color: VytalColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 2. CENTRAL TIMER AREA
            Expanded(
              flex: 2,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                    child: _showSuccessMark
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: VytalColors.secondaryNeon,
                            size: 150,
                            key: const ValueKey('success'),
                          )
                        : _isTimerRunning
                        ? FittedBox(
                            // <-- ВАЖНО: Масштабирует текст, чтобы не было overflow
                            fit: BoxFit.contain,
                            child: Text(
                              _formatTime(_timeLeft),
                              key: ValueKey('timer_$_timeLeft'),
                              style: TextStyle(
                                color: accent,
                                fontSize: 120,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Courier',
                                letterSpacing: -5,
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 100,
                          ), // Плейсхолдер если не таймер
                  ),
                ),
              ),
            ),

            // 2.5. VISUALIZER
            if (currentEx.visualUrl != null)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: VytalColors.textSecondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        currentEx.visualUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, color: VytalColors.textSecondary, size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 3. EXERCISE INFO
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Название (Масштабируется)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currentEx.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: VytalColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Подзаголовок
                    Text(
                      currentEx.subtitle,
                      style: TextStyle(
                        color: accent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Описание в скролле (чтобы не вылезало)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: VytalColors.textPrimary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: VytalColors.textSecondary),
                        ),
                        child: SingleChildScrollView(
                          // <-- ВАЖНО: Скролл для длинного текста
                          child: Text(
                            currentEx.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: VytalColors.textSecondary,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. CONTROL BUTTON (Фиксированное пространство снизу)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 70, // Фиксированная высота кнопки
                child: !_isTimerRunning
                    ? GestureDetector(
                        onTap: _manualFinish,
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                Colors.transparent, // Minimalist transparent bg
                            border: Border.all(color: accent, width: 0.5),
                          ),
                          child: Center(
                            child: Text(
                              "DONE",
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: 2,

                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(), // Если таймер, кнопка скрыта (пустое место той же высоты не обязательно, т.к. колонка растянется)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishScreen() {
    return Scaffold(
      backgroundColor: VytalColors.surface,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [widget.workout.color.withValues(alpha: 0.3), VytalColors.textPrimary],
            radius: 1.5,
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Icon(
              Icons.verified_rounded,
              size: 120,
              color: widget.workout.color,
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 30),
            Text(
              "SESSION\nCOMPLETE",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: VytalColors.textPrimary,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                height: 1.1,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: VytalColors.textPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: VytalColors.secondaryNeon,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "+150 XP",
                    style: TextStyle(
                      color: VytalColors.secondaryNeon,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.all(40),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.transparent, // Minimalist transparent bg
                  foregroundColor: widget.workout.color,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: widget.workout.color, width: 0.5),
                  ),
                ),
                child: const Text(
                  "RETURN TO LAB",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 2,

                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
