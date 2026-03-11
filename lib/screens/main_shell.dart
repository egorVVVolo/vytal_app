import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'dashboard_screen.dart';
import 'growth_screen.dart';
import 'plan_screen.dart';
import 'profile_screen.dart';
import 'training_hub_screen.dart';

class MainShell extends StatefulWidget {
  final String userName;
  final List<String> userGoals;

  const MainShell({super.key, required this.userName, required this.userGoals});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(userName: widget.userName), // 0: Dashboard
      const GrowthScreen(), // 1: Growth Lab
      const TrainingHubScreen(), // 2: Kinetic Lab
      const PlanScreen(), // 3: Plan
      const ProfileScreen(), // 4: Profile
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      // IndexedStack preserves state
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: VytalColors.background, // Match pure background
          border: Border(
            top: BorderSide(
              color: VytalColors.primaryNeon.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: VytalColors.primaryNeon.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: VytalColors.primaryNeon,
          unselectedItemColor: VytalColors.textSecondary.withValues(alpha: 0.5),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1,

          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,

          ),
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'DASH',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.height_rounded),
              label: 'GROWTH',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded),
              label: 'LAB',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'PLAN',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}
