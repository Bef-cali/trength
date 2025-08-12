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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Records',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.velvetMist.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${recentPRs.length} records',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.velvetMist,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 4.5,
                mainAxisSpacing: 12,
              ),
              itemCount: recentPRs.length,
              itemBuilder: (context, index) {
                final pr = recentPRs[index];
                return _buildPRCard(pr);
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

  Widget _buildPRCard(Map<String, dynamic> pr) {
    final date = pr['date'] as DateTime;
    final exerciseName = pr['exerciseName'] as String;
    final weight = pr['weight'];
    final reps = pr['reps'];
    final oneRM = pr['oneRM'] as double?; // New 1RM value

    return Container(
      decoration: BoxDecoration(
        color: AppColors.deepVelvet.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.velvetMist.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // PR icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.velvetMist.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppColors.velvetMist,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Exercise details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, y').format(date),
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // 1RM and original performance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                oneRM != null ? '${oneRM!.toStringAsFixed(1)}kg' : '${weight}kg',
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.velvetMist,
                ),
              ),
              Text(
                oneRM != null ? 'Est. 1RM' : '× $reps reps',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              if (oneRM != null)
                Text(
                  'from ${weight}kg × $reps',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 8),

          // PR badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.velvetMist,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'PR',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 10,
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
