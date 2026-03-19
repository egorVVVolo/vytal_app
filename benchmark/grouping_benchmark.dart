// ignore_for_file: unused_local_variable, avoid_print

enum HabitType { vitamin, activity, sleep, mental }

class Habit {
  final String id;
  final HabitType type;
  Habit(this.id, this.type);
}

void main() {
  // Realistic number of habits (e.g., 20)
  final habits = List.generate(20, (i) {
    return Habit(i.toString(), HabitType.values[i % HabitType.values.length]);
  });

  const iterations = 1000000;

  // Baseline
  final stopwatchBaseline = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    final v1 = habits.where((h) => h.type == HabitType.vitamin).toList();
    final v2 = habits.where((h) => h.type == HabitType.activity).toList();
    final v3 = habits.where((h) => h.type == HabitType.mental).toList();
    final v4 = habits.where((h) => h.type == HabitType.sleep).toList();
  }
  stopwatchBaseline.stop();
  final baselineUs = stopwatchBaseline.elapsedMicroseconds / iterations;
  print('Baseline (multiple where): $baselineUs us per iteration');

  // Optimized (Single pass with switch)
  final stopwatchOptimized = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    final v1 = <Habit>[];
    final v2 = <Habit>[];
    final v3 = <Habit>[];
    final v4 = <Habit>[];
    for (final h in habits) {
      switch (h.type) {
        case HabitType.vitamin:
          v1.add(h);
          break;
        case HabitType.activity:
          v2.add(h);
          break;
        case HabitType.mental:
          v3.add(h);
          break;
        case HabitType.sleep:
          v4.add(h);
          break;
      }
    }
  }
  stopwatchOptimized.stop();
  final optimizedUs = stopwatchOptimized.elapsedMicroseconds / iterations;
  print('Optimized (switch): $optimizedUs us per iteration');

  final improvement = (baselineUs - optimizedUs) / baselineUs * 100;
  print('Improvement: ${improvement.toStringAsFixed(2)}%');
}
