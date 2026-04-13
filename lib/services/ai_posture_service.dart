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
  // Ключ VseGPT теперь берем из параметров сборки
  static const String _apiKey = String.fromEnvironment(
    'VSEGPT_API_KEY',
    defaultValue:
        'sk-or-vv-7370ab2c2f91c3946add4bd5044aa7e485235eef67810f16d4b09d852df3fe8b',
  );

  static Future<AiPostureResult?> analyzePosture(
    File sidePhoto,
    File backPhoto,
  ) async {
    _initApi();

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

      final systemPrompt = """
        You are a strict biomechanical analysis algorithm.
        Analyze two photos (side and back) and output a JSON with metrics.
        
        STRICT RULES:
        1. Do not artificially lower scores. If the back is straight — give 90-100.
        2. If posture is bad, evaluate honestly.
        3. Lost Height: 
           - 0.0 cm, if posture is perfect.
           - 0.5-1.5 cm with a slight neck tilt.
           - 2.0-5.0 cm with severe kyphosis.
        4. Advice: Must be short (max 10 words), technical, and clinical. No greetings.
        
        JSON FORMAT:
        {
          "overall": int,
          "kyphosis": int,
          "lordosis": int,
          "head_posture": int,
          "lost_height": double,
          "advice": "String"
        }
      """;

      final chatCompletion = await OpenAI.instance.chat.create(
        model: _modelName,
        temperature:
            0.1, // Низкая температура = строгое соблюдение правил и JSON
        responseFormat: {
          "type": "json_object",
        }, // Гарантирует, что вернется JSON
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                systemPrompt,
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
                "data:image/jpeg;base64,$sideBase64",
              ),
              OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
                "data:image/jpeg;base64,$backBase64",
              ),
            ],
          ),
        ],
      );

      // Извлекаем текст ответа
      String text =
          chatCompletion.choices.first.message.content?.first.text ?? "";

      // На всякий случай чистим от артефактов маркдауна, если они проскочат
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      debugPrint("AI ANALYSIS: $text");

      final jsonMap = json.decode(text);
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
