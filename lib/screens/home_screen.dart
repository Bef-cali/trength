// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../screens/exercise_browse_screen.dart';
import '../screens/workout_dashboard_screen.dart';
import '../screens/templates_screen.dart';
import '../screens/progression_settings_screen.dart';
import '../screens/analytics/analytics_dashboard_screen.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isNavBarVisible = true;
  double _lastScrollOffset = 0.0;
  Timer? _autoShowTimer;
  Timer? _debounceTimer;
  late AnimationController _navBarAnimationController;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _navBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navBarAnimationController.forward(); // Start visible
  }

  @override
  void dispose() {
    _navBarAnimationController.dispose();
    _autoShowTimer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final currentOffset = notification.metrics.pixels;
      final delta = currentOffset - _lastScrollOffset;
      
      // Only react to significant scroll movements (reduced to 2px)
      if (delta.abs() < 2) return;
      
      // Debounce rapid scroll events
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        
        bool shouldShowNavBar = _isNavBarVisible;
        
        // Always show at top of page
        if (currentOffset <= 10) {
          shouldShowNavBar = true;
        }
        // Hide when scrolling down, show when scrolling up
        else if (delta > 0 && _isNavBarVisible && !_isAnimating) {
          // Scrolling down - hide navbar
          shouldShowNavBar = false;
        } else if (delta < 0 && !_isNavBarVisible && !_isAnimating) {
          // Scrolling up - show navbar
          shouldShowNavBar = true;
        }
        
        // Only update if state actually needs to change
        if (shouldShowNavBar != _isNavBarVisible && !_isAnimating) {
          _updateNavBarVisibility(shouldShowNavBar);
        }
      });
      
      _lastScrollOffset = currentOffset;
      
      // Auto-show navbar after user stops scrolling (increased to 6 seconds)
      _autoShowTimer?.cancel();
      _autoShowTimer = Timer(const Duration(seconds: 6), () {
        if (!_isNavBarVisible && mounted && !_isAnimating) {
          _updateNavBarVisibility(true);
        }
      });
    }
  }
  
  void _updateNavBarVisibility(bool shouldShow) {
    if (_isAnimating || _isNavBarVisible == shouldShow) return;
    
    setState(() {
      _isNavBarVisible = shouldShow;
      _isAnimating = true;
    });
    
    if (_isNavBarVisible) {
      _navBarAnimationController.forward().then((_) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
          });
        }
      });
    } else {
      _navBarAnimationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar removed per request
      extendBody: true,
      body: Stack(
        children: [
          // Main content with scroll detection
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              _handleScroll(scrollNotification);
              return false;
            },
            child: _buildCurrentScreen(),
          ),
          // Floating navigation bar with animation
          AnimatedBuilder(
            animation: _navBarAnimationController,
            builder: (context, child) {
              return Positioned(
                bottom: 16 - (80 * (1 - _navBarAnimationController.value)),
                left: 24,
                right: 24,
                child: Opacity(
                  opacity: _navBarAnimationController.value,
                  child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.royalVelvet,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, "assets/images/home.svg", "Home", Colors.white),
                  _buildNavItem(1, "assets/images/split.svg", "Splits", Colors.white),
                  _buildNavItem(2, "assets/images/analytics.svg", "Analytics", Colors.white),
                  _buildNavItem(3, "assets/images/history.svg", "History", Colors.white),
                  _buildNavItem(4, "assets/images/user settings.svg", "Settings", Colors.white),
                ],
              ), // Closes Row
                  ), // Closes Container
                ), // Closes Opacity
              ); // Closes Positioned
            }, // Closes builder
          ), // Closes AnimatedBuilder
        ],
      ),
    );
  }


  Widget _buildCurrentScreen() {
    Widget screen;
    switch (_selectedIndex) {
      case 0:
        screen = const WorkoutDashboardScreen(); // Home dashboard
        break;
      case 1:
        screen = const ExerciseBrowseScreen(); // Splits and exercises
        break;
      case 2:
        screen = const AnalyticsDashboardScreen(); // Analytics dashboard
        break;
      case 3:
        screen = const TemplatesScreen(); // Templates
        break;
      case 4:
        screen = const ProgressionSettingsScreen(); // Settings
        break;
      default:
        screen = const WorkoutDashboardScreen();
    }
    
    // Let content scroll naturally behind the floating navbar
    return screen;
  }

  Widget _buildNavItem(int index, String svgAsset, String label, Color selectedColor) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 10 : 6,
          vertical: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 26,
              height: 26,
              colorFilter: ColorFilter.mode(
                isSelected ? selectedColor : AppColors.velvetPale,
                BlendMode.srcIn,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: isSelected ? null : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                opacity: isSelected ? 1.0 : 0.0,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selectedColor,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
