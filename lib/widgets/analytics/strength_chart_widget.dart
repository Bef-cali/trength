// lib/widgets/analytics/strength_chart_widget.dart
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

    // Calculate progress percentage
    final percentIncrease = selectedExercise['percentIncrease'] as double;
    final isPositive = percentIncrease >= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise selector and progress indicator
          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedExerciseIndex,
                    isDense: true,
                    dropdownColor: AppColors.deepVelvet,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: widget.strengthProgressData!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text(
                          exercise['exerciseName'] as String,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (index) {
                      if (index != null) {
                        setState(() {
                          _selectedExerciseIndex = index;
                        });
                      }
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percentIncrease.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    // Extract data points
    final spots = performances.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final performance = entry.value;
      return FlSpot(index, performance['weight']);
    }).toList();

    // Find min and max values for y-axis
    double minY = spots.map((spot) => spot.y).reduce(
          (min, value) => value < min ? value : min,
        );
    double maxY = spots.map((spot) => spot.y).reduce(
          (max, value) => value > max ? value : max,
        );

    // Add some padding to the y-axis range
    final yPadding = (maxY - minY) * 0.1;
    minY = minY > yPadding ? minY - yPadding : 0;
    maxY = maxY + yPadding;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
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
                if (value.toInt() >= performances.length || value.toInt() < 0) {
                  return const SizedBox.shrink();
                }

                // Show date for some data points
                if (performances.length < 5 ||
                    value.toInt() == 0 ||
                    value.toInt() == performances.length - 1 ||
                    value.toInt() % (performances.length ~/ 3) == 0) {

                  final date = performances[value.toInt()]['date'] as DateTime;
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
        maxX: (performances.length - 1).toDouble(),
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
                final isFirstOrLast = index == 0 || index == performances.length - 1;

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
                final performance = performances[barSpot.x.toInt()];
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
}
