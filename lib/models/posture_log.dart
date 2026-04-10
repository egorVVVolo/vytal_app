import 'package:hive/hive.dart';

// ВАЖНО: Мы объединили модель и адаптер в один файл для простоты.
// Обычно это делают генератором, но мы напишем руками, чтобы работало сразу.

@HiveType(typeId: 3)
class PostureLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int overallScore;

  @HiveField(2)
  final int kyphosisScore;

  @HiveField(3)
  final int lordosisScore;

  @HiveField(4)
  final int headPostureScore;

  @HiveField(5)
  final double lostHeight;

  @HiveField(6)
  final String advice;

  @HiveField(7)
  final String? backImagePath; // Фото сзади

  @HiveField(8)
  final String? sideImagePath; // Фото сбоку

  PostureLog({
    required this.date,
    required this.overallScore,
    required this.kyphosisScore,
    required this.lordosisScore,
    required this.headPostureScore,
    required this.lostHeight,
    required this.advice,
    this.backImagePath,
    this.sideImagePath,
  });
}

// --- АДАПТЕР (Копируй это тоже сюда же) ---
class PostureLogAdapter extends TypeAdapter<PostureLog> {
  @override
  final int typeId = 3;

  @override
  PostureLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostureLog(
      date: fields[0] as DateTime,
      overallScore: fields[1] as int,
      kyphosisScore: fields[2] as int,
      lordosisScore: fields[3] as int,
      headPostureScore: fields[4] as int,
      lostHeight: fields[5] as double,
      advice: fields[6] as String,
      backImagePath: fields[7] as String?,
      sideImagePath: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PostureLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.overallScore)
      ..writeByte(2)
      ..write(obj.kyphosisScore)
      ..writeByte(3)
      ..write(obj.lordosisScore)
      ..writeByte(4)
      ..write(obj.headPostureScore)
      ..writeByte(5)
      ..write(obj.lostHeight)
      ..writeByte(6)
      ..write(obj.advice)
      ..writeByte(7)
      ..write(obj.backImagePath)
      ..writeByte(8)
      ..write(obj.sideImagePath);
  }
}
