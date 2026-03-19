import 'package:flutter/material.dart';
import 'dart:ui'; // ImageFilter
import '../theme/colors.dart';
import '../data/workouts_data.dart';
import '../widgets/glass_container.dart';
import '../widgets/level_path_view.dart';
import '../services/storage_service.dart';
import 'workout_session_screen.dart';

class TrainingHubScreen extends StatefulWidget {
  const TrainingHubScreen({super.key});

  @override
  State<TrainingHubScreen> createState() => _TrainingHubScreenState();
}

class _TrainingHubScreenState extends State<TrainingHubScreen> {
  int _todayWorkoutCount = 0;
  final int _currentLevelIndex = 0; // In a real app, this should also come from StorageService. For now, defaulting to 0 or mock logic.

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    int count = await StorageService.getTodayWorkoutCount();
    // Assuming we might have a way to get the current unlocked level
    // int currentLevel = await StorageService.getCurrentLevelIndex();

    if (mounted) {
      setState(() {
        _todayWorkoutCount = count;
        // _currentLevelIndex = currentLevel;
        // For demonstration, let's keep it at 0, or we can mock it.
        // Actually, let's just make the first one accessible by default.
      });
    }
  }

  void _onNodeTapped(Workout workout, int index) async {
    if (index > _currentLevelIndex || _todayWorkoutCount >= 3) {
      // Ignored: Node is locked or daily limit reached.
      return;
    }

    // Pass the workout directly to start training
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => WorkoutSessionScreen(workout: workout),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );

    // Refresh after returning (in case a workout was finished)
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: VytalColors.background.withValues(alpha: 0.5)),
          ),
        ),
        title: const Text(
          "KINETIC LAB",
          style: TextStyle(
            color: VytalColors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: VytalColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header showing limits
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                color: _todayWorkoutCount >= 3
                    ? VytalColors.warningNeon.withValues(alpha: 0.1)
                    : VytalColors.textPrimary.withValues(alpha: 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "DAILY LIMIT",
                          style: TextStyle(
                            color: VytalColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$_todayWorkoutCount / 3 COMPLETED",
                          style: TextStyle(
                            color: _todayWorkoutCount >= 3 ? VytalColors.warningNeon : VytalColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _todayWorkoutCount >= 3 ? Icons.lock_clock_rounded : Icons.bolt_rounded,
                      color: _todayWorkoutCount >= 3 ? VytalColors.warningNeon : VytalColors.primaryNeon,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),

            // Level Path View
            Expanded(
              child: LevelPathView(
                workouts: WorkoutsData.allWorkoutsPath,
                todayWorkoutCount: _todayWorkoutCount,
                currentLevelIndex: _currentLevelIndex,
                // The widget only passes Workout. We need index for checking lock.
                // We'll map the workout to index in the callback wrapper.
                onNodeTapped: (Workout w) {
                  int idx = WorkoutsData.allWorkoutsPath.indexOf(w);
                  _onNodeTapped(w, idx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
