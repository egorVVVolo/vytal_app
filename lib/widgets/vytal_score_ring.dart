import 'package:flutter/material.dart';
import '../theme/colors.dart'; // Подключаем наши цвета

class VytalScoreRing extends StatelessWidget {
  final double score; // от 0.0 до 100.0
  final String label; // Например "Recovery" или "Age"

  const VytalScoreRing({
    super.key,
    required this.score,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    // Определяем цвет в зависимости от оценки (как в светофоре)
    Color ringColor = VytalColors.primaryAccent;
    if (score < 50) ringColor = VytalColors.warningAccent;
    if (score >= 80) ringColor = VytalColors.secondaryAccent;

    return Column(
      children: [
        SizedBox(
          height: 180, // Размер круга
          width: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Серый круг (фон трека)
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 12,
                color: VytalColors.textPrimary.withValues(alpha: 0.1),
              ),
              // 2. Цветной круг (прогресс)
              CircularProgressIndicator(
                value: score / 100, // Переводим 85 в 0.85
                strokeWidth: 12,
                color: ringColor,
                strokeCap: StrokeCap.round, // Закругленные края линии
              ),
              // 3. Текст внутри
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    score.toInt().toString(),
                    style: const TextStyle(
                      color: VytalColors.textPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -2,
                    ),
                  ),
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: VytalColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}