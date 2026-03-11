import 'package:hive/hive.dart';

part 'height_log.g.dart';

@HiveType(typeId: 2) // Уникальный ID для логов роста
class HeightLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double value;

  @HiveField(2)
  final bool isMorning;

  HeightLog({required this.date, required this.value, required this.isMorning});
}