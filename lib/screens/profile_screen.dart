import 'dart:io';
import 'dart:typed_data';
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

    ScaffoldMessenger.of(context).showSnackBar(
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
      print("Share error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error sharing data"),
            backgroundColor: VytalColors.warningNeon,
          ),
        );
      }
    }
  }

  void _showHexagonInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black, // Minimal black
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: Colors.white10),
        ),
        title: const Text(
          "BIOHACKER METRICS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
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
                color: VytalColors.primaryNeon,
                fontFamily: 'monospace',
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
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (ctx) => const _RealSettingsSheet(),
    );
  }

  void _showDevicesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
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
                        VytalColors.primaryNeon.withOpacity(0.1),
                        VytalColors.background,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white54,
                    ),
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
                            color: VytalColors.primaryNeon,
                            width: 1, // Thinner border
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: VytalColors.primaryNeon.withOpacity(
                                0.1,
                              ), // Reduced glow
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: VytalColors.surface,
                          child: Text(
                            _name.isNotEmpty ? _name[0].toUpperCase() : "?",
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
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
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 8),
                      // LEVEL
                      Column(
                        children: [
                          Text(
                            "Level $_level Biohacker",
                            style: const TextStyle(
                              color: VytalColors.primaryNeon,
                              fontSize: 12,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 120,
                            height: 6,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: _levelProgress,
                                backgroundColor: Colors.white10,
                                color: VytalColors.primaryNeon,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$_xp XP Total",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 10,
                              fontFamily: 'monospace',
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
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.white24,
                        size: 20,
                      ),
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
                color: VytalColors.primaryNeon,
                size: 16,
              ),
              label: const Text(
                "SHARE PROGRESS",
                style: TextStyle(
                  color: VytalColors.primaryNeon,
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
                  border: Border.all(color: Colors.white10, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMiniStat("WEIGHT", _weight.toStringAsFixed(1), "kg"),
                    Container(width: 1, height: 30, color: Colors.white10),
                    _buildMiniStat("HEIGHT", _height.toStringAsFixed(0), "cm"),
                    Container(width: 1, height: 30, color: Colors.white10),
                    _buildMiniStat("AGE", _age.toString(), "yrs"),
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
                    title: "My Devices",
                    icon: Icons.watch_rounded,
                    onTap: _showDevicesSheet,
                  ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),
                  ProfileMenuItem(
                    title: "Settings",
                    icon: Icons.settings_rounded,
                    onTap: _showSettingsSheet,
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1),
                  ProfileMenuItem(
                    title: "Reset Progress",
                    icon: Icons.delete_forever_rounded,
                    isDestructive: true,
                    onTap: () async {
                      await StorageService.clearAll();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
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
            fontFamily: 'monospace',
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
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(
                color: VytalColors.primaryNeon,
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
            "SYSTEM CONFIG",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
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
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),
          const Text(
            "Vytal v1.2.0 (Stable)",
            style: TextStyle(
              color: Colors.white24,
              fontSize: 10,
              fontFamily: 'monospace',
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
        if (key == 'apple_watch')
          _isAppleWatchConnected = !_isAppleWatchConnected;
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
                "DATA SOURCES",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
              if (_isScanning)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: VytalColors.primaryNeon,
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
            style: TextStyle(color: Colors.white38, fontSize: 12),
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
              ? VytalColors.primaryNeon.withOpacity(0.05)
              : Colors.transparent,
          border: Border.all(
            color: isConnected ? VytalColors.primaryNeon : Colors.white10,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isConnected ? VytalColors.primaryNeon : Colors.white54,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    isConnected ? "Synchronized" : "Tap to connect",
                    style: TextStyle(
                      color: isConnected
                          ? VytalColors.primaryNeon
                          : Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (isConnected)
              const Icon(
                Icons.check_circle,
                color: VytalColors.primaryNeon,
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
                color: VytalColors.primaryNeon,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
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
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
      value: value,
      activeColor: VytalColors.primaryNeon,
      onChanged: onChanged,
    );
  }
}
