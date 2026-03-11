class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl; // Пока будем использовать заглушку
  final int age;
  final double weight; // кг
  final int height; // см
  final List<String> focusAreas; // "Сон", "Спина" и т.д.

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    required this.age,
    required this.weight,
    required this.height,
    required this.focusAreas,
  });

  // Заготовка данных (Mock) для отображения прямо сейчас
  static const User currentUser = User(
    id: 'u1',
    name: 'Егор Волощук',
    email: 'egor@vytal.app',
    age: 16,
    weight: 72.5,
    height: 182,
    focusAreas: ['Масса', 'Сон', 'Энергия'],
  );
}