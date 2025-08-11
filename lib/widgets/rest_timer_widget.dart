// lib/widgets/rest_timer_widget.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RestTimerWidget extends StatelessWidget {
  final int seconds;
  final bool isActive;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;

  const RestTimerWidget({
    Key? key,
    required this.seconds,
    required this.isActive,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the remaining time as mm:ss
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

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
              color: isActive
                  ? AppColors.velvetPale
                  : AppColors.velvetLight.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.timer : Icons.timer_off,
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
                'Rest Timer',
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

          // Timer controls
          Row(
            children: [
              // Pause/Resume button
              IconButton(
                icon: Icon(
                  isActive ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: isActive ? onPause : onResume,
              ),

              // Cancel button
              IconButton(
                icon: const Icon(
                  Icons.cancel,
                  color: Colors.white70,
                ),
                onPressed: onCancel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
