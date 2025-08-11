// lib/screens/analytics/exercise_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../models/personal_record.dart';
import '../../theme/app_colors.dart';

class ExerciseAnalyticsScreen extends StatefulWidget {
  const ExerciseAnalyticsScreen({Key? key}) : super(key: key);

  @override
  _ExerciseAnalyticsScreenState createState() => _ExerciseAnalyticsScreenState();
}

class _ExerciseAnalyticsScreenState extends State<ExerciseAnalyticsScreen> {
  String? _selectedExerciseId;
  String _chartType = 'weight'; // 'weight', 'volume', 'reps'
  String _timeRange = 'all'; // 'month', 'quarter', 'year', 'all'

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final exercises = exerciseProvider.exercises;

    // Sort exercises alphabetically
    exercises.sort((a, b) => a.name.compareTo(b.name));

    // Auto-select first exercise if none selected
    if (_selectedExerciseId == null && exercises.isNotEmpty) {
      _selectedExerciseId = exercises.first.id;
    }

    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      appBar: AppBar(
        title: const Text(
          'Exercise Analytics',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.royalVelvet,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Exercise picker
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.royalVelvet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Exercise',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedExerciseId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.deepVelvet,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  dropdownColor: AppColors.deepVelvet,
                  items: exercises.map((exercise) {
                    return DropdownMenuItem<String>(
                      value: exercise.id,
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedExerciseId = value;
                    });
                  },
                ),

                // Filter options
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Chart type selector
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chart Type',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _chartType,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.deepVelvet,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            dropdownColor: AppColors.deepVelvet,
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'weight',
                                child: Text(
                                  'Weight',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'volume',
                                child: Text(
                                  'Volume',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'reps',
                                child: Text(
                                  'Reps',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _chartType = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Time range selector
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Time Range',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _timeRange,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.deepVelvet,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            dropdownColor: AppColors.deepVelvet,
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'month',
                                child: Text(
                                  'Last Month',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'quarter',
                                child: Text(
                                  'Last 3 Months',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'year',
                                child: Text(
                                  'Last Year',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'all',
                                child: Text(
                                  'All Time',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _timeRange = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Exercise data
          Expanded(
            child: _selectedExerciseId != null
                ? _buildExerciseAnalytics(
                    _selectedExerciseId!,
                    workoutProvider,
                    exerciseProvider,
                  )
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseAnalytics(
    String exerciseId,
    WorkoutProvider workoutProvider,
    ExerciseProvider exerciseProvider,
  ) {
    final exercise = exerciseProvider.getExerciseById(exerciseId);
    if (exercise == null) {
      return _buildEmptyState();
    }

    // Get performance data for this exercise
    DateTime? startDate;
    final now = DateTime.now();

    switch (_timeRange) {
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'quarter':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case 'all':
      default:
        startDate = null;
        break;
    }

    // Get historical performance data
    final performanceData = workoutProvider.getPerformanceTrend(
      exerciseId,
      limit: 50, // Get more data for better trend visualization
      byWeight: _chartType == 'weight',
    );

    // Filter by date if needed
    final filteredData = startDate != null
        ? performanceData
            .where((data) => (data['date'] as DateTime).isAfter(startDate!))
            .toList()
        : performanceData;

    // Get personal records
    final prs = workoutProvider.getPersonalRecordsForExercise(exerciseId);

    // If no data, show empty state
    if (filteredData.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            _buildExerciseHeader(exercise.name, exercise.primaryMuscles.join(', ')),

            const SizedBox(height: 24),

            // No data message
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timeline,
                    size: 64,
                    color: AppColors.velvetLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data available for this time range',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.velvetLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete more workouts with this exercise\nor try a different time range',
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
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          _buildExerciseHeader(exercise.name, exercise.primaryMuscles.join(', ')),

          const SizedBox(height: 24),

          // Quick stats
          _buildQuickStats(filteredData, prs),

          const SizedBox(height: 24),

          // Performance chart
          _buildSectionHeader('Progress Chart'),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: _buildPerformanceChart(filteredData),
          ),

          const SizedBox(height: 24),

          // Personal records
          if (prs.isNotEmpty) ...[
            _buildSectionHeader('Personal Records'),
            const SizedBox(height: 8),
            _buildPersonalRecordsTable(prs),
            const SizedBox(height: 24),
          ],

          // Recent sets
          _buildSectionHeader('Recent Sets'),
          const SizedBox(height: 8),
          _buildRecentSetsTable(workoutProvider.getPreviousSets(exerciseId)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: AppColors.velvetLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Select an exercise to view analytics',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.velvetLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader(String name, String muscles) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.velvetHighlight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                muscles,
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: AppColors.velvetPale,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
      List<Map<String, dynamic>> performanceData, List<PersonalRecord> prs) {
    // Get first and last data points for comparison
    final firstEntry = performanceData.first;
    final lastEntry = performanceData.last;

    // Extract values based on chart type
    double firstValue = 0;
    double lastValue = 0;
    String unit = '';

    switch (_chartType) {
      case 'weight':
        firstValue = firstEntry['weight'];
        lastValue = lastEntry['weight'];
        unit = lastEntry['weightUnit'] ?? 'kg';
        break;
      case 'volume':
        firstValue = firstEntry['volume'];
        lastValue = lastEntry['volume'];
        unit = 'kg';
        break;
      case 'reps':
        firstValue = firstEntry['reps'].toDouble();
        lastValue = lastEntry['reps'].toDouble();
        unit = 'reps';
        break;
    }

    // Calculate change
    final absoluteChange = lastValue - firstValue;
    final percentChange = firstValue > 0
        ? (absoluteChange / firstValue * 100)
        : 0.0;

    // Format values
    final firstValueFormatted = _chartType == 'reps'
        ? firstValue.toInt().toString()
        : firstValue.toStringAsFixed(1);
    final lastValueFormatted = _chartType == 'reps'
        ? lastValue.toInt().toString()
        : lastValue.toStringAsFixed(1);
    final changeFormatted = _chartType == 'reps'
        ? absoluteChange.toInt().toString()
        : absoluteChange.toStringAsFixed(1);

    // Get total workouts with this exercise
    final totalWorkouts = performanceData.length;

    // Get PR information
    String prValue = '0';
    if (prs.isNotEmpty) {
      // Find the relevant PR based on chart type
      final relevantPr = prs.firstWhere(
        (pr) => pr.type == (_chartType == 'volume' ? 'volume' : 'weight'),
        orElse: () => prs.first,
      );

      prValue = _chartType == 'reps'
          ? relevantPr.reps?.toString() ?? '0'
          : relevantPr.value.toStringAsFixed(1);
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Best Performance',
          '$prValue $unit',
          Icons.emoji_events,
        ),
        _buildStatCard(
          'Current',
          '$lastValueFormatted $unit',
          Icons.trending_up,
        ),
        _buildStatCard(
          'Progress',
          '$changeFormatted $unit (${percentChange.toStringAsFixed(1)}%)',
          Icons.show_chart,
          positive: absoluteChange >= 0,
        ),
        _buildStatCard(
          'Total Workouts',
          totalWorkouts.toString(),
          Icons.calendar_month,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {bool positive = true}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: title == 'Progress'
                ? (positive ? Colors.green : Colors.red)
                : AppColors.velvetPale,
            size: 28,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(List<Map<String, dynamic>> data) {
    // This is a placeholder for the actual chart
    // In a real implementation, you would use a chart library like FL Chart
    return Container(
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Performance chart for $_chartType over time would be shown here',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalRecordsTable(List<PersonalRecord> prs) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'Type',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'Value',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Expanded(
                flex: 3,
                child: Text(
                  'Date',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          ...prs.map((pr) {
            String type;
            String value;

            switch (pr.type) {
              case 'weight':
                type = 'Weight';
                value = '${pr.value} kg x ${pr.reps}';
                break;
              case 'reps':
                type = 'Reps';
                value = '${pr.value.toInt()} reps';
                break;
              case 'volume':
                type = 'Volume';
                value = '${pr.value.toStringAsFixed(1)} kg';
                break;
              default:
                type = pr.type.capitalize();
                value = pr.value.toString();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      DateFormat('MMM d, y').format(pr.date),
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentSetsTable(List<dynamic> sets) {
    if (sets.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.royalVelvet,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No recent sets for this exercise',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  'Date',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'Weight',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'Reps',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'Volume',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          ...sets.map((set) {
            final volume = set.weight * set.reps;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      DateFormat('MMM d, y').format(set.timestamp),
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${set.weight} ${set.weightUnit}',
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${set.reps}',
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${volume.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
