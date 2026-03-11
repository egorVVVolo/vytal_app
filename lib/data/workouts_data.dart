import 'package:flutter/material.dart';

enum ExerciseType { timer, reps }

class Exercise {
  final String title;
  final String subtitle;
  final String description;
  final ExerciseType type;
  final int? durationSeconds;
  final String? visualUrl;

  const Exercise({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    this.durationSeconds,
    this.visualUrl = 'https://via.placeholder.com/400x300.png?text=Exercise+Animation',
  });
}

class Workout {
  final String id;
  final int levelNumber;
  final String title;
  final String subtitle;
  final String totalDurationEst;
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
  static const Color foundationColor = Color(0xFF00E5FF);
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
          description: 'Back pressed against the wall. Elbows slide up and down.',
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
          description: 'Passive dead hang on a pull-up bar. Complete back relaxation.',
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
          description: 'Cobra pose. Pull the crown of your head up, shoulders down.',
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
          description: 'Lying on your stomach, raise your arms forming the letters Y, W, T. Squeeze your shoulder blades.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Plank Scapula Pushups',
          subtitle: '15 reps',
          description: 'In a plank, pinch and spread only your shoulder blades. Keep arms straight.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Wall Sit Posture',
          subtitle: '90 sec',
          description: 'Wall sit with a perfectly straight back and pressed back of the head.',
          type: ExerciseType.timer,
          durationSeconds: 90,
        ),
      ],
    ),
    Workout(
      id: 'f4',
      levelNumber: 4,
      title: 'CORE STABILITY',
      subtitle: 'Building center strength',
      totalDurationEst: '10 min',
      color: foundationColor,
      icon: Icons.foundation_rounded,
      exercises: [
        Exercise(
          title: 'Bird Dog',
          subtitle: '12 reps per side',
          description: 'On all fours, extend opposite arm and leg while keeping torso stable.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Dead Bug',
          subtitle: '15 reps per side',
          description: 'Lying on back, alternate extending opposite arm and leg without arching lower back.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Forearm Plank',
          subtitle: '60 sec hold',
          description: 'Maintain a straight line from head to heels on forearms and toes.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
      ],
    ),
    Workout(
      id: 'f5',
      levelNumber: 5,
      title: 'MOBILITY FLOW',
      subtitle: 'Dynamic joint control',
      totalDurationEst: '15 min',
      color: foundationColor,
      icon: Icons.waves_rounded,
      exercises: [
        Exercise(
          title: 'World\'s Greatest Stretch',
          subtitle: '5 reps per side',
          description: 'Lunge with torso rotation, feeling stretch in hips and mid-back.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: '90/90 Hip Switches',
          subtitle: '10 reps per side',
          description: 'Seated hip internal/external rotation mobility.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Deep Squat Hold',
          subtitle: '60 sec hold',
          description: 'Sit in a deep, active squat, pressing knees out with elbows.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
      ],
    ),
    Workout(
      id: 'f6',
      levelNumber: 6,
      title: 'SPINAL RESILIENCE',
      subtitle: 'Advanced back health',
      totalDurationEst: '14 min',
      color: foundationColor,
      icon: Icons.spa_rounded,
      exercises: [
        Exercise(
          title: 'Jefferson Curls',
          subtitle: '10 slow reps',
          description: 'Slowly articulate the spine downwards with a light weight, then roll back up.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Hollow Body Hold',
          subtitle: '45 sec hold',
          description: 'Lower back pressed into floor, arms and legs extended and lifted.',
          type: ExerciseType.timer,
          durationSeconds: 45,
        ),
        Exercise(
          title: 'Back Extensions',
          subtitle: '15 reps',
          description: 'Lying face down, lift chest and legs off the ground simultaneously.',
          type: ExerciseType.reps,
        ),
      ],
    ),
  ];

  static const Color activationColor = Color(0xFFFF9100);
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
    Workout(
      id: 'a3',
      levelNumber: 3,
      title: 'VO2 MAX PUSH',
      subtitle: 'Cardio capacity limit',
      totalDurationEst: '12 min',
      color: activationColor,
      icon: Icons.air_rounded,
      exercises: [
        Exercise(
          title: 'Jumping Lunge',
          subtitle: '40 sec',
          description: 'Explosive lunge switches.',
          type: ExerciseType.timer,
          durationSeconds: 40,
        ),
        Exercise(
          title: 'Rest',
          subtitle: '20 sec',
          description: 'Catch your breath.',
          type: ExerciseType.timer,
          durationSeconds: 20,
        ),
        Exercise(
          title: 'Skater Jumps',
          subtitle: '40 sec',
          description: 'Lateral bounds side to side.',
          type: ExerciseType.timer,
          durationSeconds: 40,
        ),
        Exercise(
          title: 'Rest',
          subtitle: '20 sec',
          description: 'Catch your breath.',
          type: ExerciseType.timer,
          durationSeconds: 20,
        ),
        Exercise(
          title: 'Tuck Jumps',
          subtitle: '30 sec MAXIMUM',
          description: 'Jump bringing knees to chest.',
          type: ExerciseType.timer,
          durationSeconds: 30,
        ),
      ],
    ),
    Workout(
      id: 'a4',
      levelNumber: 4,
      title: 'LACTATE THRESHOLD',
      subtitle: 'Sustained power output',
      totalDurationEst: '16 min',
      color: activationColor,
      icon: Icons.speed_rounded,
      exercises: [
        Exercise(
          title: 'Kettlebell Swings (or DB)',
          subtitle: '60 sec',
          description: 'Hip hinge explosion, driving the weight up.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
        Exercise(
          title: 'Rest',
          subtitle: '30 sec',
          description: 'Active rest.',
          type: ExerciseType.timer,
          durationSeconds: 30,
        ),
        Exercise(
          title: 'Thrusters',
          subtitle: '60 sec',
          description: 'Front squat into an overhead press.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
        Exercise(
          title: 'Rest',
          subtitle: '30 sec',
          description: 'Active rest.',
          type: ExerciseType.timer,
          durationSeconds: 30,
        ),
        Exercise(
          title: 'Renegade Rows',
          subtitle: '60 sec',
          description: 'Plank position row with dumbbells.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
      ],
    ),
    Workout(
      id: 'a5',
      levelNumber: 5,
      title: 'AEROBIC PEAK',
      subtitle: 'Ultimate endurance test',
      totalDurationEst: '20 min',
      color: activationColor,
      icon: Icons.whatshot_rounded,
      exercises: [
        Exercise(
          title: 'Box Jumps',
          subtitle: '15 reps',
          description: 'Explosive jump onto a box, step down.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Bear Crawls',
          subtitle: '60 sec',
          description: 'Crawl forward and backward keeping hips low.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
        Exercise(
          title: 'Battle Ropes (or fast high knees)',
          subtitle: '45 sec MAXIMUM',
          description: 'Maximum upper or lower body output.',
          type: ExerciseType.timer,
          durationSeconds: 45,
        ),
        Exercise(
          title: 'Rest',
          subtitle: '60 sec',
          description: 'Deep recovery breathing.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
        Exercise(
          title: 'Sprint',
          subtitle: '20 sec MAXIMUM',
          description: 'Final all-out effort.',
          type: ExerciseType.timer,
          durationSeconds: 20,
        ),
      ],
    ),
  ];

  static const Color evolutionColor = Color(0xFFD500F9);
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
          description: 'Jumps only on straight legs using calves. Focus on a hard landing.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Drop Jumps',
          subtitle: '10 reps',
          description: 'Jump down from a small height (step) and instantly jump up.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Farmer Walks',
          subtitle: '60 sec',
          description: 'Walking with heavy dumbbells in hands. Posture is straight.',
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
          description: 'Sprint outside with maximum effort. Impact load on the skeleton.',
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
    Workout(
      id: 'e3',
      levelNumber: 3,
      title: 'TENDON STIFFNESS',
      subtitle: 'Elastic energy storage',
      totalDurationEst: '10 min',
      color: evolutionColor,
      icon: Icons.linear_scale_rounded,
      exercises: [
        Exercise(
          title: 'Extensive Pogo Jumps',
          subtitle: '100 jumps',
          description: 'Continuous stiff-legged hops, prioritizing minimal ground contact time.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Depth Drops',
          subtitle: '5 reps',
          description: 'Step off a box, land softly and hold the absorbing position.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Isometric Calf Raise Hold',
          subtitle: '60 sec',
          description: 'Hold the top position of a calf raise with added weight.',
          type: ExerciseType.timer,
          durationSeconds: 60,
        ),
      ],
    ),
    Workout(
      id: 'e4',
      levelNumber: 4,
      title: 'NEURAL DRIVE',
      subtitle: 'Motor unit recruitment',
      totalDurationEst: '14 min',
      color: evolutionColor,
      icon: Icons.electric_bolt_rounded,
      exercises: [
        Exercise(
          title: 'Broad Jumps',
          subtitle: '10 jumps',
          description: 'Maximal effort jumps for distance. Reset between each jump.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Heavy Sled Push (or Wall Sits)',
          subtitle: '45 sec',
          description: 'Maximum exertion pushing a heavy load, or an intense wall sit.',
          type: ExerciseType.timer,
          durationSeconds: 45,
        ),
        Exercise(
          title: 'Clapping Pushups',
          subtitle: '8 reps',
          description: 'Explosive pushups, getting enough height to clap.',
          type: ExerciseType.reps,
        ),
      ],
    ),
    Workout(
      id: 'e5',
      levelNumber: 5,
      title: 'STRUCTURAL INTEGRITY',
      subtitle: 'Apex skeletal fortification',
      totalDurationEst: '18 min',
      color: evolutionColor,
      icon: Icons.diamond_rounded,
      exercises: [
        Exercise(
          title: 'Max Vertical Jump',
          subtitle: '5 jumps',
          description: 'Absolute maximum effort vertical jump. Full recovery between.',
          type: ExerciseType.reps,
        ),
        Exercise(
          title: 'Heavy Loaded Carries',
          subtitle: '90 sec',
          description: 'Farmer carries or Zercher carries with maximal weight.',
          type: ExerciseType.timer,
          durationSeconds: 90,
        ),
        Exercise(
          title: 'Single Leg Bounds',
          subtitle: '20 bounds (10/leg)',
          description: 'Explosive forward bounds from one leg to the other.',
          type: ExerciseType.reps,
        ),
      ],
    ),
  ];
}
