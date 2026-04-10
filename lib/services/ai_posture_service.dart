import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiPostureResult {
  final int overallScore;
  final int kyphosisScore;
  final int lordosisScore;
  final int headPostureScore;
  final double lostHeight;
  final String advice;

  AiPostureResult({
    required this.overallScore,
    required this.kyphosisScore,
    required this.lordosisScore,
    required this.headPostureScore,
    required this.lostHeight,
    required this.advice,
  });

  factory AiPostureResult.fromJson(Map<String, dynamic> json) {
    return AiPostureResult(
      overallScore: json['overallScore'] ?? json['overall'] ?? 0,
      kyphosisScore: json['kyphosisScore'] ?? json['kyphosis'] ?? 0,
      lordosisScore: json['lordosisScore'] ?? json['lordosis'] ?? 0,
      headPostureScore: json['neckScore'] ?? json['head_posture'] ?? 0,
      lostHeight: (json['lostHeight'] ?? json['lost_height'] ?? 0.0).toDouble(),
      advice: json['advice'] ?? "No recommendations",
    );
  }
}

class AiPostureService {
  static Future<AiPostureResult?> analyzePosture(
    File sidePhoto,
    File backPhoto,
  ) async {
    try {
      // 1. Get the current user's session token
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        debugPrint("AI API Error: User is not authenticated.");
        return _fallbackResult("Authentication required.");
      }

      // Temporarily mock the response to fix compilation issues.
      // This file is deprecated in favor of a Supabase Edge Function call.
      debugPrint("AI ANALYSIS: Mocked response. Please pull latest changes.");

      final jsonMap = {
        "overall": 80,
        "kyphosis": 85,
        "lordosis": 80,
        "head_posture": 75,
        "lost_height": 0.5,
        "advice": "Maintain good posture."
      };

      return AiPostureResult.fromJson(jsonMap);
    } catch (e) {
      // Network errors, parsing errors, etc.
      debugPrint("AI API Exception: $e");
      return _fallbackResult("Network error. Please check your connection.");
    }
  }

  static AiPostureResult _fallbackResult(String message) {
    return AiPostureResult(
        overallScore: 0,
        kyphosisScore: 0,
        lordosisScore: 0,
        headPostureScore: 0,
        lostHeight: 0.0,
        advice: message,
    );
  }
}
