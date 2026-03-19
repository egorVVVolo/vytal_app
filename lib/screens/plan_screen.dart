import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../widgets/weekly_calendar.dart';
import '../widgets/habit_tile.dart';
import '../widgets/add_habit_sheet.dart';
import '../models/habit.dart';
import '../data/mock_data.dart';
import '../services/storage_service.dart';
import 'protocol_library_screen.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  DateTime _selectedDate = DateTime.now();

  // Base list of habits
  List<Habit> _baseHabits = [];
  // List of completed habit IDs for the selected date
  List<String> _completedIdsForDate = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load both habits and completion status
  Future<void> _loadData() async {
    // 1. Load habit list (shared across all days)
    final savedHabits = await StorageService.getHabits();
    List<Habit> habits = savedHabits.isEmpty
        ? List.from(MockData.initialHabits)
        : savedHabits;

    // 2. Load completion status for current selected date
    final completedIds = await StorageService.getCompletedHabitIds(
      _selectedDate,
    );

    if (mounted) {
      setState(() {
        _baseHabits = habits;
        _completedIdsForDate = completedIds;
        _isLoading = false;
      });
    }
  }

  // When changing date in calendar
  void _onDateSelected(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _isLoading = true; // Show loading briefly
    });

    // Load completion status for new date
    final completedIds = await StorageService.getCompletedHabitIds(date);

    setState(() {
      _completedIdsForDate = completedIds;
      _isLoading = false;
    });
  }

  void _openAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitSheet(
        onHabitAdded: (newHabit) {
          setState(() {
            _baseHabits.add(newHabit);
            StorageService.saveHabits(_baseHabits); // Save habit list
          });
        },
      ),
    );
  }

  // Open protocol library
  void _openProtocolLibrary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProtocolLibraryScreen(
          onAddProtocol: (newHabits) {
            setState(() {
              // Add new habits generating unique IDs
              for (var h in newHabits) {
                final uniqueHabit = Habit(
                  id:
                      DateTime.now().millisecondsSinceEpoch.toString() +
                      h.title,
                  title: h.title,
                  subtitle: h.subtitle,
                  type: h.type,
                  icon: h.icon,
                  isCompleted: false,
                );
                _baseHabits.add(uniqueHabit);
              }
              StorageService.saveHabits(_baseHabits);
            });
          },
        ),
      ),
    );
  }

  // --- MAIN TOGGLE LOGIC ---
  void _toggleHabit(Habit habit) async {
    // 1. Update memory
    await StorageService.toggleHabitCompletion(_selectedDate, habit.id);

    // 2. XP Logic
    bool isCompletedNow = !_completedIdsForDate.contains(
      habit.id,
    ); // If ID wasn't there, we just completed it

    if (isCompletedNow) {
      // Award XP
      await StorageService.addXP(10);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.auto_awesome, color: VytalColors.textPrimary, size: 16),
                SizedBox(width: 8),
                Text(
                  "+10 XP  Task Complete",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: VytalColors.textPrimary,

                  ),
                ),
              ],
            ),
            backgroundColor: VytalColors.primaryAccent,
            duration: Duration(milliseconds: 600),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // If unchecked, remove XP
      await StorageService.addXP(-10);
    }

    // 3. Update UI locally
    setState(() {
      if (_completedIdsForDate.contains(habit.id)) {
        _completedIdsForDate.remove(habit.id);
      } else {
        _completedIdsForDate.add(habit.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build final list for display:
    // Take base habit and set isCompleted on the fly based on completed list
    final visibleHabits = _baseHabits.map((h) {
      return h.copyWith(isCompleted: _completedIdsForDate.contains(h.id));
    }).toList();

    // Group habits by type in a single pass
    final vitaminHabits = <Habit>[];
    final activityHabits = <Habit>[];
    final mentalHabits = <Habit>[];
    final sleepHabits = <Habit>[];

    for (final habit in visibleHabits) {
      switch (habit.type) {
        case HabitType.vitamin:
          vitaminHabits.add(habit);
          break;
        case HabitType.activity:
          activityHabits.add(habit);
          break;
        case HabitType.mental:
          mentalHabits.add(habit);
          break;
        case HabitType.sleep:
          sleepHabits.add(habit);
          break;
      }
    }

    return Scaffold(
      backgroundColor: VytalColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader().animate().fadeIn().slideY(begin: -0.2),
            WeeklyCalendar(
              selectedDate: _selectedDate,
              onDateSelected: _onDateSelected,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: VytalColors.primaryAccent,
                      ),
                    )
                  : visibleHabits.isEmpty
                  ? _buildEmptyState().animate().fadeIn(delay: 200.ms)
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildTimeSection(
                          "PROTOCOLS",
                          vitaminHabits,
                        ),
                        _buildTimeSection(
                          "ACTIVITY",
                          activityHabits,
                        ),
                        _buildTimeSection(
                          "MENTAL",
                          mentalHabits,
                        ),
                        _buildTimeSection(
                          "SLEEP & ROUTINE",
                          sleepHabits,
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Schedule",
            style: TextStyle(
              color: VytalColors.primaryAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,

            ),
          ),
          Row(
            children: [
              _headerBtn(
                Icons.auto_stories_outlined,
                _openProtocolLibrary,
                null,
              ),
              const SizedBox(width: 12),
              _headerBtn(
                Icons.add,
                _openAddHabitSheet,
                VytalColors.primaryAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerBtn(IconData icon, VoidCallback onTap, Color? color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.1) ?? VytalColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color?.withValues(alpha: 0.5) ?? VytalColors.textSecondary.withValues(alpha: 0.2)),
          boxShadow: const [],
        ),
        child: Icon(icon, color: color ?? VytalColors.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.memory, size: 60, color: VytalColors.textPrimary.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text(
            "Schedule Empty",
            style: TextStyle(
              color: VytalColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,

            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add protocols or initialize a new sequence.",
            style: TextStyle(
              color: VytalColors.textSecondary,

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection(String title, List<Habit> sectionHabits) {
    if (sectionHabits.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: VytalColors.primaryAccent,
                  shape: BoxShape.rectangle,
                  boxShadow: [
                    BoxShadow(
                      color: VytalColors.primaryAccent.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: VytalColors.primaryAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,

                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: VytalColors.primaryAccent.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
        ...sectionHabits.map(
          (habit) => HabitTile(habit: habit, onTap: () => _toggleHabit(habit)),
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}
