// lib/utils/chart_utils.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Utility class for formatting and preparing data for charts
class ChartUtils {
  /// Format a number with appropriate suffixes (K, M) for easier reading in charts
  static String formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(1);
    }
  }

  /// Get a color from the app's palette based on an index
  static Color getColorByIndex(int index) {
    final colors = [
      AppColors.velvetMist,
      AppColors.velvetPale,
      AppColors.velvetLight,
      AppColors.velvetHighlight,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.amberAccent,
    ];

    return index < colors.length
        ? colors[index]
        : Colors.grey.shade600;
  }

  /// Calculate percentage distribution for a list of values
  static List<double> calculatePercentages(List<double> values) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return List.filled(values.length, 0);

    return values.map((value) => (value / total) * 100).toList();
  }

  /// Generate a gradient for chart backgrounds
  static LinearGradient getChartGradient({
    Color startColor = const Color(0xFF6E1431),
    Color endColor = const Color(0x4D4C0D1F),
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        startColor,
        endColor,
      ],
    );
  }

  /// Format a date for chart labels based on the frequency of data points
  static String formatDateForChart(DateTime date, int dataPointCount) {
    if (dataPointCount > 20) {
      // For many data points, just show month abbreviation
      return '${date.month}/${date.day}';
    } else if (dataPointCount > 10) {
      // For moderate number of points, show short month name
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${monthNames[date.month - 1]} ${date.day}';
    } else {
      // For few data points, show more details
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  /// Group data by categories (like muscle groups) and sum values
  static Map<String, double> groupAndSumData(List<Map<String, dynamic>> data,
      String categoryKey, String valueKey) {
    final result = <String, double>{};

    for (final item in data) {
      final category = item[categoryKey] as String;
      final value = item[valueKey] as double;

      result[category] = (result[category] ?? 0) + value;
    }

    return result;
  }

  /// Calculate the maximum value from a list of maps with a specific key
  static double getMaxValue(List<Map<String, dynamic>> data, String key) {
    if (data.isEmpty) return 0;

    return data.map((item) => item[key] as double).reduce(
      (max, value) => value > max ? value : max
    );
  }

  /// Calculate the average value from a list of maps with a specific key
  static double getAverageValue(List<Map<String, dynamic>> data, String key) {
    if (data.isEmpty) return 0;

    final sum = data.fold<double>(
      0, (sum, item) => sum + (item[key] as double)
    );

    return sum / data.length;
  }

  /// Get appropriate intervals for y-axis based on the data range
  static double getYAxisInterval(double min, double max) {
    final range = max - min;

    if (range <= 5) return 1;
    if (range <= 20) return 5;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    if (range <= 500) return 100;

    return 200;
  }
}
