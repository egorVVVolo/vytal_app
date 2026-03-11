import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для вибрации
import '../theme/colors.dart';
import '../widgets/glass_container.dart';
import 'onboarding_v2.dart'; // Переход на онбординг после согласия

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  // Состояния галочек
  bool _agreedToTerms = false;
  bool _agreedToMedical = false;
  bool _agreedToAge = false;

  // Все ли отмечено?
  bool get _allAgreed => _agreedToTerms && _agreedToMedical && _agreedToAge;

  void _proceed() {
    if (!_allAgreed) return;
    HapticFeedback.heavyImpact(); // Сильная вибрация подтверждения

    // Переходим к Онбордингу и не даем вернуться назад
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingV2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Заголовок
              const Icon(
                Icons.shield_outlined,
                color: VytalColors.warningNeon,
                size: 40,
              ),
              const SizedBox(height: 20),
              const Text(
                "SYSTEM\nPROTOCOL",
                style: TextStyle(
                  color: VytalColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  height: 1.1,

                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Verify subject status before accessing VYTAL.",
                style: TextStyle(
                  color: VytalColors.textSecondary,
                  fontSize: 14,

                ),
              ),

              const SizedBox(height: 40),

              // Блок соглашений
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCheckbox(
                        value: _agreedToMedical,
                        title: "NOT MEDICAL ADVICE",
                        text:
                            "I understand Vytal is not a medical app. All recommendations are informational. I will consult a doctor before starting training.",
                        onChanged: (v) => setState(() => _agreedToMedical = v),
                      ),
                      const SizedBox(height: 20),
                      _buildCheckbox(
                        value: _agreedToAge,
                        title: "AGE RESTRICTION",
                        text:
                            "I acknowledge that my growth plates may be closed (age 20+), in which case the app will only help with posture, not skeletal growth.",
                        onChanged: (v) => setState(() => _agreedToAge = v),
                      ),
                      const SizedBox(height: 20),
                      _buildCheckbox(
                        value: _agreedToTerms,
                        title: "TERMS OF USE",
                        text:
                            "I accept the Terms of Service and Privacy Policy. I take responsibility for my own health.",
                        onChanged: (v) => setState(() => _agreedToTerms = v),
                      ),
                    ],
                  ),
                ),
              ),

              // Кнопка входа
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _allAgreed ? 1.0 : 0.3,
                child: GestureDetector(
                  onTap: _proceed,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _allAgreed
                          ? VytalColors.textPrimary
                          : Colors.transparent, // Minimalist bg
                      border: Border.all(
                        color: _allAgreed
                            ? VytalColors.primaryNeon
                            : VytalColors.textSecondary,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      "ACCEPT AND ENTER",
                      style: TextStyle(
                        color: _allAgreed
                            ? VytalColors.primaryNeon
                            : VytalColors.textSecondary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,

                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required String title,
    required String text,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        border: Border.all(
          color: value
              ? VytalColors.primaryNeon
              : VytalColors.textPrimary.withValues(alpha: 0.1),
          width: 0.5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Кастомный чекбокс
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? VytalColors.primaryNeon : Colors.transparent,
                border: Border.all(
                  color: value ? VytalColors.primaryNeon : VytalColors.textSecondary,
                  width: 1,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: VytalColors.textPrimary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: value ? VytalColors.primaryNeon : VytalColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 2,

                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: const TextStyle(
                      color: VytalColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,

                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
