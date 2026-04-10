import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'dart:io';
import '../theme/colors.dart';
import '../services/storage_service.dart';
import '../models/posture_log.dart';
import '../widgets/glass_container.dart';
import 'paywall_screen.dart';

class PostureHistoryScreen extends StatefulWidget {
  const PostureHistoryScreen({super.key});

  @override
  State<PostureHistoryScreen> createState() => _PostureHistoryScreenState();
}

class _PostureHistoryScreenState extends State<PostureHistoryScreen> {
  List<PostureLog> _logs = [];
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final logs = await StorageService.getPostureHistory();
    final isPro = await StorageService.isProUser();

    // Сортируем: старые сначала (для графика)
    logs.sort((a, b) => a.date.compareTo(b.date));

    if (mounted) {
      setState(() {
        _logs = logs;
        _isPro = isPro;
      });
    }
  }

  // Обработка покупки (возврат с Paywall)
  Future<void> _handleUnlock() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaywallScreen()),
    );
    // После возвращения обновляем статус!
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // Инвертируем список для ленты (новые сверху)
    final reversedLogs = _logs.reversed.toList();

    return Scaffold(
      backgroundColor: VytalColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "VISION LOGS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 16,
            color: VytalColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: VytalColors.textPrimary),
      ),
      body: _logs.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. ДИНАМИКА (График или Baseline)
                  const Text(
                    "POSTURE DYNAMICS",
                    style: TextStyle(
                      color: VytalColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _logs.length < 2
                      ? _buildBaselineVisual(
                          _logs.first,
                        ) // Если точка одна - показываем "Target"
                      : SizedBox(
                          height: 220,
                          child: LineChart(_buildChartData()),
                        ), // Если > 1, график

                  const SizedBox(height: 40),

                  // 2. PRO АНАЛИТИКА (Теперь с надежным блюром и динамическим текстом)
                  _buildProSection(reversedLogs.first),

                  const SizedBox(height: 30),

                  // 3. ИСТОРИЯ
                  const Text(
                    "SCAN ARCHIVE",
                    style: TextStyle(
                      color: VytalColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reversedLogs.length,
                    itemBuilder: (ctx, i) => _buildLogCard(reversedLogs[i]),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.center_focus_weak,
            size: 60,
            color: VytalColors.textPrimary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          const Text(
            "NO DATA",
            style: TextStyle(
              color: VytalColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Perform a scan in the GROWTH section",
            style: TextStyle(color: VytalColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Виджет "Baseline" (вместо одной точки на графике)
  Widget _buildBaselineVisual(PostureLog log) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: VytalColors.textPrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: VytalColors.primaryAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Линии прицела
          Positioned(
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: VytalColors.primaryAccent.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: VytalColors.primaryAccent.withValues(alpha: 0.1),
            ),
          ),

          // Центральный круг
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: VytalColors.primaryAccent, width: 2),
              color: VytalColors.primaryAccent.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${log.overallScore}",
                    style: const TextStyle(
                      color: VytalColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const Text(
                    "BASE",
                    style: TextStyle(
                      color: VytalColors.primaryAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Positioned(
            bottom: 12,
            child: Text(
              "BASELINE ESTABLISHED",
              style: TextStyle(
                color: VytalColors.textSecondary,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Секция PRO (Исправленный блюр)
  Widget _buildProSection(PostureLog latestLog) {
    // Контент аналитики (текст и цифры)
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "DEEP ANALYSIS (PRO)",
          style: TextStyle(
            color: VytalColors.secondaryAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Avg Loss",
                _calculateAvgLoss(),
                Icons.height,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                "Progress",
                _calculateProgress(),
                Icons.trending_up,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "BIOMECHANICS",
                style: TextStyle(
                  color: VytalColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,

                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              // ДИНАМИЧЕСКИЙ ТЕКСТ
              Text(
                _isPro
                    ? _getDynamicAnalysisText(latestLog)
                    : "Analysis hidden. Unlock Pro to access detailed spinal biomechanics breakdown and AI recommendations.",
                style: const TextStyle(
                  color: VytalColors.textPrimary,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Если PRO куплен - показываем как есть
    if (_isPro) return content;

    // Если НЕ куплен - используем ImageFiltered для надежного блюра
    return Stack(
      children: [
        // 1. Размытый контент
        ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: 6,
            sigmaY: 6,
          ), // Размываем сам виджет
          child: content,
        ),

        // 2. Кнопка поверх размытия
        Positioned.fill(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: VytalColors.textPrimary.withValues(
                alpha: 0.2,
              ), // Легкое затемнение
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: VytalColors.primaryAccent,
                  size: 32,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _handleUnlock, // <--- ВЫЗЫВАЕМ НОВУЮ ФУНКЦИЮ
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Minimalist
                    foregroundColor: VytalColors.primaryAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(
                        color: VytalColors.primaryAccent,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: const Text(
                    "UNLOCK",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Генератор текста
  String _getDynamicAnalysisText(PostureLog log) {
    if (log.advice.length > 20) {
      return log.advice; // Если AI вернул нормальный совет, используем его
    }

    // Иначе генерируем заглушку на основе баллов
    if (log.overallScore < 50) {
      return "Critical deviation from vertical line. Severe compression observed in the cervical region (-${log.lostHeight} cm). Immediate commencement of the decompression protocol is recommended.";
    } else if (log.overallScore < 80) {
      return "Moderate posture deviations. Pelvic tilt angle is within normal limits, but Text Neck is present. Recovery potential: +${log.lostHeight} cm.";
    } else {
      return "Excellent indicators. Biomechanics are normal. Continue maintenance training to preserve the result.";
    }
  }

  String _calculateAvgLoss() {
    if (_logs.isEmpty) return "--";
    double sum = _logs.fold(0, (prev, e) => prev + e.lostHeight);
    return "-${(sum / _logs.length).toStringAsFixed(1)} cm";
  }

  String _calculateProgress() {
    if (_logs.length < 2) return "0%";
    int first = _logs.first.overallScore;
    int last = _logs.last.overallScore;
    int diff = last - first;
    return diff >= 0 ? "+$diff%" : "$diff%";
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: VytalColors.secondaryAccent, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: VytalColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: VytalColors.textSecondary,
              fontSize: 12,

              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(PostureLog log) {
    Color scoreColor = log.overallScore < 60
        ? VytalColors.warningAccent
        : VytalColors.secondaryAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent, // Minimalist transparent
        border: Border.all(
          color: VytalColors.textPrimary.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: scoreColor, width: 0.5),
            ),
            child: Text(
              "${log.overallScore}",
              style: TextStyle(
                color: scoreColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${log.date.day}.${log.date.month}  ${log.date.hour}:${log.date.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    color: VytalColors.textPrimary,
                    fontWeight: FontWeight.bold,

                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Loss: ${log.lostHeight} cm",
                  style: const TextStyle(
                    color: VytalColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (log.sideImagePath != null)
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: FileImage(File(log.sideImagePath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (!_isPro)
            const Icon(Icons.lock, size: 16, color: VytalColors.textSecondary),
        ],
      ),
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: _logs
              .asMap()
              .entries
              .map(
                (e) =>
                    FlSpot(e.key.toDouble(), e.value.overallScore.toDouble()),
              )
              .toList(),
          isCurved: true,
          color: VytalColors.primaryAccent,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                VytalColors.primaryAccent.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
