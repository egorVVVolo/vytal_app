import 'package:flutter/material.dart';
import 'dart:ui'; // ImageFilter
import '../theme/colors.dart';
import '../data/workouts_data.dart';
import '../services/storage_service.dart';
import '../widgets/level_path_view.dart';
import 'workout_session_screen.dart';

class TrainingHubScreen extends StatefulWidget {
  const TrainingHubScreen({super.key});

  @override
  State<TrainingHubScreen> createState() => _TrainingHubScreenState();
}

class _TrainingHubScreenState extends State<TrainingHubScreen> {
  int _todayWorkoutCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  // Загружаем количество тренировок за сегодня из базы данных
  Future<void> _loadProgress() async {
    final count = await StorageService.getTodayWorkoutCount();
    setState(() {
      _todayWorkoutCount = count;
      _isLoading = false;
    });
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
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: VytalColors.primaryNeon),
      )
          : Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: VytalColors.primaryAccent.withValues(alpha: 0.1),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: Text(
                            "$_todayWorkoutCount/3 COMPLETED PROTOCOLS",
                            style: const TextStyle(
                              color: VytalColors.primaryAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: LevelPathView(
                          // Берем объединенный длинный список из всех категорий
                          workouts: WorkoutsData.allWorkoutsPath,
                          todayWorkoutCount: _todayWorkoutCount,
                          currentLevelIndex: _todayWorkoutCount,
                          onNodeTapped: (workout) async {
                            // Если лимит достигнут, клик не работает
                            if (_todayWorkoutCount >= 3) return;

                            // Открываем экран тренировки и ждем возврата
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (c, a1, a2) => WorkoutSessionScreen(workout: workout),
                                transitionsBuilder: (c, anim, a2, child) =>
                                    FadeTransition(opacity: anim, child: child),
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                            );

                            // После возврата с тренировки обновляем счетчик лимитов
                            _loadProgress();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}