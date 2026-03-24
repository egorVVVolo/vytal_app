import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic
import 'package:flutter_animate/flutter_animate.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/colors.dart';
import '../widgets/stats_hexagon.dart';
import '../widgets/profile_menu_item.dart';
import '../services/storage_service.dart';
import 'edit_profile_screen.dart';
import '../utils/l10n.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Screenshot controller
  final ScreenshotController _screenshotController = ScreenshotController();

  String _name = "Loading...";
  double _weight = 0;
  double _height = 0;
  int _age = 0;

  int _xp = 0;
  int _level = 1;
  double _levelProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final name = await StorageService.getUserName();
    final bio = await StorageService.getBiometrics();
    final xp = await StorageService.getXP();

    // Level 1: 0-99 XP
    int level = (xp / 100).floor() + 1;
    int xpInCurrentLevel = xp % 100;
    double progress = xpInCurrentLevel / 100.0;

    if (mounted) {
      setState(() {
        _name = name;
        _weight = bio['weight'] ?? 70.0;
        _height = bio['height'] ?? 175.0;
        _age = bio['age'] ?? 18;
        _xp = xp;
        _level = level;
        _levelProgress = progress;
      });
    }
  }

  void _openEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(onSave: () => _loadData()),
      ),
    );
  }

  // --- SHARING LOGIC ---
  Future<void> _shareStats() async {
    if (StorageService.getSetting('haptic')) HapticFeedback.mediumImpact();

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text("Generating card..."),
        duration: Duration(milliseconds: 500),
      ),
    );

    try {
      // 1. Capture widget to image
      final Uint8List? image = await _screenshotController.capture();

      if (image != null) {
        // 2. Save to temporary file
        final directory = await getTemporaryDirectory();
        final imagePath = await File(
          '${directory.path}/vytal_stats.png',
        ).create();
        await imagePath.writeAsBytes(image);

        // 3. Native share dialog
        await Share.shareXFiles([
          XFile(imagePath.path),
        ], text: 'My biohacking progress in Vytal: Level $_level 🧬');
      }
    } catch (e) {
      debugPrint("Share error: $e");
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("Error sharing data"),
            backgroundColor: VytalColors.warningAccent,
          ),
        );
      }
    }
  }

  void _showHexagonInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VytalColors.surface, // Minimal black
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: VytalColors.textSecondary),
        ),
        title: const Text(
          "Biohacker Metrics",
          style: TextStyle(
            color: VytalColors.textPrimary,
            fontWeight: FontWeight.bold,

            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _InfoRow("Height", "% of genetic potential"),
            _InfoRow("Sleep", "7-day routine quality"),
            _InfoRow("Posture", "Score of latest AI scan"),
            _InfoRow("Body", "Body Mass Index (BMI)"),
            _InfoRow("Focus", "Depends on Level rating"),
            _InfoRow("Routine", "Daily plan completion streak"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "GOT IT",
              style: TextStyle(
                color: VytalColors.primaryAccent,

                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: VytalColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (ctx) => const _RealSettingsSheet(),
    );
  }

  void _showDevicesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: VytalColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (ctx) => const _DevicesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 340,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        VytalColors.primaryAccent.withValues(alpha: 0.1),
                        VytalColors.background,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    tooltip: 'Edit Profile',
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: VytalColors.textSecondary,
                    ),
                    tooltip: 'Edit Profile',
                    tooltip: "Edit Profile",
                    onPressed: _openEdit,
                  ).animate().fadeIn(),
                ),
                Positioned(
                  top: 60,
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: VytalColors.primaryAccent,
                            width: 1, // Thinner border
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: VytalColors.primaryAccent.withValues(alpha:
                                0.1,
                              ), // Reduced glow
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: VytalColors.surface,
                          child: Text(
                            _name.isNotEmpty ? _name.characters.first.toUpperCase() : "?",
                            style: const TextStyle(
                              fontSize: 36,
                              color: VytalColors.textPrimary,
                            ),
                          ),
                        ),
                      ).animate().scale(
                        curve: Curves.easeOutBack,
                        duration: 600.ms,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: VytalColors.textPrimary,
                          letterSpacing: 1,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 8),
                      // LEVEL
                      Column(
                        children: [
                          Text(
                            "${L10n.t('level')} $_level ${L10n.t('biohacker')}",
                            style: const TextStyle(
                              color: VytalColors.primaryAccent,
                              fontSize: 12,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,

                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 120,
                            height: 6,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: LinearProgressIndicator(
                                value: _levelProgress,
                                backgroundColor: VytalColors.textSecondary.withValues(alpha: 0.2),
                                color: VytalColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$_xp ${L10n.t('xp_total')}",
                            style: TextStyle(
                              color: VytalColors.textPrimary.withValues(alpha: 0.4),
                              fontSize: 10,

                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
              ],
            ),

            // --- SCREENSHOT AREA ---
            Screenshot(
              controller: _screenshotController,
              child: Container(
                color: VytalColors.background,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
                      child: StatsHexagon(
                        scoreHeight: (_height / 190 * 100).clamp(0, 100),
                        scoreSleep: 82,
                        scorePosture: 45, // Map to real data if required
                        scoreBody: (_weight / 80 * 100).clamp(0, 100),
                        scoreFocus: (_level * 10.0).clamp(0, 100),
                        scoreRoutine: (_xp / 500 * 100).clamp(0, 100),
                      ),
                    ).animate().scale(curve: Curves.easeOutBack, delay: 400.ms),
                    IconButton(
                      tooltip: 'Biohacker Metrics Info',
                      icon: const Icon(
                        Icons.info_outline,
                        color: VytalColors.textSecondary,
                        size: 20,
                      ),
                      tooltip: 'Score Information',
                      tooltip: "Metrics Info",
                      onPressed: _showHexagonInfo,
                    ),
                  ],
                ),
              ),
            ),

            // Share Button
            TextButton.icon(
              onPressed: _shareStats,
              icon: const Icon(
                Icons.share,
                color: VytalColors.primaryAccent,
                size: 16,
              ),
              label: Text(
                L10n.t('share_progress'),
                style: const TextStyle(
                  color: VytalColors.primaryAccent,
                  letterSpacing: 1,
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 30),

            // --- BIOMETRICS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.transparent, // Transparent for minimalism
                  border: Border.all(color: VytalColors.textSecondary, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMiniStat(L10n.t('weight'), _weight.toStringAsFixed(1), "kg"),
                    Container(width: 1, height: 30, color: VytalColors.textSecondary),
                    _buildMiniStat(L10n.t('height'), _height.toStringAsFixed(0), "cm"),
                    Container(width: 1, height: 30, color: VytalColors.textSecondary),
                    _buildMiniStat(L10n.t('age'), _age.toString(), "yrs"),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
            ),

            const SizedBox(height: 30),

            // --- MENU ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ProfileMenuItem(
                    title: L10n.t('my_devices'),
                    icon: Icons.watch_rounded,
                    onTap: _showDevicesSheet,
                  ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),
                  ProfileMenuItem(
                    title: L10n.t('settings'),
                    icon: Icons.settings_rounded,
                    onTap: _showSettingsSheet,
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1),
                  ProfileMenuItem(
                    title: L10n.t('reset_progress'),
                    icon: Icons.delete_forever_rounded,
                    isDestructive: true,
                    onTap: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      await StorageService.clearAll();
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(content: Text("Reset successful.")),
                        );
                        setState(() {
                          _loadData();
                        });
                      }
                    },
                  ).animate().fadeIn(delay: 900.ms).slideX(begin: 0.1),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: VytalColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,

          ),
        ),
        const SizedBox(height: 6),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: VytalColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,

              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(
                color: VytalColors.primaryAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- SETTINGS SHEET ---
class _RealSettingsSheet extends StatefulWidget {
  const _RealSettingsSheet();
  @override
  State<_RealSettingsSheet> createState() => _RealSettingsSheetState();
}

class _RealSettingsSheetState extends State<_RealSettingsSheet> {
  late bool _sound;
  late bool _haptic;
  late bool _notifs;

  @override
  void initState() {
    super.initState();
    _sound = StorageService.getSetting('sound', defaultValue: true);
    _haptic = StorageService.getSetting('haptic', defaultValue: true);
    _notifs = StorageService.getSetting('notifications', defaultValue: true);
  }

  void _update(String key, bool value) {
    setState(() {
      if (key == 'sound') _sound = value;
      if (key == 'haptic') _haptic = value;
      if (key == 'notifications') _notifs = value;
    });
    StorageService.saveSetting(key, value);
    if (_haptic) HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 350,
      child: Column(
        children: [
          const Text(
            "System Config",
            style: TextStyle(
              color: VytalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,

            ),
          ),
          const SizedBox(height: 20),
          _SwitchRow(
            label: "App Sounds",
            value: _sound,
            onChanged: (v) => _update('sound', v),
          ),
          _SwitchRow(
            label: "Haptic Feedback",
            value: _haptic,
            onChanged: (v) => _update('haptic', v),
          ),
          _SwitchRow(
            label: "Push Notifications",
            value: _notifs,
            onChanged: (v) => _update('notifications', v),
          ),
          const SizedBox(height: 20),
          const Divider(color: VytalColors.textSecondary),
          const SizedBox(height: 10),
          const Text(
            "Vytal v1.2.0 (Stable)",
            style: TextStyle(
              color: VytalColors.textSecondary,
              fontSize: 10,

            ),
          ),
        ],
      ),
    );
  }
}

// --- DEVICES SHEET ---
class _DevicesSheet extends StatefulWidget {
  const _DevicesSheet();
  @override
  State<_DevicesSheet> createState() => _DevicesSheetState();
}

class _DevicesSheetState extends State<_DevicesSheet> {
  bool _isAppleWatchConnected = false;
  bool _isOuraRingConnected = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _isAppleWatchConnected = StorageService.isDeviceConnected('apple_watch');
    _isOuraRingConnected = StorageService.isDeviceConnected('oura_ring');
  }

  void _toggleDevice(String key) async {
    setState(() => _isScanning = true);
    // Simulation logic
    await Future.delayed(const Duration(seconds: 2));
    await StorageService.toggleDeviceConnection(key);

    if (mounted) {
      setState(() {
        _isScanning = false;
        if (key == 'apple_watch') {
          _isAppleWatchConnected = !_isAppleWatchConnected;
        }
        if (key == 'oura_ring') _isOuraRingConnected = !_isOuraRingConnected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 400,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Data Sources",
                style: TextStyle(
                  color: VytalColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,

                ),
              ),
              if (_isScanning)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: VytalColors.primaryAccent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 30),
          _DeviceTile(
            name: "Apple Health",
            icon: Icons.favorite,
            isConnected: _isAppleWatchConnected,
            onTap: () => _toggleDevice('apple_watch'),
          ),
          const SizedBox(height: 16),
          _DeviceTile(
            name: "Oura Ring",
            icon: Icons.donut_large,
            isConnected: _isOuraRingConnected,
            onTap: () => _toggleDevice('oura_ring'),
          ),
          const Spacer(),
          const Text(
            "Connections allow automatic syncing of sleep and step data.",
            textAlign: TextAlign.center,
            style: TextStyle(color: VytalColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// --- HELPERS ---

class _DeviceTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isConnected;
  final VoidCallback onTap;
  const _DeviceTile({
    required this.name,
    required this.icon,
    required this.isConnected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isConnected
              ? VytalColors.primaryAccent.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border.all(
            color: isConnected ? VytalColors.primaryAccent : VytalColors.textSecondary,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isConnected ? VytalColors.primaryAccent : VytalColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      color: VytalColors.textPrimary,
                      fontWeight: FontWeight.bold,

                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    isConnected ? "Synchronized" : "Tap to connect",
                    style: TextStyle(
                      color: isConnected
                          ? VytalColors.primaryAccent
                          : VytalColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (isConnected)
              const Icon(
                Icons.check_circle,
                color: VytalColors.primaryAccent,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String text;
  const _InfoRow(this.label, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: VytalColors.primaryAccent,
                fontWeight: FontWeight.bold,

              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: VytalColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: VytalColors.textPrimary,

          fontSize: 12,
        ),
      ),
      value: value,
      activeThumbColor: VytalColors.primaryAccent,
      onChanged: onChanged,
    );
  }
}
