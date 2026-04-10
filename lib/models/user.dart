class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl; // Пока будем использовать заглушку
  final int age;
  final double weight; // кг
  final int height; // см
  final List<String> focusAreas; // "Sleep", "Back" и т.д.

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
    name: 'Egor Voloshchuk',
    email: 'egor@vytal.app',
    age: 16,
    weight: 72.5,
    height: 182,
    focusAreas: ['Mass', 'Sleep', 'Energy'],
  );
}
