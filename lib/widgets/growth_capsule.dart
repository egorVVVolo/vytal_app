import 'package:flutter/material.dart';
import '../theme/colors.dart';

class GrowthCapsule extends StatelessWidget {
  final double currentHeight;
  final double potentialHeight;
  final double posturePenalty; // How much height lost due to posture (cm)

  const GrowthCapsule({
    super.key,
    required this.currentHeight,
    required this.potentialHeight,
    this.posturePenalty = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Proportions
    // Scale from 150 cm to (Potential + 5 cm)
    final double minScale = 150.0;
    final double maxScale = potentialHeight + 5.0;
    final double totalRange = maxScale - minScale;

    // Protection from div/0 and going out of bounds
    final double currentPercent = ((currentHeight - minScale) / totalRange)
        .clamp(0.0, 1.0);
    final double potentialPercent = ((potentialHeight - minScale) / totalRange)
        .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VytalColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. VISUAL BAR
          SizedBox(
            width: 70,
            height: 220,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Capsule BG
                Container(
                  decoration: BoxDecoration(
                    color: VytalColors.background,
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.white10, width: 2),
                  ),
                ),

                // Potential Level
                FractionallySizedBox(
                  heightFactor: potentialPercent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: VytalColors.primaryNeon.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                ),

                // Current Height Level
                FractionallySizedBox(
                  heightFactor: currentPercent,
                  child: Container(
                    margin: const EdgeInsets.all(6), // Inner padding
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0038FF), VytalColors.primaryNeon],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: VytalColors.primaryNeon.withValues(alpha: 0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                // Posture Penalty Indicator (Red hyphen)
                Positioned(
                  bottom: (220 * currentPercent) + 2, // Slightly above current
                  child: Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: VytalColors.warningNeon,
                      boxShadow: [
                        BoxShadow(
                          color: VytalColors.warningNeon,
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // 2. TEXT STATS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLabel("CURRENT"),
                _buildValue(
                  currentHeight.toStringAsFixed(1),
                  "cm",
                  Colors.white,
                ),

                const SizedBox(height: 20),

                _buildLabel("GENETIC MAXIMUM"),
                _buildValue(
                  potentialHeight.toStringAsFixed(1),
                  "cm",
                  VytalColors.primaryNeon,
                ),

                const SizedBox(height: 20),

                // Warning Block
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: VytalColors.warningNeon.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: VytalColors.warningNeon.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: VytalColors.warningNeon,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "POSTURE STEALS $posturePenalty CM",
                          style: const TextStyle(
                            color: VytalColors.warningNeon,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: VytalColors.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildValue(String value, String unit, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.0,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
