// lib/widgets/analytics/strength_chart_widget.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';

class StrengthChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>>? strengthProgressData;

  const StrengthChartWidget({Key? key, required this.strengthProgressData}) : super(key: key);

  @override
  _StrengthChartWidgetState createState() => _StrengthChartWidgetState();
}

class _StrengthChartWidgetState extends State<StrengthChartWidget> {
  int _selectedExerciseIndex = 0;

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
          // Clean header with exercise name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Strength Progress',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exerciseName,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Horizontal scrollable exercise selection chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.strengthProgressData!.length,
              itemBuilder: (context, index) {
                final exercise = widget.strengthProgressData![index];
                final isSelected = index == _selectedExerciseIndex;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      exercise['exerciseName'] as String,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedExerciseIndex = index;
                        });
                      }
                    },
                    backgroundColor: AppColors.deepVelvet.withOpacity(0.5),
                    selectedColor: AppColors.velvetPale.withOpacity(0.3),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.velvetPale : Colors.white30,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Strength progress information
          Row(
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

          const SizedBox(height: 16),

          // Line chart
          Expanded(
            child: performances.length > 1
                ? _buildLineChart(performances)
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

  Widget _buildLineChart(List<Map<String, dynamic>> performances) {
    // Sort performances by date to ensure chronological order (earliest to latest)
    final sortedPerformances = List<Map<String, dynamic>>.from(performances);
    sortedPerformances.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateA.compareTo(dateB); // Ascending order: earliest dates on left
    });
    
    // Extract data points with chronologically sorted data
    final spots = sortedPerformances.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final performance = entry.value;
      return FlSpot(index, performance['weight']);
    }).toList();

    // Find min and max values for y-axis
    double dataMinY = spots.map((spot) => spot.y).reduce(
          (min, value) => value < min ? value : min,
        );
    double dataMaxY = spots.map((spot) => spot.y).reduce(
          (max, value) => value > max ? value : max,
        );

    // Calculate appropriate interval first
    final interval = _calculateYAxisInterval(dataMinY, dataMaxY);
    
    // Align min and max to nice intervals
    final minY = (dataMinY / interval).floor() * interval;
    final maxY = (dataMaxY / interval).ceil() * interval;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateYAxisInterval(minY, maxY),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= sortedPerformances.length || value.toInt() < 0) {
                  return const SizedBox.shrink();
                }

                // Show date for some data points
                if (sortedPerformances.length < 5 ||
                    value.toInt() == 0 ||
                    value.toInt() == sortedPerformances.length - 1 ||
                    value.toInt() % (sortedPerformances.length ~/ 3) == 0) {

                  final date = sortedPerformances[value.toInt()]['date'] as DateTime;
                  final dateStr = DateFormat('MM/dd').format(date);

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dateStr,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _calculateYAxisInterval(minY, maxY),
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: (sortedPerformances.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.velvetMist,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                // Highlight first and last dots
                final isFirstOrLast = index == 0 || index == sortedPerformances.length - 1;

                return FlDotCirclePainter(
                  radius: isFirstOrLast ? 4 : 3,
                  color: AppColors.velvetMist,
                  strokeWidth: isFirstOrLast ? 2 : 0,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.velvetMist.withOpacity(0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppColors.deepVelvet.withOpacity(0.8),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final performance = sortedPerformances[barSpot.x.toInt()];
                final date = performance['date'] as DateTime;
                final weight = performance['weight'];
                final reps = performance['reps'];

                final dateStr = DateFormat('MMM d, y').format(date);

                return LineTooltipItem(
                  '$dateStr\n',
                  const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: '$weight kg × $reps reps',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // Calculate appropriate Y-axis interval for better spacing
  double _calculateYAxisInterval(double minY, double maxY) {
    final range = maxY - minY;
    
    if (range <= 0) return 1.0; // Default fallback
    
    // Target around 4-6 evenly spaced intervals
    final targetIntervals = 5;
    final rawInterval = range / targetIntervals;
    
    // Find the power of 10 for the raw interval
    final magnitude = (rawInterval).abs();
    final power = (magnitude > 0) ? (math.log(magnitude) / math.log(10)).floor() : 0;
    final base = math.pow(10.0, power.toDouble()).toDouble();
    
    // Normalize to 1-10 range
    final normalized = magnitude / base;
    
    // Choose nice interval values
    double niceInterval;
    if (normalized <= 1.0) {
      niceInterval = 1.0;
    } else if (normalized <= 2.0) {
      niceInterval = 2.0;
    } else if (normalized <= 5.0) {
      niceInterval = 5.0;
    } else {
      niceInterval = 10.0;
    }
    
    return niceInterval * base;
  }
}
