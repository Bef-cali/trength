// lib/widgets/analytics/volume_chart_widget.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class VolumeChartWidget extends StatelessWidget {
  final Map<String, double>? muscleGroupVolume;

  const VolumeChartWidget({Key? key, required this.muscleGroupVolume}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle null or empty data safely
    if (muscleGroupVolume == null || muscleGroupVolume!.isEmpty) {
      return _buildEmptyState();
    }

    // Sort muscle groups by volume (descending)
    final sortedEntries = muscleGroupVolume!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate total volume safely (avoiding reduce on empty list)
    final totalVolume = sortedEntries.isEmpty
        ? 0.0
        : sortedEntries.map((e) => e.value).reduce((a, b) => a + b);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title and total volume
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Volume Distribution',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Total: ${totalVolume.toStringAsFixed(0)} kg',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Enhanced legends (no pie chart)
          Expanded(
            child: sortedEntries.isEmpty
                ? Center(
                    child: Text(
                      'No volume data to display',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  )
                : _buildEnhancedLegend(sortedEntries, totalVolume),
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
              Icons.assessment,
              size: 48,
              color: AppColors.velvetLight.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No volume data available',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.velvetLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete workouts to generate volume data',
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

  Widget _buildEnhancedLegend(List<MapEntry<String, double>> entries, double totalVolume) {
    // Define a list of colors for visual indicators
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

    // Handle zero total volume to avoid division by zero
    if (totalVolume <= 0) {
      return const Center(
        child: Text(
          'No volume data to display',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final muscleGroup = entry.key;
        final volume = entry.value;
        final percentage = (volume / totalVolume * 100);

        // Use color from the list, or a fallback color
        final color = index < colors.length
            ? colors[index]
            : Colors.grey.shade600;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),

              // Muscle name and percentage
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      muscleGroup,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Volume value
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${volume.toStringAsFixed(0)} kg',
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Volume',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Visual bar indicator
              const SizedBox(width: 12),
              Container(
                width: 8,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: percentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
