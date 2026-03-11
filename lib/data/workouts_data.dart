import 'package:flutter/material.dart';

enum ExerciseType { timer, reps }

class Exercise {
  final String title;
  final String subtitle; // Например "30 сек" или "20 раз"
  final String description;
  final ExerciseType type;
  // Важно: время в секундах для автоматического таймера (если type == timer)
  final int? durationSeconds;

  const Exercise({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    this.durationSeconds,
  });
}

class Workout {
  final String id;
  final int levelNumber; // Номер уровня в цепочке
  final String title;
  final String subtitle;
  final String totalDurationEst; // Примерное время "10 мин"
  final Color color;
  final IconData icon;
  final List<Exercise> exercises;

  const Workout({
    required this.id,
    required this.levelNumber,
    required this.title,
    required this.subtitle,
    required this.totalDurationEst,
    required this.color,
    required this.icon,
    required this.exercises,
  });
}

class WorkoutsData {
  // === РАЗДЕЛ 1: FOUNDATION (ОСАНКА) ===
  static const Color foundationColor = Color(0xFF00E5FF); // Cyan
  static const List<Workout> foundationLevels = [
    Workout(
      id: 'f1',
      levelNumber: 1,
      title: 'BASIC ALIGNMENT',
      subtitle: 'Introductory correction',
      totalDurationEst: '5 min',
      color: foundationColor,
      icon: Icons.accessibility_new_rounded,
      exercises: [
        Exercise(
          title: 'Wall Angels',
          subtitle: '15 slow reps',
          description:
              'Back pressed against the wall. Elbows slide up and down.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Chin Tucks',
          subtitle: '20 reps',
          description: 'Tucking the chin back. Forming cervical lordosis.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Thoracic Opener',
          subtitle: '60 sec hold',
          description: 'Thoracic extension on a roller or chair.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
      ],
    ),
    Workout(
      id: 'f2',
      levelNumber: 2,
      title: 'DECOMPRESSION PRO',
      subtitle: 'Deep stretch',
      totalDurationEst: '8 min',
      color: foundationColor,
      icon: Icons.vertical_align_top_rounded,
      exercises: [
        Exercise(
          title: 'Dead Hang',
          subtitle: '45 sec hang',
          description:
              'Passive dead hang on a pull-up bar. Complete back relaxation.',
          type: ExerciseType.timer,
          durationSeconds: 45,
        ),
        Exercise(
          title: 'Cat-Cow Stretch',
          subtitle: '60 sec dynamic',
          description: 'Slow arches and rounding of the back on all fours.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
        Exercise(
          title: 'Cobra Pose Hold',
          subtitle: '45 sec static',
          description:
              'Cobra pose. Pull the crown of your head up, shoulders down.',
          type: ExerciseType.timer,
          durationSeconds: 45,
        ),
      ],
    ),
    Workout(
      id: 'f3',
      levelNumber: 3,
      title: 'POSTURE MASTERY',
      subtitle: 'Securing the result',
      totalDurationEst: '12 min',
      color: foundationColor,
      icon: Icons.shield_rounded,
      exercises: [
        Exercise(
          title: 'Y-W-T Raises',
          subtitle: '10 reps each letter',
          description:
              'Lying on your stomach, raise your arms forming the letters Y, W, T. Squeeze your shoulder blades.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Plank Scapula Pushups',
          subtitle: '15 reps',
          description:
              'In a plank, pinch and spread only your shoulder blades. Keep arms straight.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Wall Sit Posture',
          subtitle: '90 sec',
          description:
              'Wall sit with a perfectly straight back and pressed back of the head.',
          type: ExerciseType.timer,
          durationSeconds: 90,
        ),
      ],
    ),
  ];

  // === РАЗДЕЛ 2: ACTIVATION (HGH & HIIT) ===
  static const Color activationColor = Color(0xFFFF9100); // Orange
  static const List<Workout> activationLevels = [
    Workout(
      id: 'a1',
      levelNumber: 1,
      title: 'HGH IGNITION',
      subtitle: 'Lactate stimulation',
      totalDurationEst: '10 min',
      color: activationColor,
      icon: Icons.local_fire_department_rounded,
      exercises: [
        Exercise(
          title: 'Sprint (High Knees)',
          subtitle: '30 sec MAXIMUM',
          description: 'Running in place with high knees. Explosive speed.',
          type: ExerciseType.timer,
          durationSeconds: 30,
        ),
        Exercise(
          title: 'Complete Rest',
          subtitle: '90 sec rest',
          description: 'Stand or walk slowly. Breathe deeply.',
          type: ExerciseType.timer,
          durationSeconds: 90,
        ),
        Exercise(
          title: 'Sprint (High Knees)',
          subtitle: '30 sec MAXIMUM',
          description: 'Second round. Give it your all.',
          type: ExerciseType.timer,
          durationSeconds: 30,
        ),
        Exercise(
          title: 'Complete Rest',
          subtitle: '90 sec rest',
          description: 'Recovery.',
          type: ExerciseType.timer,
          durationSeconds: 90,
        ),
        Exercise(
          title: 'Explosive Squats',
          subtitle: '15 jump squats',
          description: 'Squat and maximum jump up.',
          type: ExerciseType.reps,
        ),
      ],
    ),
    Workout(
      id: 'a2',
      levelNumber: 2,
      title: 'METABOLIC BURN',
      subtitle: 'Fat burning and tone',
      totalDurationEst: '15 min',
      color: activationColor,
      icon: Icons.bolt_rounded,
      exercises: [
        Exercise(
          title: 'Burpees',
          subtitle: '45 sec',
          description: 'Classic burpees at a moderate pace.',
          type: ExerciseType.timer,
          durationSeconds: 45,
        ),
        Exercise(
          title: 'Rest',
          subtitle: '30 sec',
          description: 'Short rest.',
          type: ExerciseType.timer,
          durationSeconds: 30,
        ),
        Exercise(
          title: 'Mountain Climbers',
          subtitle: '45 sec',
          description: 'Running in a push-up position.',
          type: ExerciseType.timer,
          durationSeconds: 45,
        ),
        Exercise(
          title: 'Rest',
          subtitle: '30 sec',
          description: 'Rest.',
          type: ExerciseType.timer,
          durationSeconds: 30,
        ),
        Exercise(
          title: 'Plank to Down Dog',
          subtitle: '60 sec',
          description: 'Transition from plank to downward dog and back.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
      ],
    ),
  ];

  // === РАЗДЕЛ 3: EVOLUTION (WOLF'S LAW) ===
  static const Color evolutionColor = Color(0xFFD500F9); // Purple
  static const List<Workout> evolutionLevels = [
    Workout(
      id: 'e1',
      levelNumber: 1,
      title: 'BONE DENSITY I',
      subtitle: 'Wolff\'s Law: Genesis',
      totalDurationEst: '8 min',
      color: evolutionColor,
      icon: Icons.architecture_rounded,
      exercises: [
        Exercise(
          title: 'Pogo Jumps (Ankle)',
          subtitle: '50 jumps',
          description:
              'Jumps only on straight legs using calves. Focus on a hard landing.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Drop Jumps',
          subtitle: '10 reps',
          description:
              'Jump down from a small height (step) and instantly jump up.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Farmer Walks',
          subtitle: '60 sec',
          description:
              'Walking with heavy dumbbells in hands. Posture is straight.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
      ],
    ),
    Workout(
      id: 'e2',
      levelNumber: 2,
      title: 'BONE DENSITY II',
      subtitle: 'Impact load',
      totalDurationEst: '12 min',
      color: evolutionColor,
      icon: Icons.terrain_rounded,
      exercises: [
        Exercise(
          title: 'Sprinting',
          subtitle: '3 x 60 meters',
          description:
              'Sprint outside with maximum effort. Impact load on the skeleton.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Lateral Bounds',
          subtitle: '20 jumps',
          description: 'Powerful side-to-side jumps (like a speed skater).',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Jump Squats',
          subtitle: '20 reps',
          description: 'Deep squat and high jump.',
          type: ExerciseType.reps,
        ),
      ],
    ),
  ];
}
