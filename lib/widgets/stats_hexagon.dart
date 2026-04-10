import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';

class StatsHexagon extends StatelessWidget {
  // Значения от 0 до 100
  final double scoreHeight;
  final double scoreSleep;
  final double scorePosture;
  final double scoreBody;
  final double scoreFocus;
  final double scoreRoutine;

  const StatsHexagon({
    super.key,
    required this.scoreHeight,
    required this.scoreSleep,
    required this.scorePosture,
    required this.scoreBody,
    required this.scoreFocus,
    required this.scoreRoutine,
  });

  @override
  Widget build(BuildContext context) {
    // Данные для отображения (порядок важен - по часовой стрелке)
    final features = [
      "Height", // Top
      "Sleep", // Top-Right
      "Posture", // Bottom-Right
      "Body", // Bottom
      "Focus", // Bottom-Left
      "Routine", // Top-Left
    ];

    final data = [
      scoreHeight,
      scoreSleep,
      scorePosture,
      scoreBody,
      scoreFocus,
      scoreRoutine,
    ];

    return AspectRatio(
      aspectRatio: 1.3,
      child: RadarChart(
        RadarChartData(
          radarTouchData: RadarTouchData(enabled: false),
          tickCount: 5,
          ticksTextStyle: const TextStyle(
            color: Colors.transparent,
          ), // Скрываем цифры шкалы
          gridBorderData: const BorderSide(
            color: VytalColors.textSecondary,
            width: 1,
          ),
          titlePositionPercentageOffset: 0.1, // Отступ текста от графика
          titleTextStyle: const TextStyle(
            color: VytalColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),

          // Определяем подписи осей
          getTitle: (index, angle) {
            return RadarChartTitle(text: features[index]);
          },

          // Сам график (Паутина)
          dataSets: [
            RadarDataSet(
              fillColor: VytalColors.primaryAccent.withValues(alpha: 0.2),
              borderColor: VytalColors.primaryAccent,
              // itemColors удален, так как он устарел.
              // Цвет точек теперь берется из borderColor автоматически.
              borderWidth: 2,
              entryRadius: 3, // Размер точек на углах
              dataEntries: data
                  .map((value) => RadarEntry(value: value))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
