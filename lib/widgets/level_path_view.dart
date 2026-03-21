import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/workouts_data.dart';

class LevelPathView extends StatefulWidget {
  final List<Workout> workouts;
  final int todayWorkoutCount;
  final Function(Workout) onNodeTapped;
  final int currentLevelIndex; // Add this to track the user's progress

  const LevelPathView({
    super.key,
    required this.workouts,
    required this.todayWorkoutCount,
    required this.onNodeTapped,
    this.currentLevelIndex = 0, // Default to 0 if not provided
  });

  @override
  State<LevelPathView> createState() => _LevelPathViewState();
}

class _LevelPathViewState extends State<LevelPathView> {
  // Pattern of offsets for the winding path
  final List<double> _offsets = [0.0, 0.5, 0.8, 0.5, 0.0, -0.5, -0.8, -0.5];
  final double _itemHeight = 150.0; // Increased to give more room for the line

  @override
  Widget build(BuildContext context) {
    if (widget.workouts.isEmpty) {
      return const Center(child: Text('No workouts available'));
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: widget.workouts.length,
      itemBuilder: (context, index) {
        return SizedBox(
          height: _itemHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Draw the connecting line segment first (behind the node)
              Positioned.fill(
                child: CustomPaint(
                  painter: _LineSegmentPainter(
                    index: index,
                    totalItems: widget.workouts.length,
                    offsets: _offsets,
                    color: widget.workouts.first.color.withValues(alpha: 0.3),
                  ),
                ),
              ),
              // The Node itself
              Align(
                alignment: Alignment(_offsets[index % _offsets.length], 0),
                child: _buildNode(context, widget.workouts[index], index),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNode(BuildContext context, Workout workout, int index) {
    bool isCompleted = index < widget.currentLevelIndex;
    bool isCurrent = index == widget.currentLevelIndex;
    bool isLocked = index > widget.currentLevelIndex || widget.todayWorkoutCount >= 3;

    // If todayWorkoutCount >= 3, even the current becomes locked (limit reached)
    if (widget.todayWorkoutCount >= 3 && isCurrent) {
      isCurrent = false;
      isLocked = true;
    }

    // Determine colors
    Color baseColor = workout.color;
    Color glowColor = baseColor.withValues(alpha: 0.6);
    IconData iconData = workout.icon;

    if (isCompleted) {
      iconData = Icons.check_rounded;
    } else if (isLocked) {
      baseColor = Colors.grey.shade600;
      glowColor = Colors.transparent;
      iconData = Icons.lock_rounded;
    }

    Widget nodeContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: baseColor,
            boxShadow: [
              if (!isLocked)
                BoxShadow(
                  color: glowColor,
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: isLocked ? 0.1 : 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    color: isLocked ? Colors.white54 : Colors.white,
                    size: 32,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isLocked ? Colors.white54 : Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          workout.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isLocked ? Colors.grey : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    // Add interactivity and appearance animations
    // Since it's in a ListView.builder, it builds as it scrolls.
    // We animate it entering the screen.
    Widget animatedNode = GestureDetector(
      onTap: isLocked ? null : () => widget.onNodeTapped(workout),
      child: nodeContent,
    )
    .animate()
    .fade(duration: 500.ms, curve: Curves.easeOut)
    .slideY(begin: 0.5, end: 0, duration: 500.ms, curve: Curves.easeOut);

    if (isCurrent) {
      // Pulsing animation for current available node
      animatedNode = animatedNode
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 1000.ms, curve: Curves.easeInOut)
          .shimmer(duration: 2000.ms, color: Colors.white24);
    }

    return animatedNode;
  }
}

class _LineSegmentPainter extends CustomPainter {
  final int index;
  final int totalItems;
  final List<double> offsets;
  final Color color;

  _LineSegmentPainter({
    required this.index,
    required this.totalItems,
    required this.offsets,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5); // Glow effect for the line

    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double centerX = size.width / 2;
    double childWidth = 80.0;

    // Current node center
    double currentAlignX = offsets[index % offsets.length];
    double currentX = centerX + currentAlignX * ((size.width - childWidth) / 2);
    double currentY = size.height / 2;

    // 1. Draw from top (previous node) to current node
    if (index > 0) {
      double prevAlignX = offsets[(index - 1) % offsets.length];
      double prevX = centerX + prevAlignX * ((size.width - childWidth) / 2);

      // The shared coordinate at the item boundary (y = 0)
      double midXTop = (prevX + currentX) / 2;

      path.moveTo(midXTop, 0);

      // Control points for the bottom half of the S-curve (from y=0 to currentY)
      // We want the curve to start vertically at midXTop and end vertically at currentX
      path.cubicTo(midXTop, currentY * 0.5, currentX, currentY * 0.5, currentX, currentY);
    } else {
      path.moveTo(currentX, currentY);
    }

    // 2. Draw from current node to bottom (next node)
    if (index < totalItems - 1) {
      double nextAlignX = offsets[(index + 1) % offsets.length];
      double nextX = centerX + nextAlignX * ((size.width - childWidth) / 2);

      // The shared coordinate at the item boundary (y = size.height)
      double midXBottom = (currentX + nextX) / 2;

      // The path is already at (currentX, currentY)
      // Control points for the top half of the S-curve (from currentY to y=size.height)
      // We want the curve to start vertically at currentX and end vertically at midXBottom
      double controlY1 = currentY + (size.height - currentY) * 0.5;
      double controlY2 = currentY + (size.height - currentY) * 0.5;

      path.cubicTo(currentX, controlY1, midXBottom, controlY2, midXBottom, size.height);
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, corePaint);
  }

  @override
  bool shouldRepaint(covariant _LineSegmentPainter oldDelegate) {
    return oldDelegate.index != index ||
           oldDelegate.totalItems != totalItems ||
           oldDelegate.color != color;
  }
}
