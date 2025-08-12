// lib/widgets/personal_record_celebration.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PersonalRecordCelebration extends StatefulWidget {
  final VoidCallback onClose;
  final String? exerciseName;
  final double? oneRM;
  final String? formula;
  final double? originalWeight;
  final int? originalReps;

  const PersonalRecordCelebration({
    Key? key,
    required this.onClose,
    this.exerciseName,
    this.oneRM,
    this.formula,
    this.originalWeight,
    this.originalReps,
  }) : super(key: key);

  @override
  _PersonalRecordCelebrationState createState() => _PersonalRecordCelebrationState();
}

class _PersonalRecordCelebrationState extends State<PersonalRecordCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Using ClampedSimulation to ensure values stay within range
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      // Using a safer curve that doesn't overshoot
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Safer approach to auto-close after animation
    // Using a status listener instead of then()
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          widget.onClose();
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Safely handle tap to close
        if (_controller.isAnimating) {
          _controller.stop();
        }
        widget.onClose();
      },
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: AppColors.velvetPale,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trophy icon with glow effect
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.velvetHighlight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.velvetPale.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),

          // Personal Record text
          const Text(
            'NEW 1-REP MAX PR!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Exercise name if provided
          if (widget.exerciseName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.velvetHighlight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.exerciseName!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 1RM details if provided
          if (widget.oneRM != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.deepVelvet.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.velvetMist.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '${widget.oneRM!.toStringAsFixed(1)}kg',
                    style: const TextStyle(
                      color: AppColors.velvetMist,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Est. 1-Rep Max',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.originalWeight != null && widget.originalReps != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'from ${widget.originalWeight!.toStringAsFixed(1)}kg × ${widget.originalReps} reps',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (widget.formula != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${widget.formula!.toUpperCase()} formula',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Motivational message
          Text(
            'Keep crushing it! 💪',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Tap to dismiss note
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.1),
            ),
            child: const Text(
              'Tap anywhere to continue',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
