import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CyberpunkGridBackground extends StatefulWidget {
  final Widget child; // Обязательный параметр
  const CyberpunkGridBackground({super.key, required this.child});

  @override
  State<CyberpunkGridBackground> createState() => _CyberpunkGridBackgroundState();
}

class _CyberpunkGridBackgroundState extends State<CyberpunkGridBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Черный фон
        Container(color: VytalColors.background),

        // 2. Анимированная сетка
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _GridPainter(_controller.value),
              );
            },
          ),
        ),

        // 3. Виньетка (затемнение по краям)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  VytalColors.background,
                  VytalColors.background.withValues(alpha: 0.8),
                  Colors.transparent,
                  VytalColors.background.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.15, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // 4. КОНТЕНТ (То, что передаем внутрь)
        widget.child,
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final double animationValue;
  _GridPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VytalColors.primaryNeon.withValues(alpha: 0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final horizonY = size.height * 0.4;

    // Перспектива
    for (double i = -12; i <= 12; i++) {
      final xStart = centerX + (i * 60);
      final xEnd = centerX + (i * 2);
      canvas.drawLine(Offset(xStart, size.height), Offset(xEnd, horizonY), paint);
    }

    // Горизонтальные линии (бегут вперед)
    for (double i = 0; i < 20; i++) {
      final progress = (i + animationValue) / 20;
      final y = size.height - (size.height - horizonY) * (progress * progress);

      if (y > horizonY && y < size.height) {
        paint.color = VytalColors.primaryNeon.withValues(alpha: 0.15 * progress);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => true;
}