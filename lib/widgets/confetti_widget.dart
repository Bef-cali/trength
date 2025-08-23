// lib/widgets/confetti_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart' as confetti_package;
import '../theme/app_colors.dart';

enum ConfettiStyle {
  large,
  small,
}

class ConfettiWidget extends StatefulWidget {
  final List<Color> colors;
  final double intensity;
  final ConfettiStyle style;
  final bool isActive;
  final VoidCallback? onComplete;
  
  const ConfettiWidget({
    Key? key,
    this.colors = const [
      AppColors.velvetMist,
      AppColors.velvetPale,
      AppColors.velvetHighlight,
      AppColors.velvetLight,
      Colors.white,
      Colors.yellow,
    ],
    this.intensity = 0.8,
    this.style = ConfettiStyle.large,
    this.isActive = true,
    this.onComplete,
  }) : super(key: key);
  
  @override
  _ConfettiWidgetState createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> {
  late confetti_package.ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    
    // Set 12-second duration as required
    _confettiController = confetti_package.ConfettiController(
      duration: const Duration(seconds: 12),
    );
    
    if (widget.isActive) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive && !oldWidget.isActive) {
      _startConfetti();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopConfetti();
    }
  }

  void _startConfetti() {
    _confettiController.play();
    
    // Call onComplete after 12 seconds if provided
    if (widget.onComplete != null) {
      Future.delayed(const Duration(seconds: 12), () {
        if (mounted) {
          widget.onComplete!();
        }
      });
    }
  }

  void _stopConfetti() {
    _confettiController.stop();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Custom path to draw stars for confetti particles
  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main confetti blast from center
        Align(
          alignment: Alignment.center,
          child: confetti_package.ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: confetti_package.BlastDirectionality.explosive,
            shouldLoop: false, // No loop, just 8-second duration
            colors: widget.colors,
            createParticlePath: _drawStar,
            // Adjust particle count based on style and intensity
            numberOfParticles: _getParticleCount(),
            emissionFrequency: _getEmissionFrequency(),
            gravity: 0.3,
            particleDrag: 0.05,
            // Set particle size based on style
            minimumSize: _getMinSize(),
            maximumSize: _getMaxSize(),
          ),
        ),
        
        // Additional side blasts for large style
        if (widget.style == ConfettiStyle.large) ...[
          // Left side blast
          Align(
            alignment: Alignment.centerLeft,
            child: confetti_package.ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 0, // Right direction
              shouldLoop: false,
              colors: widget.colors,
              numberOfParticles: (15 * widget.intensity).round(),
              emissionFrequency: 0.1,
              gravity: 0.2,
              minimumSize: const Size(8, 8),
              maximumSize: const Size(20, 20),
            ),
          ),
          
          // Right side blast
          Align(
            alignment: Alignment.centerRight,
            child: confetti_package.ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi, // Left direction
              shouldLoop: false,
              colors: widget.colors,
              numberOfParticles: (15 * widget.intensity).round(),
              emissionFrequency: 0.1,
              gravity: 0.2,
              minimumSize: const Size(8, 8),
              maximumSize: const Size(20, 20),
            ),
          ),
        ],
      ],
    );
  }

  int _getParticleCount() {
    if (widget.style == ConfettiStyle.large) {
      return (50 * widget.intensity).round().clamp(30, 100);
    } else {
      return (20 * widget.intensity).round().clamp(10, 40);
    }
  }

  double _getEmissionFrequency() {
    if (widget.style == ConfettiStyle.large) {
      return 0.02; // More frequent for large style
    } else {
      return 0.05; // Less frequent for small style
    }
  }

  Size _getMinSize() {
    if (widget.style == ConfettiStyle.large) {
      return const Size(10, 10);
    } else {
      return const Size(5, 5);
    }
  }

  Size _getMaxSize() {
    if (widget.style == ConfettiStyle.large) {
      return Size(30 * widget.intensity, 30 * widget.intensity);
    } else {
      return Size(15 * widget.intensity, 15 * widget.intensity);
    }
  }
}