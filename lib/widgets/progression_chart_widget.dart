// lib/widgets/progression_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class ProgressionChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> performanceData;
  final String title;
  final bool showWeight;
  final bool showReps;
  final bool showVolume;

  const ProgressionChartWidget({
    Key? key,
    required this.performanceData,
    this.title = 'Progression',
    this.showWeight = true,
    this.showReps = false,
    this.showVolume = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (performanceData.isEmpty) {
      return _buildEmptyChart();
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Chart legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showWeight) _buildLegendItem('Weight', AppColors.velvetMist),
              if (showWeight && showReps) const SizedBox(width: 16),
              if (showReps) _buildLegendItem('Reps', AppColors.velvetLight),
              if ((showWeight || showReps) && showVolume) const SizedBox(width: 16),
              if (showVolume) _buildLegendItem('Volume', AppColors.velvetPale),
            ],
          ),
          const SizedBox(height: 16),

          // Chart itself
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: _buildGridData(),
                titlesData: _buildTitlesData(),
                borderData: _buildBorderData(),
                lineBarsData: _buildLineBarsData(),
                minX: 0,
                maxX: (performanceData.length - 1).toDouble(),
                minY: _calculateMinY(),
                maxY: _calculateMaxY(),
                lineTouchData: _buildLineTouchData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              color: AppColors.velvetLight,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Not enough data to display chart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Complete more workouts to see progression',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _calculateGridInterval(),
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.white.withOpacity(0.1),
          strokeWidth: 1,
        );
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: _calculateXAxisInterval(),
          getTitlesWidget: _bottomTitleWidgets,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: _calculateGridInterval(),
          getTitlesWidget: _leftTitleWidgets,
        ),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        left: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        right: BorderSide(color: Colors.transparent),
        top: BorderSide(color: Colors.transparent),
      ),
    );
  }

  List<LineChartBarData> _buildLineBarsData() {
    final List<LineChartBarData> result = [];

    // Weight line
    if (showWeight) {
      result.add(
        LineChartBarData(
          spots: _createWeightSpots(),
          isCurved: true,
          color: AppColors.velvetMist,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.velvetMist.withOpacity(0.1),
          ),
        ),
      );
    }

    // Reps line
    if (showReps) {
      result.add(
        LineChartBarData(
          spots: _createRepsSpots(),
          isCurved: true,
          color: AppColors.velvetLight,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.velvetLight.withOpacity(0.1),
          ),
        ),
      );
    }

    // Volume line
    if (showVolume) {
      result.add(
        LineChartBarData(
          spots: _createVolumeSpots(),
          isCurved: true,
          color: AppColors.velvetPale,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.velvetPale.withOpacity(0.1),
          ),
        ),
      );
    }

    return result;
  }

  LineTouchData _buildLineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: AppColors.deepVelvet.withOpacity(0.8),
        tooltipRoundedRadius: 8,
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((spot) {
            final index = spot.x.toInt();
            if (index >= 0 && index < performanceData.length) {
              final data = performanceData[index];
              final date = DateFormat('MMM d').format(data['date']);

              String tooltipText = '';
              Color tooltipColor;

              if (spot.barIndex == 0 && showWeight) {
                tooltipText = '${data['weight']} ${data['weightUnit']}';
                tooltipColor = AppColors.velvetMist;
              } else if ((spot.barIndex == 1 && showWeight && showReps) ||
                         (spot.barIndex == 0 && !showWeight && showReps)) {
                tooltipText = '${data['reps']} reps';
                tooltipColor = AppColors.velvetLight;
              } else {
                tooltipText = '${data['volume'].toStringAsFixed(1)} (volume)';
                tooltipColor = AppColors.velvetPale;
              }

              return LineTooltipItem(
                '$date: $tooltipText',
                TextStyle(
                  color: tooltipColor,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return null;
          }).toList();
        },
      ),
      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {},
      handleBuiltInTouches: true,
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final int index = value.toInt();
    if (index >= 0 && index < performanceData.length) {
      final data = performanceData[index];
      final date = data['date'] as DateTime;

      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          DateFormat('M/d').format(date),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toInt().toString(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
        ),
      ),
    );
  }

  List<FlSpot> _createWeightSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < performanceData.length; i++) {
      final data = performanceData[i];
      spots.add(FlSpot(i.toDouble(), data['weight']));
    }
    return spots;
  }

  List<FlSpot> _createRepsSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < performanceData.length; i++) {
      final data = performanceData[i];
      spots.add(FlSpot(i.toDouble(), data['reps'].toDouble()));
    }
    return spots;
  }

  List<FlSpot> _createVolumeSpots() {
    List<FlSpot> spots = [];

    // Find max volume to scale correctly
    double maxVolume = 0;
    for (var data in performanceData) {
      if (data['volume'] > maxVolume) {
        maxVolume = data['volume'];
      }
    }

    // Scale volume to fit in a reasonable range
    double scaleFactor = _calculateMaxY() / (maxVolume > 0 ? maxVolume : 1);

    for (int i = 0; i < performanceData.length; i++) {
      final data = performanceData[i];
      spots.add(FlSpot(i.toDouble(), data['volume'] * scaleFactor));
    }
    return spots;
  }

  double _calculateMinY() {
    if (showWeight) {
      double minWeight = double.infinity;
      for (var data in performanceData) {
        if (data['weight'] < minWeight) {
          minWeight = data['weight'];
        }
      }
      // Make some room at the bottom
      return (minWeight * 0.8).floorToDouble();
    } else if (showReps) {
      double minReps = double.infinity;
      for (var data in performanceData) {
        if (data['reps'] < minReps) {
          minReps = data['reps'].toDouble();
        }
      }
      return (minReps * 0.8).floorToDouble();
    } else {
      return 0;
    }
  }

  double _calculateMaxY() {
    if (showWeight) {
      double maxWeight = 0;
      for (var data in performanceData) {
        if (data['weight'] > maxWeight) {
          maxWeight = data['weight'];
        }
      }
      // Add some room at the top
      return (maxWeight * 1.2).ceilToDouble();
    } else if (showReps) {
      double maxReps = 0;
      for (var data in performanceData) {
        if (data['reps'] > maxReps) {
          maxReps = data['reps'].toDouble();
        }
      }
      return (maxReps * 1.2).ceilToDouble();
    } else {
      return 100;
    }
  }

  double _calculateGridInterval() {
    final max = _calculateMaxY();
    final min = _calculateMinY();
    final range = max - min;

    if (range <= 5) return 1;
    if (range <= 20) return 5;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    return 50;
  }

  double _calculateXAxisInterval() {
    if (performanceData.length <= 5) return 1;
    if (performanceData.length <= 10) return 2;
    if (performanceData.length <= 20) return 4;
    return 5;
  }
}
