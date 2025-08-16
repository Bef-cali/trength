import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/workout_provider.dart';

class StreakTrackerWidget extends StatelessWidget {
  const StreakTrackerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final streakData = _calculateWeeklyStreak(workoutProvider);
        final currentStreak = _calculateCurrentStreak(workoutProvider);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.royalVelvet,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Week days row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDayColumn('mon', streakData[0]),
                  _buildDayColumn('tue', streakData[1]),
                  _buildDayColumn('wed', streakData[2]),
                  _buildDayColumn('thu', streakData[3]),
                  _buildDayColumn('fri', streakData[4]),
                  _buildDayColumn('sat', streakData[5]),
                  _buildDayColumn('sun', streakData[6]),
                ],
              ),
              const SizedBox(height: 16),
              // Streak count text
              Text(
                '$currentStreak Days of consistency',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayColumn(String dayName, WorkoutDayStatus status) {
    Color iconColor;
    switch (status) {
      case WorkoutDayStatus.completed:
        iconColor = Colors.green;
        break;
      case WorkoutDayStatus.missed:
        iconColor = Colors.red;
        break;
      case WorkoutDayStatus.today:
        iconColor = Colors.green;
        break;
      case WorkoutDayStatus.restDay:
        iconColor = Colors.grey;
        break;
      case WorkoutDayStatus.future:
      default:
        iconColor = Colors.grey.withOpacity(0.5);
        break;
    }

    return Column(
      children: [
        Text(
          dayName,
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        SvgPicture.asset(
          'assets/images/dumbbell.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }

  List<WorkoutDayStatus> _calculateWeeklyStreak(WorkoutProvider workoutProvider) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final workouts = workoutProvider.getWorkoutHistory();
    
    List<WorkoutDayStatus> weekStatus = [];
    
    // First, determine if each day has a workout
    List<bool> hasWorkoutList = [];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final isFuture = day.isAfter(now);
      
      if (isFuture) {
        hasWorkoutList.add(false); // Future days count as no workout
      } else {
        final hasWorkout = workouts.any((workout) {
          final workoutDate = workout.startTime;
          return workoutDate.day == day.day && 
                 workoutDate.month == day.month && 
                 workoutDate.year == day.year &&
                 workout.isCompleted;
        });
        hasWorkoutList.add(hasWorkout);
      }
    }
    
    // Now determine status based on consecutive missed days logic
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
      final isFuture = day.isAfter(now);
      
      if (isFuture) {
        weekStatus.add(WorkoutDayStatus.future);
      } else if (hasWorkoutList[i]) {
        weekStatus.add(isToday ? WorkoutDayStatus.today : WorkoutDayStatus.completed);
      } else {
        // No workout this day - check if it's consecutive missed days
        bool isConsecutiveMiss = false;
        
        // Check if previous day was also missed (for consecutive logic)
        if (i > 0 && !hasWorkoutList[i - 1]) {
          isConsecutiveMiss = true;
        }
        // Check if next day was also missed (for consecutive logic)
        else if (i < 6 && !hasWorkoutList[i + 1]) {
          isConsecutiveMiss = true;
        }
        
        // If this is part of 2+ consecutive missed days, mark as red
        if (isConsecutiveMiss) {
          weekStatus.add(WorkoutDayStatus.missed); // Red
        } else {
          weekStatus.add(WorkoutDayStatus.restDay); // Gray (1 missed day = rest day)
        }
      }
    }
    
    return weekStatus;
  }

  int _calculateCurrentStreak(WorkoutProvider workoutProvider) {
    final workouts = workoutProvider.getWorkoutHistory();
    if (workouts.isEmpty) return 0;
    
    final now = DateTime.now();
    int streak = 0;
    int consecutiveMissedDays = 0;
    
    // Check from today backwards
    for (int i = 0; i < 60; i++) { // Check last 60 days max
      final day = now.subtract(Duration(days: i));
      final hasWorkout = workouts.any((workout) {
        final workoutDate = workout.startTime;
        return workoutDate.day == day.day && 
               workoutDate.month == day.month && 
               workoutDate.year == day.year &&
               workout.isCompleted;
      });
      
      if (hasWorkout) {
        // Reset consecutive missed days counter
        consecutiveMissedDays = 0;
        streak++;
      } else {
        // Increment consecutive missed days
        consecutiveMissedDays++;
        
        // If we hit 2 consecutive missed days, streak is broken
        if (consecutiveMissedDays >= 2) {
          break;
        }
        // If it's just 1 missed day (rest day), continue counting streak
        // but don't increment the streak counter
      }
    }
    
    return streak;
  }
}

enum WorkoutDayStatus {
  completed,
  missed,
  today,
  future,
  restDay,
}