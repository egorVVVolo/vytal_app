import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' as p;

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

class GeminiService {
  // Твой ключ (лучше вынести в .env)
  static const String _apiKey =
      'AIzaSyD1ZMAcFTnDeJdR9mtrodGuGxkGcnc3OXI'; // <--- ВЕРНИ СЮДА СВОЙ КЛЮЧ

  // Используем flash для скорости
  static const String _modelName = 'gemini-3-flash-preview';

  static Future<AiPostureResult?> analyzePosture(
    File sidePhoto,
    File backPhoto,
  ) async {
    try {
      final model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        // Temperature 0.1 делает модель максимально "роботизированной" и предсказуемой
        generationConfig: GenerationConfig(
          temperature: 0.3,
          responseMimeType: 'application/json',
        ),
      );

      // НОВЫЙ ПРОМПТ: ОБЪЕКТИВНЫЙ И СТРУКТУРИРОВАННЫЙ
      final prompt = TextPart("""
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
           Example of good advice: "You need to strengthen rhomboids. Winged scapulae observed."
           Example of bad advice: "Hi! Your back looks okay, but could be better..."
        
        JSON FORMAT:
        {
          "overall": int (0-100),
          "kyphosis": int (0-100, where 100 perfectly straight),
          "lordosis": int (0-100, where 100 is normal),
          "head_posture": int (0-100, where 100 is ear over shoulder),
          "lost_height": double (e.g. 1.2),
          "advice": "String"
        }
      """);

      final sideBytes = await sidePhoto.readAsBytes();
      final backBytes = await backPhoto.readAsBytes();

      final imageParts = [
        DataPart('image/jpeg', sideBytes),
        DataPart('image/jpeg', backBytes),
      ];

      final response = await model.generateContent([
        Content.multi([prompt, ...imageParts]),
      ]);

      String text = response.text ?? "";
      // Чистка JSON (на всякий случай, хотя responseMimeType должен помочь)
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      print("GEMINI ANALYSIS: $text"); // Лог для отладки

      final jsonMap = json.decode(text);
      return AiPostureResult.fromJson(jsonMap);
    } catch (e) {
      print("Gemini API Error: $e");
      // Возвращаем дефолтное значение при ошибке, чтобы приложение не падало
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
