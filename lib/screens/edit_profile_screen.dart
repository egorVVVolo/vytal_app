import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Нужно для "dials"
import 'package:flutter/services.dart'; // Для вибрации
import '../theme/colors.dart';
import '../services/storage_service.dart';
import '../utils/l10n.dart';

class EditProfileScreen extends StatefulWidget {
  final VoidCallback onSave;

  const EditProfileScreen({super.key, required this.onSave});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();

  // Храним значения не в контроллерах, а в переменных
  double _weight = 70.0;
  double _height = 175.0;
  int _age = 18;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    final name = await StorageService.getUserName();
    final bio = await StorageService.getBiometrics();

    setState(() {
      _nameController.text = name;
      _weight = bio['weight'];
      _height = bio['height'];
      _age = bio['age'];
    });
  }

  Future<void> _save() async {
    await StorageService.saveUserName(_nameController.text);
    await StorageService.saveBiometrics(
      weight: _weight,
      height: _height,
      age: _age,
    );

    widget.onSave();
    if (mounted) Navigator.pop(context);
  }

  // --- ЛОГИКА ОТКРЫТИЯ "DIALS" ---
  void _showPicker({
    required String title,
    required int min,
    required int max,
    required int current,
    required Function(int) onChanged,
    String suffix = "",
  }) {
    // Убираем клавиатуру, если она открыта (от поля имени)
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              // Заголовок пикера
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: VytalColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        L10n.t('done'),
                        style: const TextStyle(
                          color: VytalColors.primaryAccent,
                          fontWeight: FontWeight.bold,

                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Сам барабан
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness:
                        Brightness.dark, // Темная тема для iOS компонентов
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        color: VytalColors.textPrimary,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  child: CupertinoPicker(
                    itemExtent: 40, // Высота одной строки
                    scrollController: FixedExtentScrollController(
                      initialItem: current - min,
                    ),
                    onSelectedItemChanged: (index) {
                      // ПРОВЕРКА НАСТРОЕК
                      if (StorageService.getSetting('haptic')) {
                        HapticFeedback.selectionClick();
                      }
                      onChanged(min + index);
                    },
                    children: List.generate(max - min + 1, (index) {
                      return Center(
                        child: Text(
                          "${min + index} $suffix",
                          style: const TextStyle(
                            color: VytalColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          L10n.t('parameters'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2,

          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: VytalColors.textPrimary),
          tooltip: "Close",
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: VytalColors.primaryAccent),
            tooltip: "Save",
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(L10n.t('personal_data')),

          // Имя оставляем обычным вводом (тут крутилка не поможет)
          _buildNameInput(),

          const SizedBox(height: 30),

          _buildSection(L10n.t('biometrics')),

          // Карточки, которые открывают крутилки
          Row(
            children: [
              Expanded(
                child: _buildPickerCard(
                  label: L10n.t('height'),
                  value: "${_height.toInt()}",
                  unit: "cm",
                  icon: Icons.height,
                  onTap: () {
                    _showPicker(
                      title: "SELECT HEIGHT",
                      min: 140,
                      max: 220,
                      current: _height.toInt(),
                      suffix: "cm",
                      onChanged: (val) =>
                          setState(() => _height = val.toDouble()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPickerCard(
                  label: L10n.t('weight'),
                  value: "${_weight.toInt()}",
                  unit: "kg",
                  icon: Icons.monitor_weight_outlined,
                  onTap: () {
                    _showPicker(
                      title: "SELECT WEIGHT",
                      min: 40,
                      max: 150,
                      current: _weight.toInt(),
                      suffix: "kg",
                      onChanged: (val) =>
                          setState(() => _weight = val.toDouble()),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildPickerCard(
            label: L10n.t('age'),
            value: "$_age",
            unit: "yrs",
            icon: Icons.cake_outlined,
            onTap: () {
              _showPicker(
                title: "SELECT AGE",
                min: 12,
                max: 100,
                current: _age,
                onChanged: (val) => setState(() => _age = val),
              );
            },
          ),

          const SizedBox(height: 50),

          // Большая кнопка
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: VytalColors.surface, // Minimalist black
                foregroundColor: VytalColors.primaryAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: VytalColors.primaryAccent, width: 0.5),
                ), // Sharp edges
                elevation: 0,
              ),
              child: Text(
                L10n.t('save_changes'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 16,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: VytalColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,

        ),
      ),
    );
  }

  // Поле имени (обычный текст)
  Widget _buildNameInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent, // Minimalist
        border: Border.all(color: VytalColors.textSecondary, width: 0.5), // Sharp borders
      ),
      child: TextField(
        controller: _nameController,
        style: const TextStyle(
          color: VytalColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,

        ),
        decoration: InputDecoration(
          label: Text(L10n.t('name'), style: const TextStyle()),
          labelStyle: const TextStyle(color: VytalColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          icon: const Icon(Icons.person_outline, color: VytalColors.textSecondary),
        ),
      ),
    );
  }

  // Карточка для вызова пикера
  Widget _buildPickerCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent, // Minimalist
          border: Border.all(color: VytalColors.textSecondary, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: VytalColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: VytalColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,

                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: VytalColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,

                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: VytalColors.primaryAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
