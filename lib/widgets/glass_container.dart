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
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // 1. Apple Liquid Glass Blur Layer
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Increased blur for glassmorphism
                child: Container(
                  width: width,
                  height: height,
                  color: Colors.transparent,
                ),
              ),

              // 2. Light Glass Layer
              Container(
                width: width,
                height: height,
                padding: padding ?? const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: border ??
                      Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1,
                      ), // Subtle white border
                  color: color ?? Colors.white.withValues(alpha: 0.5), // Highly transparent white
                  boxShadow: [
                    BoxShadow(
                      color: VytalColors.textPrimary.withValues(alpha: 0.05), // Soft drop shadow
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
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
