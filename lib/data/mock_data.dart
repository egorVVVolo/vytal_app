import '../models/habit.dart';

class MockData {
  static final List<Habit> initialHabits = [
    Habit(
      id: '1',
      title: 'Vitamin D3',
      subtitle: '2000 IU after meal',
      type: HabitType.vitamin,
      isCompleted: true,
      icon: '☀️',
    ),
    Habit(
      id: '2',
      title: 'Magnesium Glycinate',
      subtitle: '400 mg before bed',
      type: HabitType.vitamin,
      isCompleted: false,
      icon: '💊',
    ),
    Habit(
      id: '3',
      title: 'Spinal Extension',
      subtitle: '"Cat-Cow" stretch',
      type: HabitType.activity,
      isCompleted: false,
      icon: '🧘',
    ),
  ];
}
