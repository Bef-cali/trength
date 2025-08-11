// lib/widgets/analytics/pr_timeline_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';

class PRTimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>>? personalRecords;

  const PRTimelineWidget({Key? key, required this.personalRecords}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (personalRecords == null || personalRecords!.isEmpty) {
      return _buildEmptyState();
    }

    // Sort PRs by date (newest first)
    final sortedPRs = List<Map<String, dynamic>>.from(personalRecords!);
    sortedPRs.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    // Limit to 5 most recent PRs
    final recentPRs = sortedPRs.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Personal Records',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: recentPRs.length,
              itemBuilder: (context, index) {
                final pr = recentPRs[index];
                return _buildPRItem(pr, index == recentPRs.length - 1);
              },
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
              Icons.emoji_events,
              size: 48,
              color: AppColors.velvetLight.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No personal records yet',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.velvetLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep training to set new personal records',
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

  Widget _buildPRItem(Map<String, dynamic> pr, bool isLast) {
    final date = pr['date'] as DateTime;
    final exerciseName = pr['exerciseName'] as String;
    final weight = pr['weight'];
    final reps = pr['reps'];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator and line
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.velvetMist,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // PR details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  DateFormat('MMMM d, y').format(date),
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),

                // Exercise and achievement
                Text(
                  exerciseName,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$weight kg × $reps reps',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    color: AppColors.velvetPale,
                  ),
                ),

                // Spacing before next item
                if (!isLast) const SizedBox(height: 16),
              ],
            ),
          ),

          // PR badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.velvetMist.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'PR',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
