// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../screens/exercise_browse_screen.dart';
import '../screens/split_list_screen.dart';
import '../screens/workout_dashboard_screen.dart';
import '../screens/workout_history_screen.dart';
import '../screens/progression_settings_screen.dart';
import '../screens/analytics/analytics_dashboard_screen.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar removed per request
      body: _buildCurrentScreen(),
      bottomNavigationBar: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: SafeArea(
          child: Container(
            height: 80,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.deepVelvet.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home,
                      label: 'Home',
                      index: 0,
                    ),
                    const SizedBox(width: 8),
                    _buildNavItem(
                      icon: Icons.fitness_center_outlined,
                      selectedIcon: Icons.fitness_center,
                      label: 'splits',
                      index: 1,
                    ),
                    const SizedBox(width: 8),
                    _buildNavItem(
                      icon: Icons.bar_chart_outlined,
                      selectedIcon: Icons.bar_chart,
                      label: 'analytics',
                      index: 2,
                    ),
                    const SizedBox(width: 8),
                    _buildNavItem(
                      icon: Icons.history_outlined,
                      selectedIcon: Icons.history,
                      label: 'history',
                      index: 3,
                    ),
                    const SizedBox(width: 8),
                    _buildNavItem(
                      icon: Icons.settings_outlined,
                      selectedIcon: Icons.settings,
                      label: 'setting',
                      index: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.05),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected 
                  ? Colors.white 
                  : Colors.white.withOpacity(0.6),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 10,
                color: isSelected 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const WorkoutDashboardScreen(); // Home dashboard
      case 1:
        return const ExerciseBrowseScreen(); // Exercise database
      case 2:
        return const AnalyticsDashboardScreen(); // Analytics dashboard
      case 3:
        return const WorkoutHistoryScreen(); // Workout history
      case 4:
        return const ProgressionSettingsScreen(); // Settings
      default:
        return const WorkoutDashboardScreen();
    }
  }
}
