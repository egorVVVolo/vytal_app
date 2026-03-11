import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/colors.dart';
import 'main_shell.dart';
import '../services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  String _name = "";
  final List<String> _selectedGoals = [];

  // Улучшенная функция перехода
  void _nextPage() {
    // 1. Скрываем клавиатуру ПЕРЕД анимацией, чтобы не было лагов
    FocusScope.of(context).unfocus();

    // 2. Делаем анимацию чуть быстрее (400ms), чтобы она чувствовалась "skillful"
    _controller.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut, // Более плавная и стандартная кривая
    );
  }

  Future<void> _finish() async {
    // 1. Сохраняем имя
    await StorageService.saveUserName(_name.isEmpty ? "User" : _name);

    // 2. Сохраняем цели
    await StorageService.saveGoals(_selectedGoals);

    // 3. Ставим метку, что онбординг пройден
    await StorageService.completeOnboarding();

    if (!mounted) return; // Проверка, что экран еще существует

    // 4. Переходим
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainShell(
          userName: _name.isEmpty ? "User" : _name,
          userGoals: _selectedGoals,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      // resizeToAvoidBottomInset: false, // Можно раскомментировать, если фон "jumps" при открытии клавиатуры
      body: Stack(
        children: [
          // Фоновые эффекты
          Positioned(
            top: -100, left: -50,
            child: _buildGlowOrb(VytalColors.primaryNeon),
          ),
          Positioned(
            bottom: -100, right: -50,
            child: _buildGlowOrb(const Color(0xFF0055FF)),
          ),

          // Контент
          PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStepWrapper(_buildWelcomeContent()),
              _buildStepWrapper(_buildNameContent()),
              _buildStepWrapper(_buildGoalsContent()),
            ],
          ),
        ],
      ),
    );
  }

  // Обертка для защиты от Overflow (теперь контент можно скроллить, если места мало)
  Widget _buildStepWrapper(Widget content) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          // ConstrainedBox заставляет контент растягиваться на весь экран,
          // если места достаточно, но позволяет скроллить, если места мало.
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 64), // -64 это padding
            child: IntrinsicHeight(child: content),
          ),
        );
      },
    );
  }

  // --- КОНТЕНТ ШАГОВ (Вынесен отдельно для чистоты) ---

  Widget _buildWelcomeContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Text(
          "VYTAL",
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 12, color: VytalColors.textPrimary),
        ),
        const SizedBox(height: 24),
        const Text(
          "Your genetic maximum.\nUnlocked.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: VytalColors.textSecondary, height: 1.5),
        ),
        const Spacer(),
        _buildPrimaryButton("START JOURNEY", _nextPage),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNameContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Text("Identification", style: TextStyle(color: VytalColors.primaryNeon, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text("How should we address you?", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: VytalColors.textPrimary, height: 1.2)),
        const SizedBox(height: 40),
        TextField(
          autofocus: true,
          onChanged: (val) => _name = val,
          style: const TextStyle(fontSize: 24, color: VytalColors.textPrimary),
          decoration: InputDecoration(
            hintText: "Enter name...",
            hintStyle: TextStyle(color: VytalColors.textPrimary.withValues(alpha: 0.3)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: VytalColors.textSecondary)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: VytalColors.primaryNeon)),
          ),
          // При нажатии Enter на клавиатуре тоже переходим дальше
          onSubmitted: (_) {
            if (_name.isNotEmpty) _nextPage();
          },
        ),
        const Spacer(),
        _buildPrimaryButton("CONTINUE", () {
          if (_name.isNotEmpty) _nextPage();
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGoalsContent() {
    final goals = ["Height Maximization", "Posture Correction", "Sleep Quality", "Focus & Dopamine"];

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text("Priorities", style: TextStyle(color: VytalColors.primaryNeon, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Choose your focus for the next month", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: VytalColors.textPrimary)),
            const SizedBox(height: 40),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: goals.map((goal) {
                final isSelected = _selectedGoals.contains(goal);
                return FilterChip( // Используем FilterChip вместо ChoiceChip для лучшей анимации
                  label: Text(goal),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selected ? _selectedGoals.add(goal) : _selectedGoals.remove(goal);
                    });
                  },
                  backgroundColor: VytalColors.surface,
                  selectedColor: VytalColors.primaryNeon,
                  labelStyle: TextStyle(color: isSelected ? VytalColors.textPrimary : VytalColors.textPrimary, fontWeight: FontWeight.bold),
                  checkmarkColor: VytalColors.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide.none),
                );
              }).toList(),
            ),

            const Spacer(),
            _buildPrimaryButton("START SYSTEM", _finish),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // --- UI КОМПОНЕНТЫ ---
  Widget _buildGlowOrb(Color color) {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: VytalColors.primaryNeon,
          foregroundColor: VytalColors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
    );
  }
}