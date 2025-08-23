// lib/widgets/total_workout_timer_widget.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TotalWorkoutTimerWidget extends StatelessWidget {
  final Duration workoutDuration;

  const TotalWorkoutTimerWidget({
    Key? key,
    required this.workoutDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format duration as HH:MM:SS or MM:SS depending on length
    final hours = workoutDuration.inHours;
    final minutes = workoutDuration.inMinutes.remainder(60);
    final seconds = workoutDuration.inSeconds.remainder(60);
    
    final timeString = hours > 0 
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: AppColors.velvetHighlight,
      child: Row(
        children: [
          // Timer icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.velvetPale,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Timer text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workout Duration',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                timeString,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
              ),
            ],
          ),

          const Spacer(),

          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.velvetMist.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.velvetMist.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(
                color: AppColors.velvetMist,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}