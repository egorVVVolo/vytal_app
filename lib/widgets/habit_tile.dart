import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../models/habit.dart';
import '../services/storage_service.dart'; // <--- Добавили импорт
import 'glass_container.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const HabitTile({super.key, required this.habit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ПРОВЕРКА НАСТРОЕК ПЕРЕД ВИБРАЦИЕЙ
        if (StorageService.getSetting('haptic')) {
          HapticFeedback.lightImpact();
        }
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 70,
        child: Stack(
          children: [
            GlassContainer(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.zero,
              // Исправлено .withValues для новых версий Flutter, либо .withOpacity для старых
              // Используем withOpacity для надежности, если версия Flutter старая
              color: VytalColors.textPrimary.withValues(alpha: 0.02),
              child: Container(),
            ),

            // Fluid Fill Animation
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                width: habit.isCompleted
                    ? MediaQuery.of(context).size.width
                    : 0,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.greenAccent.withValues(alpha: 0.1),
                      Colors.greenAccent.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: habit.isCompleted
                          ? Colors.greenAccent.withValues(alpha: 0.2)
                          : VytalColors.textPrimary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      boxShadow: const [],
                    ),
                    child: Text(
                      habit.icon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: habit.isCompleted
                                ? VytalColors.textSecondary
                                : VytalColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            decoration: null,
                          ),
                          child: Text(habit.title),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          habit.subtitle,
                          style: const TextStyle(
                            color: VytalColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: habit.isCompleted
                            ? Colors.greenAccent
                            : VytalColors.textSecondary,
                        width: 2,
                      ),
                      color: habit.isCompleted
                          ? Colors.greenAccent
                          : Colors.transparent,
                    ),
                    child: habit.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
