import 'package:flutter/material.dart';

class VytalColors {
  // Core Backgrounds - Sophisticated Minimalist
  static const Color background = Color(0xFFFAFAFA); // Ultra-clean stark white/off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceLight = Color(0xFFF0F0F0); // Subtle contrast surface

  // Elegant Accents
  static const Color primaryAccent = Color(0xFF1C1C1E); // Deep black accent for minimalism
  static const Color secondaryAccent = Color(0xFF8E8E93); // Sophisticated grey
  static const Color warningAccent = Color(0xFFFF3B30); // Soft Red (Keep for semantic errors)
  static const Color tertiaryAccent = Color(0xFF1C1C1E); // Deep black (reusing for minimalist aesthetic)

  // Backwards compatibility for the files we cannot touch
  static const Color primaryNeon = primaryAccent;
  static const Color secondaryNeon = secondaryAccent;
  static const Color warningNeon = warningAccent;
  static const Color purpleNeon = tertiaryAccent;

  // Text
  static const Color textPrimary = Color(0xFF000000); // Pure black for stark contrast
  static const Color textSecondary = Color(0xFF8E8E93); // Medium Gray
}
