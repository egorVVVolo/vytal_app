import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';

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
      overallScore: json['overall'] ?? 0,
      kyphosisScore: json['kyphosis'] ?? 0,
      lordosisScore: json['lordosis'] ?? 0,
      headPostureScore: json['head_posture'] ?? 0,
      lostHeight: (json['lost_height'] ?? 0.0).toDouble(),
      advice: json['advice'] ?? "No recommendations",
    );
  }
}

class AiPostureService {
  // Ключ VseGPT теперь берем из параметров сборки
  static const String _apiKey = String.fromEnvironment('VSEGPT_API_KEY');

  // Идеальный баланс цены и качества для Vision + JSON
  static const String _modelName = 'openai/gpt-4o-mini';

  static bool _isInitialized = false;

  static void _initApi() {
    if (!_isInitialized) {
      OpenAI.apiKey = _apiKey;
      // Направляем запросы на сервер VseGPT вместо оригинального OpenAI
      OpenAI.baseUrl = "https://api.vsegpt.ru";
      _isInitialized = true;
    }
  }

  static Future<AiPostureResult?> analyzePosture(
      File sidePhoto,
      File backPhoto,
      ) async {
    _initApi();

    try {
      // Конвертируем фото в Base64 для передачи по API
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
        temperature: 0.1, // Низкая температура = строгое соблюдение правил и JSON
        responseFormat: {"type": "json_object"}, // Гарантирует, что вернется JSON
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
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
      String text = chatCompletion.choices.first.message.content?.first.text ?? "";

      // На всякий случай чистим от артефактов маркдауна, если они проскочат
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      debugPrint("AI ANALYSIS: $text");

      final jsonMap = json.decode(text);
      return AiPostureResult.fromJson(jsonMap);

    } catch (e) {
      debugPrint("AI API Error: $e");
      return AiPostureResult(
        overallScore: 0,
        kyphosisScore: 0,
        lordosisScore: 0,
        headPostureScore: 0,
        lostHeight: 0.0,
        advice: "Server error. Try again later.",
      );
    }
  }
}