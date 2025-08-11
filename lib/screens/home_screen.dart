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
        decoration: BoxDecoration(
          color: AppColors.deepVelvet,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBlack.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: AppColors.deepVelvet,
          selectedItemColor: AppColors.velvetMist,
          unselectedItemColor: AppColors.velvetLight.withOpacity(0.7),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_view_day),
              label: 'Splits',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const WorkoutDashboardScreen(); // Home dashboard with workout module
      case 1:
        return const SplitListScreen(); // Workout splits screen
      case 2:
        return const WorkoutHistoryScreen(); // Workout history screen
      case 3:
        return const AnalyticsDashboardScreen(); // Analytics dashboard screen
      case 4:
        return const ProgressionSettingsScreen(); // Progression settings screen
      default:
        return const WorkoutDashboardScreen();
    }
  }
}
