import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class CompactStrengthChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>>? strengthProgressData;

  const CompactStrengthChartWidget({Key? key, required this.strengthProgressData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (strengthProgressData == null || strengthProgressData!.isEmpty) {
      return _buildEmptyState();
    }

    // Get the top exercise by progress percentage
    final topExercise = strengthProgressData!.first;
    final exerciseName = topExercise['exerciseName'] as String;
    final performances = topExercise['performances'] as List<Map<String, dynamic>>;

    return Container(
      height: 200, // Compact height
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            exerciseName,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Compact progress info
          Row(
            children: [
              _buildCompactInfoItem('Start', '${topExercise['startWeight']} kg'),
              _buildCompactInfoItem('Current', '${topExercise['currentWeight']} kg'),
              _buildCompactInfoItem('Progress', '${topExercise['increase']} kg'),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Compact chart
          Expanded(
            child: performances.length > 1
                ? _buildCompactLineChart(performances)
                : _buildEmptyChartState(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Strength data here',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChartState() {
    return Center(
      child: Text(
        'Strength data here',
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 14,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildCompactInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 10,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLineChart(List<Map<String, dynamic>> performances) {
    // Sort performances by date
    final sortedPerformances = List<Map<String, dynamic>>.from(performances);
    sortedPerformances.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateA.compareTo(dateB);
    });
    
    // Extract data points
    final spots = sortedPerformances.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final performance = entry.value;
      return FlSpot(index, performance['weight'].toDouble());
    }).toList();

    // Calculate Y-axis range
    double dataMinY = spots.map((spot) => spot.y).reduce(math.min);
    double dataMaxY = spots.map((spot) => spot.y).reduce(math.max);
    
    final range = dataMaxY - dataMinY;
    final padding = range * 0.1;
    final minY = dataMinY - padding;
    final maxY = dataMaxY + padding;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 3,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
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
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.velvetMist,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.velvetMist.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(enabled: false),
      ),
    );
  }
}