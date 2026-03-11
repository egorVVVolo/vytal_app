import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Для "барабанов"
import 'package:flutter/services.dart'; // Для вибрации
import '../theme/colors.dart';
import '../services/notification_service.dart';

class SleepHghScreen extends StatefulWidget {
  const SleepHghScreen({super.key});

  @override
  State<SleepHghScreen> createState() => _SleepHghScreenState();
}

class _SleepHghScreenState extends State<SleepHghScreen> {
  // По дефолту встаем в 7:00
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);

  // Расчетные данные
  late DateTime _bedTime5Cycles; // 7.5 часов
  late DateTime _bedTime6Cycles; // 9.0 часов (Hardmode)
  late DateTime _lastMealTime; // Инсулиновая отсечка

  bool _notificationsEnabled = false; // Состояние "активировано"

  @override
  void initState() {
    super.initState();
    _calculateSchedule();
  }

  void _calculateSchedule() {
    // Превращаем TimeOfDay в DateTime (на завтра)
    final now = DateTime.now();
    final wakeDateTime = DateTime(
      now.year,
      now.month,
      now.day + 1,
      _wakeTime.hour,
      _wakeTime.minute,
    );

    setState(() {
      // Считаем назад
      _bedTime6Cycles = wakeDateTime.subtract(const Duration(hours: 9));
      _bedTime5Cycles = wakeDateTime.subtract(
        const Duration(hours: 7, minutes: 30),
      );

      // Последний прием пищи - за 3 часа до идеального сна
      _lastMealTime = _bedTime6Cycles.subtract(const Duration(hours: 3));
    });
  }

  // Форматирование времени (22:30)
  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _showTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: const Color(0xFF1A1A20),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                  2024,
                  1,
                  1,
                  _wakeTime.hour,
                  _wakeTime.minute,
                ),
                use24hFormat: true,
                onDateTimeChanged: (val) {
                  setState(() {
                    _wakeTime = TimeOfDay(hour: val.hour, minute: val.minute);
                    _calculateSchedule();
                    _notificationsEnabled =
                        false; // Сбрасываем активацию при изменении времени
                  });
                },
              ),
            ),
            CupertinoButton(
              child: const Text(
                'DONE',
                style: TextStyle(
                  color: VytalColors.primaryNeon,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activateProtocol() async {
    HapticFeedback.heavyImpact();

    // 1. Планируем уведомление "За час до сна"
    final preSleep = _bedTime6Cycles.subtract(const Duration(hours: 1));

    await NotificationService().scheduleDailyReminder(
      id: 201,
      title: "🧬 HGH PROTOCOL",
      body:
          "1 hour to sleep. Wear blockers, hide phone. Preparing hormone release.",
      hour: preSleep.hour,
      minute: preSleep.minute,
    );

    // 2. Планируем уведомление "Утро"
    await NotificationService().scheduleDailyReminder(
      id: 202,
      title: "☀️ CORTISOL PEAK",
      body: "Wake up and see light! Starting circadian rhythms.",
      hour: _wakeTime.hour,
      minute: _wakeTime.minute,
    );

    setState(() => _notificationsEnabled = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "SYSTEM ACTIVATED. Notifications set.",
            style: TextStyle(fontFamily: 'monospace'),
          ),
          backgroundColor: VytalColors.secondaryNeon,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "HGH PROTOCOL",
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. ВЫБОР ВРЕМЕНИ ПОДЪЕМА
                  const Text(
                    "WAKE UP TIME",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _showTimePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent, // Minimalist
                        border: Border.all(
                          color: Colors.white12,
                          width: 0.5,
                        ), // Sharp edges
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_wakeTime.hour.toString().padLeft(2, '0')}:${_wakeTime.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Icon(
                            Icons.edit,
                            color: VytalColors.primaryNeon,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 2. TIMELINE ГРАФИК
                  const Text(
                    "BIORHYTHM SCHEDULE",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Карточка: ПОСЛЕДНЯЯ ЕДА
                  _buildEventCard(
                    time: _formatTime(_lastMealTime),
                    title: "INSULIN BLOCK",
                    desc: "Last meal. Only water from here.",
                    icon: Icons.no_food_outlined,
                    color: Colors.redAccent,
                  ),

                  _buildConnector(),

                  // Карточка: ОТБОЙ (Идеал)
                  _buildEventCard(
                    time: _formatTime(_bedTime6Cycles),
                    title: "SLEEP (MAXIMUM)",
                    desc: "9 hours (6 cycles). HGH peak.",
                    icon: Icons.bedtime,
                    color: VytalColors.primaryNeon,
                    isHighlight: true,
                  ),

                  _buildConnector(),

                  // Карточка: ОТБОЙ (Минимум)
                  _buildEventCard(
                    time: _formatTime(_bedTime5Cycles),
                    title: "SLEEP (MINIMUM)",
                    desc: "7.5 hours (5 cycles).",
                    icon: Icons.battery_alert,
                    color: Colors.orangeAccent,
                  ),

                  const SizedBox(height: 30),

                  // 3. ИНФОБЛОК
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Minimalist
                      border: Border.all(
                        color: VytalColors.primaryNeon.withOpacity(0.5),
                        width: 0.5,
                      ), // Sharp thin borders
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: VytalColors.primaryNeon,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "70% of growth hormone is released during deep sleep (SWS) in the first hours of the night.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ФИКСИРОВАННАЯ КНОПКА ВНИЗУ
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: VytalColors.background,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: GestureDetector(
              onTap: _activateProtocol,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _notificationsEnabled
                      ? Colors.black
                      : Colors.transparent, // Sharp and minimal
                  border: Border.all(
                    color: _notificationsEnabled
                        ? VytalColors.secondaryNeon
                        : VytalColors.primaryNeon,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _notificationsEnabled
                          ? Icons.check
                          : Icons.power_settings_new,
                      color: _notificationsEnabled
                          ? VytalColors.secondaryNeon
                          : VytalColors.primaryNeon,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _notificationsEnabled
                          ? "PROTOCOL ACTIVE"
                          : "ACTIVATE PROTOCOL",
                      style: TextStyle(
                        color: _notificationsEnabled
                            ? VytalColors.secondaryNeon
                            : VytalColors.primaryNeon,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required String time,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent, // Minimalist transparent background
        border: isHighlight
            ? Border.all(color: color, width: 1.0)
            : Border.all(color: Colors.white10, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                time,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              if (isHighlight)
                const Text(
                  "START",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(icon, color: color.withOpacity(0.5), size: 30),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      margin: const EdgeInsets.only(left: 45), // Центрируем под временем
      height: 30,
      width: 2,
      color: Colors.white10,
    );
  }
}
