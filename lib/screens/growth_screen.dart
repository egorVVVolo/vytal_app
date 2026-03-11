import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vytal_app/screens/vision_ai_screen.dart';
import '../theme/colors.dart';
import '../widgets/growth_capsule.dart';
import '../services/storage_service.dart';
import '../models/height_log.dart';
import 'paywall_screen.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  // Genetics Form Data
  double fatherHeight = 180;
  double motherHeight = 165;

  // User Data (from DB)
  double currentHeight = 175;
  double _targetHeight = 180;
  double _weight = 70;
  int _age = 18;

  // Posture Height Loss
  double _postureLostHeight = 0.0;

  List<HeightLog> _history = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final bio = await StorageService.getBiometrics();
    final logs = await StorageService.getHeightLogs();

    // Load latest posture scan
    final lastPosture = await StorageService.getLastPostureLog();

    if (mounted) {
      setState(() {
        currentHeight = bio['height'] ?? 175.0;
        _weight = bio['weight'] ?? 70.0;
        _age = bio['age'] ?? 18;
        _targetHeight = bio['targetHeight'] ?? (currentHeight + 5);
        _history = logs;

        // Actual lost height from scan or 0
        _postureLostHeight = lastPosture?.lostHeight ?? 0.0;
      });
    }
  }

  // Update target height on slider change
  void _updateGenetics() {
    double rawTarget = (fatherHeight + motherHeight + 13) / 2;
    double gap = rawTarget - currentHeight;
    if (gap < 4) {
      rawTarget = currentHeight + 4.0;
    }

    setState(() {
      _targetHeight = rawTarget;
    });

    StorageService.saveBiometrics(
      weight: _weight,
      height: currentHeight,
      age: _age,
      targetHeight: _targetHeight,
    );
  }

  // Dialog to log new height measurement
  void _showAddLogDialog() {
    int selectedInteger = currentHeight.floor();
    int selectedDecimal = ((currentHeight - selectedInteger) * 10).round();

    showModalBottomSheet(
      context: context,
      backgroundColor: VytalColors.surface, // Minimal pitch black
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ), // Sharp edges
      ),
      builder: (ctx) {
        return SizedBox(
          height: 350,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "LOG MEASUREMENT",
                      style: TextStyle(
                        color: VytalColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,

                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        double finalHeight =
                            selectedInteger + (selectedDecimal / 10);
                        await StorageService.addHeightLog(finalHeight, true);

                        await StorageService.saveBiometrics(
                          weight: _weight,
                          height: finalHeight,
                          age: _age,
                          targetHeight: _targetHeight,
                        );

                        _loadData();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "SAVE",
                        style: TextStyle(
                          color: VytalColors.primaryNeon,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,

                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "CURRENT HEIGHT",
                style: TextStyle(
                  color: VytalColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,

                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      child: CupertinoTheme(
                        data: const CupertinoThemeData(
                          brightness: Brightness.dark,
                        ),
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedInteger - 100,
                          ),
                          itemExtent: 50,
                          onSelectedItemChanged: (val) {
                            HapticFeedback.selectionClick();
                            selectedInteger = 100 + val;
                          },
                          children: List.generate(
                            150,
                            (index) => Center(
                              child: Text(
                                "${100 + index}",
                                style: const TextStyle(
                                  color: VytalColors.textPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,

                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        ".",
                        style: TextStyle(
                          color: VytalColors.primaryNeon,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: CupertinoTheme(
                        data: const CupertinoThemeData(
                          brightness: Brightness.dark,
                        ),
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedDecimal,
                          ),
                          itemExtent: 50,
                          onSelectedItemChanged: (val) {
                            HapticFeedback.selectionClick();
                            selectedDecimal = val;
                          },
                          children: List.generate(
                            10,
                            (index) => Center(
                              child: Text(
                                "$index",
                                style: const TextStyle(
                                  color: VytalColors.primaryNeon,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,

                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        "cm",
                        style: TextStyle(
                          color: VytalColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "GROWTH_LAB",
                style: TextStyle(
                  color: VytalColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,

                ),
              ).animate().fadeIn().slideY(begin: -0.2),
              const SizedBox(height: 5),
              const Text(
                "GENETICS & POTENTIAL",
                style: TextStyle(
                  color: VytalColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 2,

                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),

              Center(
                child: GrowthCapsule(
                  currentHeight: currentHeight,
                  potentialHeight: _targetHeight,
                  posturePenalty: _postureLostHeight,
                ),
              ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 30),

              _buildSectionHeader("CORRECTION").animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 16),
              _buildScannerCard()
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideY(begin: 0.1),

              const SizedBox(height: 40),

              _buildSectionHeader(
                "GENETIC SIMULATION",
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.transparent, // Transparent for minimalism
                  border: Border.all(color: VytalColors.textSecondary, width: 0.5),
                ),
                child: Column(
                  children: [
                    _buildSlider("Father's Height", fatherHeight, (v) {
                      setState(() => fatherHeight = v);
                      _updateGenetics();
                    }),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: VytalColors.textSecondary),
                    ),
                    _buildSlider("Mother's Height", motherHeight, (v) {
                      setState(() => motherHeight = v);
                      _updateGenetics();
                    }),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader("DYNAMICS"),
                  IconButton(
                    onPressed: _showAddLogDialog,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: VytalColors.primaryNeon,
                    ),
                    tooltip: "Add Measurement",
                  ),
                ],
              ).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 16),

              Container(
                height: 200,
                padding: const EdgeInsets.only(
                  right: 20,
                  left: 10,
                  top: 20,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: VytalColors.textSecondary, width: 0.5),
                ),
                child: _history.isEmpty
                    ? const Center(
                        child: Text(
                          "No data. Tap + to start tracking.",
                          style: TextStyle(color: VytalColors.textSecondary),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: VytalColors.textPrimary.withValues(alpha: 0.05),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _history.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value.value);
                              }).toList(),
                              isCurved: true,
                              color: VytalColors.primaryNeon,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: VytalColors.primaryNeon.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 30),

              // Paywall Button
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaywallScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: VytalColors.warningNeon,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.lock_outline,
                          color: VytalColors.warningNeon,
                          size: 16,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "UNLOCK AI FORECAST",
                          style: TextStyle(
                            color: VytalColors.warningNeon,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 2,

                          ),
                        ),
                      ],
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: VytalColors.primaryNeon),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: VytalColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,

          ),
        ),
      ],
    );
  }

  Widget _buildScannerCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VisionAiScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent, // Transparent minimalism
          border: Border.all(
            color: VytalColors.primaryNeon,
            width: 0.5,
          ), // Thin border
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: VytalColors.textPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.center_focus_strong,
                color: VytalColors.primaryNeon,
              ),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI POSTURE SCAN",
                  style: TextStyle(
                    color: VytalColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,

                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "ACCURACY: 98%",
                  style: TextStyle(
                    color: VytalColors.primaryNeon,
                    fontSize: 10,

                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: VytalColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: VytalColors.textSecondary)),
            Text(
              "${value.toInt()} cm",
              style: const TextStyle(
                color: VytalColors.textPrimary,
                fontWeight: FontWeight.bold,

              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: VytalColors.textPrimary,
            inactiveTrackColor: VytalColors.textSecondary,
            thumbColor: VytalColors.primaryNeon,
            overlayColor: VytalColors.primaryNeon.withValues(alpha: 0.2),
            trackHeight: 2,
          ),
          child: Slider(value: value, min: 150, max: 220, onChanged: onChanged),
        ),
      ],
    );
  }
}
