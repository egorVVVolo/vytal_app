import '../theme/colors.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final Border? border;

  const GlassContainer({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 24, // Soft, rounded corners default
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: VytalColors.textPrimary.withValues(alpha: 0.05), // Soft drop shadow for elevation
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // 1. Shadow Layer (Placed outside the glass effect, usually on a container around the ClipRRect,
              // but we can fake a glow/shadow inside or add it to the parent wrapper.)
              // The shadow doesn't work well *inside* the ClipRRect because it gets clipped.
              // So, we'll draw the glass layer with a subtle gradient and use the border.

              // 2. Apple Liquid Glass Blur Layer
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Whoop style heavy blur
                child: Container(
                  width: width,
                  height: height,
                  color: Colors.transparent,
                ),
              ),

              // 3. Light Glass Layer
              Container(
                width: width,
                height: height,
                padding: padding ?? const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: border ??
                      Border.all(
                        color: Colors.white.withValues(alpha: 0.6), // Pronounced white edge
                        width: 1.5,
                      ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color ?? Colors.white.withValues(alpha: 0.7), // More solid white at top left
                      color?.withValues(alpha: 0.3) ?? Colors.white.withValues(alpha: 0.3), // More transparent at bottom right
                    ],
                  ),
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
