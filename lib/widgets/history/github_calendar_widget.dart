// lib/widgets/history/github_calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/workout_provider.dart';
import '../../models/active_workout.dart';
import '../../theme/app_colors.dart';

class GitHubCalendarWidget extends StatefulWidget {
  final DateTime? focusedDate;
  final Function(DateTime)? onDateChanged;
  
  const GitHubCalendarWidget({
    Key? key,
    this.focusedDate,
    this.onDateChanged,
  }) : super(key: key);

  @override
  _GitHubCalendarWidgetState createState() => _GitHubCalendarWidgetState();
}

class _GitHubCalendarWidgetState extends State<GitHubCalendarWidget> {
  late DateTime _focusedDate;
  bool _isYearView = false;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.focusedDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(GitHubCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedDate != null && widget.focusedDate != _focusedDate) {
      setState(() {
        _focusedDate = widget.focusedDate!;
      });
    }
  }

  void _toggleView() {
    setState(() {
      _isYearView = !_isYearView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header removed - month display handled by History tab header
        Expanded(
          child: _isYearView ? _buildYearCalendar() : _buildMonthCalendar(),
        ),
        _buildLegend(),
      ],
    );
  }


  Widget _buildMonthCalendar() {
    // Get the workouts from the provider
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workouts = workoutProvider.getWorkoutHistory();

    // Map workouts by date
    final Map<String, List<ActiveWorkout>> workoutsByDate = {};
    for (var workout in workouts) {
      final dateString = DateFormat('yyyy-MM-dd').format(workout.startTime);
      workoutsByDate[dateString] = [...workoutsByDate[dateString] ?? [], workout];
    }

    // Get the first day of the month
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);

    // Get the number of days in the month
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Get the weekday of the first day (0-based, Monday = 0)
    final firstWeekday = (firstDayOfMonth.weekday - 1) % 7;

    // Calculate the number of rows needed
    final int rowCount = ((daysInMonth + firstWeekday) / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Weekday headers
          Row(
            children: const [
              WeekdayHeader('M'),
              WeekdayHeader('T'),
              WeekdayHeader('W'),
              WeekdayHeader('T'),
              WeekdayHeader('F'),
              WeekdayHeader('S'),
              WeekdayHeader('S'),
            ],
          ),
          const SizedBox(height: 8),

          // Calendar grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: rowCount * 7,
              itemBuilder: (context, index) {
                // Calculate the day number (1-based)
                final int displayIndex = index - firstWeekday + 1;

                // Check if this grid position is a valid day for this month
                if (displayIndex < 1 || displayIndex > daysInMonth) {
                  return const SizedBox();
                }

                // Create the date for this cell
                final cellDate = DateTime(_focusedDate.year, _focusedDate.month, displayIndex);
                final dateString = DateFormat('yyyy-MM-dd').format(cellDate);

                // Get the workouts for this date
                final daysWorkouts = workoutsByDate[dateString] ?? [];

                // Calculate the intensity (0-3) based on workout count or volume
                int intensity = 0;
                if (daysWorkouts.isNotEmpty) {
                  double totalVolume = 0;
                  for (var workout in daysWorkouts) {
                    workout.exerciseSets.forEach((_, sets) {
                      for (var set in sets) {
                        if (set.completed && !set.isWarmup) {
                          totalVolume += set.weight * set.reps;
                        }
                      }
                    });
                  }

                  // Assign intensity based on volume
                  if (totalVolume > 0) {
                    if (totalVolume < 2000) intensity = 1;
                    else if (totalVolume < 5000) intensity = 2;
                    else intensity = 3;
                  }
                }

                return InkWell(
                  onTap: daysWorkouts.isNotEmpty
                      ? () => _showWorkoutsForDay(context, cellDate, daysWorkouts)
                      : null,
                  child: DayCell(
                    day: displayIndex,
                    intensity: intensity,
                    isToday: _isToday(cellDate),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearCalendar() {
    // Get the workouts from the provider
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workouts = workoutProvider.getWorkoutHistory();

    // Map workouts by date
    final Map<String, List<ActiveWorkout>> workoutsByDate = {};
    for (var workout in workouts) {
      final dateString = DateFormat('yyyy-MM-dd').format(workout.startTime);
      workoutsByDate[dateString] = [...workoutsByDate[dateString] ?? [], workout];
    }

    // Build a grid of months
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        // Create the month (1-indexed)
        final month = index + 1;

        // Calculate the number of days in the month
        final daysInMonth = DateTime(_focusedDate.year, month + 1, 0).day;

        // Count workouts in this month
        int workoutCount = 0;
        double totalVolume = 0;

        for (int day = 1; day <= daysInMonth; day++) {
          final date = DateTime(_focusedDate.year, month, day);
          final dateString = DateFormat('yyyy-MM-dd').format(date);

          final daysWorkouts = workoutsByDate[dateString] ?? [];
          workoutCount += daysWorkouts.length;

          for (var workout in daysWorkouts) {
            workout.exerciseSets.forEach((_, sets) {
              for (var set in sets) {
                if (set.completed && !set.isWarmup) {
                  totalVolume += set.weight * set.reps;
                }
              }
            });
          }
        }

        // Calculate the intensity for the month
        int intensity = 0;
        if (workoutCount > 0) {
          if (workoutCount < 4) intensity = 1;
          else if (workoutCount < 10) intensity = 2;
          else intensity = 3;
        }

        return InkWell(
          onTap: () {
            final newDate = DateTime(_focusedDate.year, month, 1);
            setState(() {
              _focusedDate = newDate;
              _isYearView = false;
            });
            // Notify parent of date change
            widget.onDateChanged?.call(newDate);
          },
          child: MonthCell(
            month: DateFormat('MMM').format(DateTime(_focusedDate.year, month)),
            intensity: intensity,
            workoutCount: workoutCount,
            volume: totalVolume,
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Intensity: ',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          _buildLegendItem('None', 0),
          _buildLegendItem('Light', 1),
          _buildLegendItem('Medium', 2),
          _buildLegendItem('High', 3),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int intensity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getIntensityColor(intensity),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  Color _getIntensityColor(int intensity) {
    switch (intensity) {
      case 0:
        return AppColors.deepVelvet;
      case 1:
        return AppColors.velvetHighlight;
      case 2:
        return AppColors.velvetPale;
      case 3:
        return AppColors.velvetMist;
      default:
        return AppColors.deepVelvet;
    }
  }

  void _showWorkoutsForDay(BuildContext context, DateTime date, List<ActiveWorkout> workouts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.royalVelvet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(date),
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Text(
                '${workouts.length} workout${workouts.length > 1 ? 's' : ''} on this day',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: AppColors.velvetPale,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];

                    // Calculate total volume
                    double totalVolume = 0;
                    workout.exerciseSets.forEach((_, sets) {
                      for (var set in sets) {
                        if (set.completed && !set.isWarmup) {
                          totalVolume += set.weight * set.reps;
                        }
                      }
                    });

                    return ListTile(
                      title: Text(
                        workout.name,
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        '${workout.exerciseSets.length} exercises · ${workout.completedSets} sets · ${totalVolume.toStringAsFixed(0)} kg',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      trailing: Text(
                        DateFormat('h:mm a').format(workout.startTime),
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: AppColors.velvetPale,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/workout-details',
                          arguments: workout.id,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DayCell extends StatelessWidget {
  final int day;
  final int intensity;
  final bool isToday;

  const DayCell({
    Key? key,
    required this.day,
    required this.intensity,
    required this.isToday,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cellColor;

    switch (intensity) {
      case 0:
        cellColor = AppColors.deepVelvet;
        break;
      case 1:
        cellColor = AppColors.velvetHighlight;
        break;
      case 2:
        cellColor = AppColors.velvetPale;
        break;
      case 3:
        cellColor = AppColors.velvetMist;
        break;
      default:
        cellColor = AppColors.deepVelvet;
    }

    return Container(
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(4),
        border: isToday
            ? Border.all(color: Colors.white, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: intensity > 0 || isToday ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class MonthCell extends StatelessWidget {
  final String month;
  final int intensity;
  final int workoutCount;
  final double volume;

  const MonthCell({
    Key? key,
    required this.month,
    required this.intensity,
    required this.workoutCount,
    required this.volume,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cellColor;

    switch (intensity) {
      case 0:
        cellColor = AppColors.deepVelvet;
        break;
      case 1:
        cellColor = AppColors.velvetHighlight;
        break;
      case 2:
        cellColor = AppColors.velvetPale;
        break;
      case 3:
        cellColor = AppColors.velvetMist;
        break;
      default:
        cellColor = AppColors.deepVelvet;
    }

    return Container(
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$workoutCount workouts',
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          if (volume > 0)
            Text(
              '${volume.toStringAsFixed(0)} kg',
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }
}

class WeekdayHeader extends StatelessWidget {
  final String day;

  const WeekdayHeader(this.day, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
