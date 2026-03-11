import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';
import '../services/storage_service.dart';
import 'main_shell.dart';

class OnboardingV2 extends StatefulWidget {
  const OnboardingV2({super.key});

  @override
  State<OnboardingV2> createState() => _OnboardingV2State();
}

class _OnboardingV2State extends State<OnboardingV2> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0: Story, 1: Data, 2: Calculation, 3: Result
  int _storyIndex = 0;
  int _dataStepIndex = 0;

  // Data Input State
  String _name = ""; // ADDED NAME
  String _gender = "Male";
  int _age = 16;
  int _height = 175;
  int _weight = 70;
  int _fatherHeight = 178;
  int _motherHeight = 165;

  // Calculation State
  double _targetHeight = 0;

  void _nextStory() {
    if (_storyIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _currentStep = 1);
    }
  }

  void _nextDataStep() {
    // Increased number of steps (0=Name, 1=Gender, 2=Age, 3=Bio, 4=Parents)
    if (_dataStepIndex < 4) {
      setState(() => _dataStepIndex++);
    } else {
      _calculatePotential();
    }
  }

  void _calculatePotential() {
    setState(() => _currentStep = 2);

    // Formula logic (Tanner Method + Vytal Bonus)
    double target;
    if (_gender == "Male") {
      target = (_fatherHeight + _motherHeight + 13) / 2;
    } else {
      target = (_fatherHeight + _motherHeight - 13) / 2;
    }

    // Vytal Promise: always give +4 cm from posture
    double currentGap = target - _height;
    if (currentGap < 4) {
      target = _height + 4.0;
    }

    _targetHeight = target;

    Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _currentStep = 3);
    });
  }

  Future<void> _finishOnboarding() async {
    // Save entered NAME
    await StorageService.saveUserName(_name.isEmpty ? "User" : _name);
    await StorageService.saveGoals(["Growth", "Posture", "HGH"]);

    await StorageService.saveBiometrics(
      weight: _weight.toDouble(),
      height: _height.toDouble(),
      age: _age,
      targetHeight: _targetHeight,
    );

    await StorageService.completeOnboarding();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainShell(
            userName: _name.isEmpty ? "User" : _name,
            userGoals: const ["Growth"],
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      // So keyboard doesn't break layout on name input step
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. ФОНОВЫЕ ЭФФЕКТЫ
          Positioned(
            top: -100,
            right: -100,
            child:
                Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: VytalColors.primaryNeon.withValues(alpha: 0.08),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      duration: 4.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                    ),
          ),

          // 2. ОСНОВНОЙ КОНТЕНТ
          SafeArea(child: _buildCurrentStep()),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: KeyedSubtree(key: ValueKey(_currentStep), child: _getContent()),
    );
  }

  Widget _getContent() {
    switch (_currentStep) {
      case 0:
        return _buildStorytelling();
      case 1:
        return _buildDataInput();
      case 2:
        return _buildCalculation();
      case 3:
        return _buildResult();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- STAGE 1: STORYTELLING ---
  Widget _buildStorytelling() {
    final stories = [
      _StoryData(
        title: "GENETICS IS NOT\nA VERDICT",
        text:
            "Scientific fact: Your height is only 60% dependent on DNA. The remaining 40% is hormones, sleep, and mechanics. We will hack this 40%.",
        icon: Icons.science_rounded,
        tag: "SCIENTIFIC PROTOCOL",
      ),
      _StoryData(
        title: "YOU ARE LOSING\nCENTIMETERS",
        text:
            "Right now, 'tech neck' and spinal compression are stealing 3-5 cm from you. Reclaim them in 30 days.",
        icon: Icons.warning_amber_rounded,
        tag: "HIDDEN POTENTIAL",
      ),
      _StoryData(
        title: "VYTAL\nSYSTEM",
        text:
            "Not just a tracker. It's an algorithm for HGH optimization and skeletal micro-correction. Your personal biohack.",
        icon: Icons.auto_awesome_rounded,
        tag: "GROWTH PROTOCOL",
      ),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "STEP ${_storyIndex + 1}/3",
                style: const TextStyle(
                  color: VytalColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,

                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _storyIndex = i),
            itemCount: stories.length,
            itemBuilder: (context, i) => _buildStorySlide(stories[i]),
          ),
        ),

        _buildBottomBar(
          label: _storyIndex == 2 ? "INITIATE ANALYSIS" : "NEXT",
          onTap: _nextStory,
          subLabel: "Takes 30 seconds",
        ),
      ],
    );
  }

  Widget _buildStorySlide(_StoryData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child:
                Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: VytalColors.primaryNeon.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            VytalColors.primaryNeon.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        data.icon,
                        size: 50,
                        color: VytalColors.primaryNeon,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 2.seconds,
                    ),
          ),

          const SizedBox(height: 50),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: VytalColors.textPrimary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: VytalColors.textSecondary),
            ),
            child: Text(
              data.tag,
              style: const TextStyle(
                color: VytalColors.primaryNeon,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,

              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            data.title,
            style: const TextStyle(
              color: VytalColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              height: 1.1,

            ),
          ).animate().fadeIn().moveX(begin: -20, end: 0),

          const SizedBox(height: 20),

          Text(
            data.text,
            style: const TextStyle(
              color: VytalColors.textSecondary,
              fontSize: 15,
              height: 1.5,

            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  // --- STAGE 2: DATA INPUT ---
  Widget _buildDataInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: List.generate(
              5,
              (index) => Expanded(
                // Now 5 steps
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: index <= _dataStepIndex
                        ? VytalColors.primaryNeon
                        : VytalColors.textSecondary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildDataStepContent(),
            ),
          ),

          _buildBottomBar(
            label: _dataStepIndex == 4 ? "CALCULATE POTENTIAL" : "PROCEED",
            onTap: () {
              // If name step, check input
              if (_dataStepIndex == 0 && _name.isEmpty) {
                // Add shake or snackbar later, for now ignore
                return;
              }
              _nextDataStep();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataStepContent() {
    switch (_dataStepIndex) {
      case 0:
        return _stepName(); // NEW STEP
      case 1:
        return _stepGender();
      case 2:
        return _stepAge();
      case 3:
        return _stepBio();
      case 4:
        return _stepParents();
      default:
        return const SizedBox.shrink();
    }
  }

  // NEW NAME INPUT WIDGET
  Widget _stepName() {
    return Column(
      key: const ValueKey("NameStep"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("IDENTIFICATION", "What's your designation?"),
        const SizedBox(height: 10),
        const Text(
          "This designation will be used across the system.",
          style: TextStyle(color: VytalColors.textSecondary, ),
        ),
        const SizedBox(height: 40),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: VytalColors.textPrimary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: VytalColors.textSecondary),
          ),
          child: TextField(
            autofocus: true,
            style: const TextStyle(
              color: VytalColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,

            ),
            decoration: const InputDecoration(
              hintText: "Enter designation...",
              hintStyle: TextStyle(
                color: VytalColors.textSecondary,

              ),
              border: InputBorder.none,
            ),
            onChanged: (val) => _name = val,
            onSubmitted: (_) {
              if (_name.isNotEmpty) _nextDataStep();
            },
          ),
        ),
      ],
    );
  }

  Widget _stepGender() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("BIOLOGY", "Define physiological baseline"),
        const SizedBox(height: 10),
        const Text(
          "Critical parameter for Tanner calculation formula.",
          style: TextStyle(color: VytalColors.textSecondary, ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: Row(
            children: [
              _genderCard("Male", "MALE", Icons.male_rounded),
              const SizedBox(width: 16),
              _genderCard("Female", "FEMALE", Icons.female_rounded),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _genderCard(String val, String label, IconData icon) {
    bool isSel = _gender == val;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _gender = val);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSel
                ? VytalColors.primaryNeon.withValues(alpha: 0.1)
                : VytalColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSel ? VytalColors.primaryNeon : VytalColors.textSecondary,
              width: 2,
            ),
            boxShadow: isSel
                ? [
                    BoxShadow(
                      color: VytalColors.primaryNeon.withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSel ? VytalColors.primaryNeon : VytalColors.textSecondary,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                label,
                style: TextStyle(
                  color: isSel ? VytalColors.textPrimary : VytalColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepAge() {
    String growthPlateStatus = "GROWTH PLATES: OPEN";
    Color statusColor = VytalColors.secondaryNeon;
    if (_age >= 18 && _age < 22) {
      growthPlateStatus = "GROWTH PLATES: CLOSING";
      statusColor = Colors.orange;
    } else if (_age >= 22) {
      growthPlateStatus = "POSTURE CORRECTION PHASE";
      statusColor = VytalColors.primaryNeon;
    }

    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("CHRONOLOGY", "Input your age"),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insights, color: statusColor, size: 16),
              const SizedBox(width: 8),
              Text(
                growthPlateStatus,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,

                ),
              ),
            ],
          ),
        ).animate(key: ValueKey(growthPlateStatus)).fadeIn(),

        const SizedBox(height: 40),

        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: VytalColors.textPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: VytalColors.textSecondary),
                ),
              ),
              CupertinoPicker(
                itemExtent: 60,
                scrollController: FixedExtentScrollController(
                  initialItem: _age - 12,
                ),
                onSelectedItemChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() => _age = 12 + i);
                },
                children: List.generate(
                  24,
                  (i) => Center(
                    child: Text(
                      "${12 + i}",
                      style: const TextStyle(
                        color: VytalColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                right: 80,
                child: Text(
                  "YRS",
                  style: TextStyle(
                    color: VytalColors.textSecondary,
                    fontWeight: FontWeight.bold,

                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBio() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("ARCHITECTURE", "Current parameters"),
        const SizedBox(height: 10),
        const Text(
          "Required for calculating current skeletal load.",
          style: TextStyle(color: VytalColors.textSecondary, ),
        ),
        const SizedBox(height: 40),

        Row(
          children: [
            Expanded(
              child: _buildDrumColumn(
                "HEIGHT",
                _height,
                120,
                220,
                (v) => setState(() => _height = v),
                "CM",
              ),
            ),
            Container(width: 1, height: 100, color: VytalColors.textSecondary),
            Expanded(
              child: _buildDrumColumn(
                "WEIGHT",
                _weight,
                30,
                150,
                (v) => setState(() => _weight = v),
                "KG",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepParents() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("HEREDITY", "Parental Height"),
        const SizedBox(height: 10),
        const Text(
          "Baseline genetic variables for the prediction engine.",
          style: TextStyle(color: VytalColors.textSecondary, ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Icon(
            Icons.group_work_rounded,
            color: VytalColors.primaryNeon.withValues(alpha: 0.5),
            size: 40,
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _buildDrumColumn(
                "FATHER",
                _fatherHeight,
                140,
                220,
                (v) => setState(() => _fatherHeight = v),
                "CM",
              ),
            ),
            Container(width: 1, height: 100, color: VytalColors.textSecondary),
            Expanded(
              child: _buildDrumColumn(
                "MOTHER",
                _motherHeight,
                130,
                200,
                (v) => setState(() => _motherHeight = v),
                "CM",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrumColumn(
    String title,
    int value,
    int min,
    int max,
    Function(int) onChanged,
    String unit,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: VytalColors.primaryNeon,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,

          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: VytalColors.primaryNeon.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              CupertinoPicker(
                itemExtent: 50,
                scrollController: FixedExtentScrollController(
                  initialItem: value - min,
                ),
                onSelectedItemChanged: (i) {
                  HapticFeedback.selectionClick();
                  onChanged(min + i);
                },
                children: List.generate(
                  max - min + 1,
                  (i) => Center(
                    child: Text(
                      "${min + i}",
                      style: const TextStyle(
                        color: VytalColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            color: VytalColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 10,

          ),
        ),
      ],
    );
  }

  Widget _stepHeader(String kicker, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          kicker,
          style: const TextStyle(
            color: VytalColors.primaryNeon,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,

          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: VytalColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.1,

          ),
        ),
      ],
    );
  }

  // --- STAGE 3: CALCULATION ---
  Widget _buildCalculation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: VytalColors.primaryNeon.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: VytalColors.primaryNeon,
                ),
              ),
              const Icon(Icons.fingerprint, size: 40, color: VytalColors.textPrimary),
            ],
          ),
          const SizedBox(height: 40),
          _AnimatedPhrases(),
        ],
      ),
    );
  }

  // --- STAGE 4: RESULT ---
  Widget _buildResult() {
    double improvement = _targetHeight - _height;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: VytalColors.textPrimary,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: VytalColors.textSecondary),
              ),
              child: const Text(
                "CALCULATION COMPLETE",
                style: TextStyle(
                  color: VytalColors.secondaryNeon,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,

                ),
              ),
            ).animate().fadeIn().slideY(begin: -1, end: 0),

            const SizedBox(height: 30),

            const Text(
              "YOUR POTENTIAL",
              style: TextStyle(
                color: VytalColors.textSecondary,
                fontSize: 12,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,

              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _targetHeight.toStringAsFixed(1),
                  style: const TextStyle(
                    color: VytalColors.textPrimary,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    height: 0.9,

                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12, left: 8),
                  child: Text(
                    "CM",
                    style: TextStyle(
                      color: VytalColors.primaryNeon,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                ),
              ],
            ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),

            const SizedBox(height: 40),

            Container(
              height: 220,
              padding: const EdgeInsets.only(top: 20, right: 20),
              decoration: BoxDecoration(
                color: VytalColors.textPrimary,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: VytalColors.textPrimary.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: VytalColors.textPrimary.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) =>
                            FlLine(color: VytalColors.textPrimary.withValues(alpha: 0.05)),
                      ),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 0),
                            FlSpot(3, improvement * 0.3),
                            FlSpot(6, improvement * 0.6),
                            FlSpot(10, improvement),
                          ],
                          isCurved: true,
                          color: VytalColors.primaryNeon,
                          barWidth: 4,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                VytalColors.primaryNeon.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    bottom: 10,
                    right: 10,
                    child: Text(
                      "12 MONTHS",
                      style: TextStyle(
                        color: VytalColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: VytalColors.primaryNeon, width: 4),
                ),
                color: VytalColors.textPrimary.withValues(alpha: 0.02),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AI PROJECTION:",
                    style: TextStyle(
                      color: VytalColors.primaryNeon,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 12,

                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: VytalColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,

                      ),
                      children: [
                        const TextSpan(
                          text: "We detected a potential margin of ",
                        ),
                        TextSpan(
                          text: "+${improvement.toStringAsFixed(1)} cm",
                          style: const TextStyle(
                            color: VytalColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text:
                              ". This is possible through spinal decompression and sleeping HGH optimization.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 40),
            _buildBottomBar(label: "INITIALIZE PLAN", onTap: _finishOnboarding),
          ],
        ),
      ),
    );
  }

  // --- COMMON WIDGETS ---
  Widget _buildBottomBar({
    required String label,
    required VoidCallback onTap,
    String? subLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                subLabel,
                style: const TextStyle(
                  color: VytalColors.textSecondary,
                  fontSize: 12,

                ),
              ),
            ),

          GestureDetector(
                onTap: onTap,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: VytalColors.primaryNeon,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: VytalColors.primaryNeon.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: VytalColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,

                    ),
                  ),
                ),
              )
              .animate(target: 1)
              .shimmer(
                delay: const Duration(seconds: 3),
                duration: const Duration(milliseconds: 1500),
              ),
        ],
      ),
    );
  }
}

class _AnimatedPhrases extends StatefulWidget {
  @override
  State<_AnimatedPhrases> createState() => _AnimatedPhrasesState();
}

class _AnimatedPhrasesState extends State<_AnimatedPhrases> {
  int _index = 0;
  final List<String> _phrases = [
    "SCANNING DNA VECTORS...",
    "CALCULATING WOLFF'S LAW MODIFIERS...",
    "ANALYZING SKELETAL GEOMETRY...",
    "PROJECTING HGH PEAKS...",
    "COMPILING PROTOCOL...",
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) setState(() => _index = (_index + 1) % _phrases.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _phrases[_index],
        key: ValueKey(_index),
        style: const TextStyle(
          color: VytalColors.primaryNeon,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          fontSize: 12,

        ),
      ),
    );
  }
}

class _StoryData {
  final String title;
  final String text;
  final IconData icon;
  final String tag;
  _StoryData({
    required this.title,
    required this.text,
    required this.icon,
    required this.tag,
  });
}
