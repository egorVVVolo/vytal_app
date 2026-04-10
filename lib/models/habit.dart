import 'package:hive/hive.dart';

// ЭТО ВАЖНО: Эта строка связывает модель с генератором
part 'habit.g.dart';

@HiveType(typeId: 0)
enum HabitType {
  @HiveField(0)
  vitamin,
  @HiveField(1)
  activity,
  @HiveField(2)
  sleep,
  @HiveField(3)
  mental,
}

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subtitle;

  @HiveField(3)
  final HabitType type;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  final String icon;

  Habit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.isCompleted = false,
    required this.icon,
  });

  Habit copyWith({bool? isCompleted}) {
    return Habit(
      id: id,
      title: title,
      subtitle: subtitle,
      type: type,
      isCompleted: isCompleted ?? this.isCompleted,
      icon: icon,
    );
  }
}
