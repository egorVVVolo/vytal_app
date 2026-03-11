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
    this.borderRadius = 0, // Minimalist sharp corners default
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // 1. Minimal Blur Layer
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Reduced blur
                child: Container(
                  width: width,
                  height: height,
                  color: Colors.transparent,
                ),
              ),

              // 2. Solid/Minimalist Layer
              Container(
                width: width,
                height: height,
                padding: padding ?? const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border:
                      border ??
                      Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 0.5,
                      ), // Thinner border
                  color: (color ?? Colors.black).withValues(
                    alpha: 0.6,
                  ), // Solid dark transparency instead of gradient
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
