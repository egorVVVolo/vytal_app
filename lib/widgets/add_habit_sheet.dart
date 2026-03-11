import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/habit.dart';

class AddHabitSheet extends StatefulWidget {
  // Function to return created habit back to parent screen
  final Function(Habit) onHabitAdded;

  const AddHabitSheet({super.key, required this.onHabitAdded});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  HabitType _selectedType = HabitType.vitamin;
  String _selectedIcon = "💊";

  // List of available icons for selection
  final Map<HabitType, List<String>> _iconsMap = {
    HabitType.vitamin: ["💊", "🧪", "💧", "🍏", "🍵"],
    HabitType.activity: ["💪", "🏃", "🧘", "🏋️", "🤸", "🧱"],
    HabitType.sleep: ["🌙", "🛌", "⏰", "📵", "🕶️"],
    HabitType.mental: ["🧠", "📚", "🎵", "🧘‍♂️", "🤫", "📵"],
  };

  void _save() {
    if (_titleController.text.isEmpty) return;

    final newHabit = Habit(
      id: DateTime.now().toString(), // Temp ID
      title: _titleController.text,
      subtitle: _subtitleController.text.isEmpty
          ? "Daily"
          : _subtitleController.text,
      type: _selectedType,
      icon: _selectedIcon,
      isCompleted: false,
    );

    widget.onHabitAdded(newHabit);
    Navigator.pop(context); // Close sheet
  }

  @override
  Widget build(BuildContext context) {
    // Get keyboard padding so it doesn't overlap content
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding + 24),
      decoration: const BoxDecoration(
        color: VytalColors.textPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Take minimum space
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: VytalColors.textSecondary,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "NEW DIRECTIVE",
            style: TextStyle(
              color: VytalColors.primaryNeon,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,

            ),
          ),

          const SizedBox(height: 24),

          // 1. Title Input
          _buildInput(_titleController, "Designation (e.g. Magnesium)"),
          const SizedBox(height: 16),
          _buildInput(_subtitleController, "Parameters (e.g. 400 mg)"),

          const SizedBox(height: 24),

          // 2. Category Selection (Chips)
          const Text(
            "CATEGORY",
            style: TextStyle(
              color: VytalColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,

            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: HabitType.values.map((type) {
              final isSelected = _selectedType == type;
              return ChoiceChip(
                label: Text(type.name.toUpperCase()),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    _selectedType = type;
                    _selectedIcon = _iconsMap[type]!
                        .first; // Reset icon to first in category
                  });
                },
                backgroundColor: VytalColors.background,
                selectedColor: VytalColors.primaryNeon.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? VytalColors.primaryNeon : VytalColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,

                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isSelected
                        ? VytalColors.primaryNeon
                        : VytalColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 3. Icon Selection
          const Text(
            "ICON",
            style: TextStyle(
              color: VytalColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,

            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _iconsMap[_selectedType]!.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? VytalColors.primaryNeon.withValues(alpha: 0.2)
                          : VytalColors.textPrimary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? VytalColors.primaryNeon
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(icon, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 32),

          // 4. Save Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: VytalColors.primaryNeon,
                foregroundColor: VytalColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                "INITIALIZE PROTOCOL",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Input Field Helper
  Widget _buildInput(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: VytalColors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: VytalColors.textPrimary.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: VytalColors.textPrimary, ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: VytalColors.textPrimary.withValues(alpha: 0.3),

          ),
        ),
      ),
    );
  }
}
