// lib/widgets/analytics/strength_chart_widget.dart
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';

class StrengthChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>>? strengthProgressData;

  const StrengthChartWidget({Key? key, required this.strengthProgressData}) : super(key: key);

  @override
  _StrengthChartWidgetState createState() => _StrengthChartWidgetState();
}

class _StrengthChartWidgetState extends State<StrengthChartWidget>
    with TickerProviderStateMixin {
  int _selectedExerciseIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _lineAnimation;
  late Animation<double> _dotAnimation;
  int _touchIndex = -1;
  bool _showingTooltip = false;
  Timer? _tooltipTimer;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _lineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _dotAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tooltipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.strengthProgressData == null || widget.strengthProgressData!.isEmpty) {
      return _buildEmptyState();
    }

    // Get the selected exercise data
    final selectedExercise = widget.strengthProgressData![_selectedExerciseIndex];
    final exerciseName = selectedExercise['exerciseName'] as String;
    final performances = selectedExercise['performances'] as List<Map<String, dynamic>>;

    // Remove progress percentage calculation

    return Container(
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Combined exercise selection and stats row
          Row(
            children: [
              // Pill-shaped exercise dropdown
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.deepVelvet.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.velvetPale.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedExerciseIndex,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withOpacity(0.7),
                      size: 18,
                    ),
                    dropdownColor: AppColors.deepVelvet,
                    borderRadius: BorderRadius.circular(12),
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    items: widget.strengthProgressData!.asMap().entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(
                          entry.value['exerciseName'] as String,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newIndex) {
                      if (newIndex != null && newIndex != _selectedExerciseIndex) {
                        setState(() {
                          _selectedExerciseIndex = newIndex;
                        });
                        _animationController.reset();
                        _animationController.forward();
                      }
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Stats row
              Expanded(
                child: Row(
                  children: [
                    _buildInfoItem(
                      'Starting',
                      '${selectedExercise['startWeight']} kg',
                    ),
                    _buildInfoItem(
                      'Current',
                      '${selectedExercise['currentWeight']} kg',
                    ),
                    _buildInfoItem(
                      'Increase',
                      '${selectedExercise['increase']} kg',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SwiftUI-style chart
          Expanded(
            child: performances.length > 1
                ? _buildSwiftUIChart(performances)
                : Center(
                    child: Text(
                      'Not enough data points to show a trend',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: AppColors.velvetLight.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No strength progress data available',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.velvetLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete more workouts to track your strength progress',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                color: AppColors.velvetLight.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwiftUIChart(List<Map<String, dynamic>> performances) {
    // Sort performances by date
    final sortedPerformances = List<Map<String, dynamic>>.from(performances);
    sortedPerformances.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateA.compareTo(dateB);
    });

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Main chart area
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (details) => _handleTouchStart(details, sortedPerformances),
                onPanUpdate: (details) => _handleTouchUpdate(details, sortedPerformances),
                onPanEnd: (details) => _handleTouchEnd(),
                onTapDown: (details) => _handleTouchStart(details, sortedPerformances),
                child: CustomPaint(
                  painter: AnalyticsSwiftUIChartPainter(
                    performances: sortedPerformances,
                    lineProgress: _lineAnimation.value,
                    dotProgress: _dotAnimation.value,
                    touchIndex: _touchIndex,
                    showingTooltip: _showingTooltip,
                  ),
                ),
              ),
            ),
            
            // Tooltip overlay
            if (_showingTooltip && _touchIndex >= 0 && _touchIndex < sortedPerformances.length)
              _buildTooltip(sortedPerformances[_touchIndex]),
          ],
        );
      },
    );
  }

  Widget _buildTooltip(Map<String, dynamic> performance) {
    return Positioned(
      top: 20,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.deepVelvet.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.velvetMist.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${performance['weight']} kg × ${performance['reps']} reps',
              style: const TextStyle(
                color: AppColors.velvetMist,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Quicksand',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEE, MMM d, yyyy').format(performance['date']),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                fontFamily: 'Quicksand',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTouchStart(dynamic details, List<Map<String, dynamic>> performances) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Calculate which data point is being touched
    final chartWidth = renderBox.size.width - 32; // Account for padding
    final pointWidth = chartWidth / (performances.length - 1);
    final touchIndex = (localPosition.dx - 16) / pointWidth;
    
    setState(() {
      _touchIndex = touchIndex.round().clamp(0, performances.length - 1);
      _showingTooltip = true;
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Auto-hide tooltip
    _tooltipTimer?.cancel();
    _tooltipTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showingTooltip = false;
          _touchIndex = -1;
        });
      }
    });
  }

  void _handleTouchUpdate(dynamic details, List<Map<String, dynamic>> performances) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    final chartWidth = renderBox.size.width - 32;
    final pointWidth = chartWidth / (performances.length - 1);
    final touchIndex = (localPosition.dx - 16) / pointWidth;
    
    final newIndex = touchIndex.round().clamp(0, performances.length - 1);
    if (newIndex != _touchIndex) {
      setState(() {
        _touchIndex = newIndex;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _handleTouchEnd() {
    _tooltipTimer?.cancel();
    _tooltipTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showingTooltip = false;
          _touchIndex = -1;
        });
      }
    });
  }
}

class AnalyticsSwiftUIChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> performances;
  final double lineProgress;
  final double dotProgress;
  final int touchIndex;
  final bool showingTooltip;

  AnalyticsSwiftUIChartPainter({
    required this.performances,
    required this.lineProgress,
    required this.dotProgress,
    required this.touchIndex,
    required this.showingTooltip,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (performances.isEmpty) return;

    // Calculate data bounds
    double minWeight = performances.map((p) => p['weight'] as double).reduce(math.min);
    double maxWeight = performances.map((p) => p['weight'] as double).reduce(math.max);
    
    // Add padding to the range
    final range = maxWeight - minWeight;
    final padding = range * 0.15; // More padding for analytics view
    minWeight = minWeight - padding;
    maxWeight = maxWeight + padding;

    // Create points
    final points = <Offset>[];
    for (int i = 0; i < performances.length; i++) {
      final x = (size.width * i / (performances.length - 1)).clamp(6.0, size.width - 6.0);
      final weight = performances[i]['weight'] as double;
      final normalizedWeight = (weight - minWeight) / (maxWeight - minWeight);
      final y = (size.height - (size.height * normalizedWeight)).clamp(6.0, size.height - 6.0);
      points.add(Offset(x, y));
    }

    // Draw grid lines
    _drawGridLines(canvas, size, minWeight, maxWeight);
    
    // Draw the progressive line with gradient
    _drawProgressiveLine(canvas, points, size);
    
    // Draw touch indicator line
    if (showingTooltip && touchIndex >= 0 && touchIndex < points.length) {
      _drawTouchIndicator(canvas, points[touchIndex], size);
    }
    
    // Draw data points
    _drawDataPoints(canvas, points);
    
    // Draw pulsing dot at the end
    _drawPulsingDot(canvas, points.last);
  }

  void _drawGridLines(Canvas canvas, Size size, double minWeight, double maxWeight) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.0;

    final range = maxWeight - minWeight;
    final gridInterval = _calculateGridInterval(range);
    
    // Draw horizontal grid lines
    final startValue = (minWeight / gridInterval).ceil() * gridInterval;
    for (double value = startValue; value <= maxWeight; value += gridInterval) {
      final normalizedValue = (value - minWeight) / (maxWeight - minWeight);
      final y = size.height - (size.height * normalizedValue);
      
      if (y >= 0 && y <= size.height) {
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          gridPaint,
        );
      }
    }
  }

  double _calculateGridInterval(double range) {
    if (range <= 5) return 1;
    if (range <= 20) return 5;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    return 50;
  }

  void _drawProgressiveLine(Canvas canvas, List<Offset> points, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFF77FD94)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF77FD94).withOpacity(0.15),
          const Color(0xFF77FD94).withOpacity(0.08),
          const Color(0xFF77FD94).withOpacity(0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create smooth path with quadratic curves (SwiftUI style)
    final path = Path();
    final gradientPath = Path();
    
    path.moveTo(points[0].dx, points[0].dy);
    gradientPath.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 0; i < points.length - 1; i++) {
      final currentPoint = points[i];
      final nextPoint = points[i + 1];
      final midPoint = Offset(
        (currentPoint.dx + nextPoint.dx) / 2,
        (currentPoint.dy + nextPoint.dy) / 2,
      );
      
      path.quadraticBezierTo(currentPoint.dx, currentPoint.dy, midPoint.dx, midPoint.dy);
      gradientPath.quadraticBezierTo(currentPoint.dx, currentPoint.dy, midPoint.dx, midPoint.dy);
    }
    
    path.lineTo(points.last.dx, points.last.dy);
    gradientPath.lineTo(points.last.dx, points.last.dy);

    // Create clipping path for progressive animation
    final clippingPath = Path();
    final progressWidth = size.width * lineProgress;
    clippingPath.addRect(Rect.fromLTWH(0, 0, progressWidth, size.height));

    canvas.save();
    canvas.clipPath(clippingPath);
    
    // Draw gradient fill
    gradientPath.lineTo(points.last.dx, size.height);
    gradientPath.lineTo(points.first.dx, size.height);
    gradientPath.close();
    canvas.drawPath(gradientPath, gradientPaint);
    
    // Draw main line
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawTouchIndicator(Canvas canvas, Offset point, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF77FD94).withOpacity(0.7)
      ..strokeWidth = 2.0;

    // Draw vertical line
    canvas.drawLine(
      Offset(point.dx, 0),
      Offset(point.dx, size.height),
      linePaint,
    );

    // Draw touch point with glow effect
    final glowPaint = Paint()
      ..color = const Color(0xFF77FD94).withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(point, 12, glowPaint);
    
    final dotPaint = Paint()
      ..color = const Color(0xFF77FD94)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(point, 5, dotPaint);
  }

  void _drawDataPoints(Canvas canvas, List<Offset> points) {
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isEndpoint = i == 0 || i == points.length - 1;
      
      // Draw subtle data points (except the last one which gets the pulsing dot)
      if (i != points.length - 1) {
        final dotPaint = Paint()
          ..color = const Color(0xFF77FD94).withOpacity(0.8)
          ..style = PaintingStyle.fill;

        final strokePaint = Paint()
          ..color = AppColors.royalVelvet
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(point, isEndpoint ? 4 : 3, strokePaint);
        canvas.drawCircle(point, isEndpoint ? 4 : 3, dotPaint);
      }
    }
  }

  void _drawPulsingDot(Canvas canvas, Offset point) {
    if (dotProgress == 0) return;

    // Outer pulsing circle with enhanced animation
    final outerPaint = Paint()
      ..color = const Color(0xFF77FD94).withOpacity(0.4 * dotProgress)
      ..style = PaintingStyle.fill;

    final time = DateTime.now().millisecondsSinceEpoch / 300;
    final pulseRadius = 10 + (6 * math.sin(time));
    canvas.drawCircle(point, pulseRadius * dotProgress, outerPaint);

    // Middle ring
    final middlePaint = Paint()
      ..color = const Color(0xFF77FD94).withOpacity(0.6 * dotProgress)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(point, 6 * dotProgress, middlePaint);

    // Inner solid dot with white border
    final borderPaint = Paint()
      ..color = AppColors.royalVelvet
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final innerPaint = Paint()
      ..color = const Color(0xFF77FD94)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(point, 5 * dotProgress, borderPaint);
    canvas.drawCircle(point, 5 * dotProgress, innerPaint);
  }

  @override
  bool shouldRepaint(AnalyticsSwiftUIChartPainter oldDelegate) {
    return oldDelegate.lineProgress != lineProgress ||
           oldDelegate.dotProgress != dotProgress ||
           oldDelegate.touchIndex != touchIndex ||
           oldDelegate.showingTooltip != showingTooltip;
  }
}
