import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  // Base URL of the Supabase instance, expected to be provided via build environment
  // e.g., --dart-define=SUPABASE_URL=https://<PROJECT_REF>.supabase.co
  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ccdfsabkulrqbsiupcyd.supabase.co', // Use the user provided URL as fallback
  );

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
      final accessToken = session.accessToken;

      // 2. Convert photos to Base64
      final sideBytes = await sidePhoto.readAsBytes();
      final backBytes = await backPhoto.readAsBytes();
      final sideBase64 = base64Encode(sideBytes);
      final backBase64 = base64Encode(backBytes);

      // 3. Prepare the request
      final url = Uri.parse('$_supabaseUrl/functions/v1/ai_posture_scan');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      final body = jsonEncode({
        'side_image_base64': sideBase64,
        'back_image_base64': backBase64,
      });

      // 4. Send the POST request to the Edge Function
      final response = await http.post(url, headers: headers, body: body);

      // 5. Handle the response
      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        return AiPostureResult.fromJson(jsonMap);
      } else if (response.statusCode == 429) {
         // Quota exceeded
         debugPrint("AI API Error: Quota exceeded (${response.body})");
         return _fallbackResult("Quota exceeded. Please upgrade to Pro for unlimited scans.");
      } else if (response.statusCode == 401) {
         debugPrint("AI API Error: Unauthorized (${response.body})");
         return _fallbackResult("Unauthorized. Please log in again.");
      } else {
        // Other errors (500, 400, etc.)
        debugPrint("AI API Error: HTTP ${response.statusCode} - ${response.body}");
        return _fallbackResult("Server error. Try again later.");
      }
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