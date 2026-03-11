import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens and Services
import 'screens/legal_screen.dart';
import 'screens/onboarding_v2.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'theme/colors.dart';
import 'models/habit.dart';
import 'models/height_log.dart';
import 'models/posture_log.dart';

void main() {
  // Run app immediately
  runApp(const AppBootstrap());
}

/// Wrapper to load all required services
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  // State: 0=Loading, 1=Ready, 2=Error
  int _status = 0;
  String _errorMessage = "";

  // Startup Data
  bool _isFirstRun = true;
  String _savedName = "User";
  List<String> _savedGoals = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // 1. Firebase Init
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. Silent Login
      await AuthService.loginSilently();

      // 3. System UI
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      );

      // 4. Notifications
      await NotificationService().init();

      // 5. Hive (Local DB)
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(HabitAdapter());
      if (!Hive.isAdapterRegistered(0))
        Hive.registerAdapter(HabitTypeAdapter());
      if (!Hive.isAdapterRegistered(2))
        Hive.registerAdapter(HeightLogAdapter());
      if (!Hive.isAdapterRegistered(3))
        Hive.registerAdapter(PostureLogAdapter());

      // Open boxes
      await Hive.openBox<Habit>('habitsBox');
      await Hive.openBox<HeightLog>('heightBox');
      await Hive.openBox('settingsBox');
      await Hive.openBox<PostureLog>('postureBox');

      // 6. Check First Run
      _isFirstRun = await StorageService.isFirstRun();
      if (!_isFirstRun) {
        _savedName = await StorageService.getUserName();
        _savedGoals = await StorageService.getGoals();
      }

      // If all good, set Ready
      if (mounted) {
        setState(() => _status = 1);
      }
    } catch (e, stack) {
      print("CRITICAL ERROR: $e");
      print(stack);
      if (mounted) {
        setState(() {
          _status = 2;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == 2) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: VytalColors.background,
          fontFamily: 'Roboto',
        ),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: VytalColors.warningNeon,
                    size: 50,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "SYSTEM COMPROMISED",
                    style: TextStyle(
                      color: VytalColors.warningNeon,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: VytalColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_status == 0) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: VytalColors.background),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fingerprint,
                  size: 80,
                  color: VytalColors.primaryNeon,
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: VytalColors.primaryNeon),
                const SizedBox(height: 20),
                Text(
                  "VYTAL SYSTEM\nINITIALIZING...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: VytalColors.primaryNeon.withOpacity(0.5),
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return VytalApp(
      isFirstRun: _isFirstRun,
      initialName: _savedName,
      initialGoals: _savedGoals,
    );
  }
}

class VytalApp extends StatelessWidget {
  final bool isFirstRun;
  final String initialName;
  final List<String> initialGoals;

  const VytalApp({
    super.key,
    required this.isFirstRun,
    required this.initialName,
    required this.initialGoals,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vytal',
      theme: ThemeData(
        scaffoldBackgroundColor: VytalColors.background,
        // Optional: Switch to Google Fonts if the user prefers, but standardizing to Roboto/Monospace for now
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: VytalColors.primaryNeon,
          secondary: VytalColors.secondaryNeon,
          surface: VytalColors.surface,
          background: VytalColors.background,
          error: VytalColors.warningNeon,
        ),
      ),
      home: isFirstRun
          ? const LegalScreen()
          : MainShell(userName: initialName, userGoals: initialGoals),
    );
  }
}
