import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui'; // ImageFilter
import '../theme/colors.dart';
import '../data/workouts_data.dart';
import '../widgets/glass_container.dart';
import 'workout_session_screen.dart';

class TrainingHubScreen extends StatefulWidget {
  const TrainingHubScreen({super.key});

  @override
  State<TrainingHubScreen> createState() => _TrainingHubScreenState();
}

class _TrainingHubScreenState extends State<TrainingHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: VytalColors.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: VytalColors.primaryNeon,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: VytalColors.primaryNeon.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              labelColor: VytalColors.textPrimary,
              unselectedLabelColor: VytalColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 2,

              ),
              tabs: const [
                Tab(text: "FOUNDATION"),
                Tab(text: "ACTIVATION"),
                Tab(text: "EVOLUTION"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryPage(
            title: "CORRECTION\n& DECOMPRESSION",
            subtitle: "Base level. Spinal alignment and tension release.",
            color: WorkoutsData.foundationColor,
            icon: Icons.accessibility_new_rounded,
            workouts: WorkoutsData.foundationLevels,
          ),
          _buildCategoryPage(
            title: "HGH & METABOLISM\nACCELERATION",
            subtitle: "HIIT protocols for peak growth hormone release.",
            color: WorkoutsData.activationColor,
            icon: Icons.local_fire_department_rounded,
            workouts: WorkoutsData.activationLevels,
          ),
          _buildCategoryPage(
            title: "WOLFF'S LAW\nFORTIFICATION",
            subtitle: "Impact loading to stimulate bone tissue growth.",
            color: WorkoutsData.evolutionColor,
            icon: Icons.architecture_rounded,
            workouts: WorkoutsData.evolutionLevels,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPage({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required List<Workout> workouts,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 1. VISUAL HEADER (ИСПРАВЛЕНО: УБРАНА ФИКСИРОВАННАЯ ВЫСОТА)
          Container(
            // height: 350, // <--- УБРАЛ ЭТО, ЧТОБЫ НЕ БЫЛО OVERFLOW
            constraints: const BoxConstraints(
              minHeight: 350,
            ), // Минимум 350, но может расти
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withValues(alpha: 0.3), VytalColors.background],
              ),
            ),
            child: SafeArea(
              bottom: false, // Чтобы градиент не обрезался снизу
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  120,
                  24,
                  40,
                ), // Больше отступа снизу
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Используем FittedBox на случай супер-длинных слов, но Text тоже норм переносится
                          Text(
                            title,
                            style: const TextStyle(
                              color: VytalColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: 1,

                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: VytalColors.textSecondary,
                              fontSize: 14,
                              height: 1.5,

                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Иконка справа
                    Icon(icon, size: 70, color: color.withValues(alpha: 0.8))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                          duration: 3.seconds,
                        ),
                  ],
                ),
              ),
            ),
          ),

          // 2. LEVEL PROGRESSION CHAIN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: _LevelChainList(workouts: workouts, color: color),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class _LevelChainList extends StatelessWidget {
  final List<Workout> workouts;
  final Color color;

  const _LevelChainList({required this.workouts, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(workouts.length, (index) {
        final workout = workouts[index];
        final isLast = index == workouts.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Левая часть: Линия и Кружок
              Column(
                children: [
                  GestureDetector(
                    onTap: () => _showWorkoutDetails(context, workout),
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle, // Sharp corners
                        border: Border.all(
                          color: color,
                          width: 0.5,
                        ), // Minimalist thin border
                      ),
                      child: Text(
                        "${workout.levelNumber}",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,

                        ),
                      ),
                    ),
                  ).animate().scale(
                    delay: (index * 100).ms,
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),

                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: color.withValues(alpha: 0.3)),
                    ),
                ],
              ),
              const SizedBox(width: 24),
              // Правая часть: Текст
              Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        onTap: () => _showWorkoutDetails(context, workout),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "LEVEL ${workout.levelNumber}",
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,

                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workout.title,
                              style: const TextStyle(
                                color: VytalColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,

                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workout.totalDurationEst,
                              style: const TextStyle(
                                color: VytalColors.textSecondary,
                                fontSize: 12,

                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (index * 100 + 100).ms)
                  .slideX(begin: 0.2),
            ],
          ),
        );
      }),
    );
  }

  // БЕЗОПАСНОЕ ВСПЛЫВАЮЩЕЕ МЕНЮ
  void _showWorkoutDetails(BuildContext context, Workout workout) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.75,
        child: Container(
          decoration: BoxDecoration(
            color: VytalColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(
              top: BorderSide(color: workout.color.withValues(alpha: 0.5), width: 2),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: VytalColors.textSecondary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Icon(workout.icon, size: 50, color: workout.color),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "LEVEL ${workout.levelNumber}",
                            style: TextStyle(
                              color: workout.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,

                            ),
                          ),
                          Text(
                            workout.title,
                            style: const TextStyle(
                              color: VytalColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,

                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // СПИСОК УПРАЖНЕНИЙ
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: workout.exercises.length,
                  itemBuilder: (context, index) {
                    final ex = workout.exercises[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        color: VytalColors.textPrimary.withValues(alpha: 0.02),
                        child: Row(
                          children: [
                            Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: workout.color,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.title,
                                    style: const TextStyle(
                                      color: VytalColors.textPrimary,
                                      fontWeight: FontWeight.bold,

                                    ),
                                  ),
                                  Text(
                                    ex.subtitle,
                                    style: const TextStyle(
                                      color: VytalColors.textSecondary,
                                      fontSize: 12,

                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              ex.type == ExerciseType.timer
                                  ? Icons.timer_outlined
                                  : Icons.repeat_rounded,
                              color: VytalColors.textSecondary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // КНОПКА
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (c, a1, a2) =>
                                WorkoutSessionScreen(workout: workout),
                            transitionsBuilder: (c, anim, a2, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration: const Duration(
                              milliseconds: 500,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Minimalist
                        foregroundColor: workout.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(color: workout.color, width: 0.5),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text(
                        "START TRAINING",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2,

                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
