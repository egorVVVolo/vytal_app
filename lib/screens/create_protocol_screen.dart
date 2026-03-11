import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/habit.dart';
import '../widgets/glass_container.dart';

class CreateProtocolScreen extends StatefulWidget {
  final Function(List<Habit>) onCreate;

  const CreateProtocolScreen({super.key, required this.onCreate});

  @override
  State<CreateProtocolScreen> createState() => _CreateProtocolScreenState();
}

class _CreateProtocolScreenState extends State<CreateProtocolScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  late TabController _tabController;

  // Корзина выбранных привычек
  final List<Habit> _selectedHabits = [];

  // PRESET INGREDIENT DATABASE
  final Map<String, List<Habit>> _ingredients = {
    "VITAMINS": [
      Habit(
        id: 'i1',
        title: 'Vitamin D3',
        subtitle: '5000 IU (Morning)',
        type: HabitType.vitamin,
        icon: '☀️',
      ),
      Habit(
        id: 'i2',
        title: 'Magnesium',
        subtitle: '400 mg (Evening)',
        type: HabitType.vitamin,
        icon: '💊',
      ),
      Habit(
        id: 'i3',
        title: 'Omega-3',
        subtitle: '1g w/ meal',
        type: HabitType.vitamin,
        icon: '🐟',
      ),
      Habit(
        id: 'i4',
        title: 'Creatine',
        subtitle: '5g (Anytime)',
        type: HabitType.vitamin,
        icon: '💪',
      ),
      Habit(
        id: 'i5',
        title: 'Zinc',
        subtitle: '15-30 mg',
        type: HabitType.vitamin,
        icon: '🛡️',
      ),
      Habit(
        id: 'i6',
        title: 'Electrolytes',
        subtitle: 'Salt water',
        type: HabitType.vitamin,
        icon: '⚡',
      ),
    ],
    "SPORT": [
      Habit(
        id: 'i7',
        title: 'Dead Hang',
        subtitle: '2 mins (Decompression)',
        type: HabitType.activity,
        icon: '🪜',
      ),
      Habit(
        id: 'i8',
        title: 'Sprints',
        subtitle: '4x100 meters',
        type: HabitType.activity,
        icon: '🏃',
      ),
      Habit(
        id: 'i9',
        title: 'Swimming',
        subtitle: '45 mins',
        type: HabitType.activity,
        icon: '🏊',
      ),
      Habit(
        id: 'i10',
        title: 'Stretching',
        subtitle: '"Cobra" Routine',
        type: HabitType.activity,
        icon: '🧘',
      ),
      Habit(
        id: 'i11',
        title: 'Pushups',
        subtitle: '3 sets to failure',
        type: HabitType.activity,
        icon: '🏋️',
      ),
    ],
    "MIND": [
      Habit(
        id: 'i12',
        title: 'Meditation',
        subtitle: '10 mins (NSDR)',
        type: HabitType.mental,
        icon: '🧠',
      ),
      Habit(
        id: 'i13',
        title: 'Cold Shower',
        subtitle: '2 mins',
        type: HabitType.mental,
        icon: '🚿',
      ),
      Habit(
        id: 'i14',
        title: 'Reading',
        subtitle: '20 pages',
        type: HabitType.mental,
        icon: '📚',
      ),
      Habit(
        id: 'i15',
        title: 'No Phone',
        subtitle: '1 hour offline',
        type: HabitType.mental,
        icon: '📵',
      ),
    ],
    "SLEEP": [
      Habit(
        id: 'i16',
        title: 'Pitch Black',
        subtitle: 'Sleep mask',
        type: HabitType.sleep,
        icon: '🕶️',
      ),
      Habit(
        id: 'i17',
        title: 'Curfew 22:00',
        subtitle: 'Lights out',
        type: HabitType.sleep,
        icon: '🌙',
      ),
      Habit(
        id: 'i18',
        title: 'Fasting',
        subtitle: '3 hrs before bed',
        type: HabitType.sleep,
        icon: '🍽️',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  void _toggleHabit(Habit habit) {
    setState(() {
      if (_selectedHabits.any((h) => h.title == habit.title)) {
        _selectedHabits.removeWhere((h) => h.title == habit.title);
      } else {
        // Создаем копию, чтобы ID был уникальным при сохранении
        _selectedHabits.add(habit);
      }
    });
  }

  void _saveProtocol() {
    if (_selectedHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Select at least one metric!",
            style: TextStyle(fontFamily: 'monospace'),
          ),
        ),
      );
      return;
    }

    widget.onCreate(_selectedHabits);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "CONSTRUCTOR",
          style: TextStyle(
            color: VytalColors.primaryNeon,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontFamily: 'monospace',
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: VytalColors.secondaryNeon),
            onPressed: _saveProtocol,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: VytalColors.primaryNeon,
          labelColor: VytalColors.primaryNeon,
          unselectedLabelColor: Colors.white54,
          isScrollable: true, // Чтобы влазило на маленькие экраны
          tabs: const [
            Tab(text: "BIO"),
            Tab(text: "SPORT"),
            Tab(text: "MIND"),
            Tab(text: "SLEEP"),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Поле названия (Опционально)
          /*
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Название протокола (например, Утро)",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: VytalColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          */

          // 2. Selection Lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHabitList("VITAMINS"),
                _buildHabitList("SPORT"),
                _buildHabitList("MIND"),
                _buildHabitList("SLEEP"),
              ],
            ),
          ),

          // 3. Bottom Panel
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildHabitList(String category) {
    final habits = _ingredients[category] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isSelected = _selectedHabits.any((h) => h.title == habit.title);

        return GestureDetector(
          onTap: () => _toggleHabit(habit),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? VytalColors.primaryNeon.withOpacity(0.1)
                  : VytalColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? VytalColors.primaryNeon
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Text(habit.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        habit.subtitle,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? VytalColors.primaryNeon
                        : Colors.white10,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: VytalColors.background,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "SELECTED:",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_selectedHabits.length} ASSETS",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),

            ElevatedButton.icon(
              onPressed: _saveProtocol,
              icon: const Icon(Icons.add_task),
              label: const Text(
                "INITIALIZE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'monospace',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: VytalColors.primaryNeon,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
