// lib/widgets/history/history_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/split_provider.dart';
import '../../theme/app_colors.dart';

class HistoryFilterWidget extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialSplitId;
  final String? initialExerciseId;
  final Function(
      {DateTime? startDate,
      DateTime? endDate,
      String? splitId,
      String? exerciseId}) onApplyFilters;

  const HistoryFilterWidget({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialSplitId,
    this.initialExerciseId,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  _HistoryFilterWidgetState createState() => _HistoryFilterWidgetState();
}

class _HistoryFilterWidgetState extends State<HistoryFilterWidget> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String? _splitId;
  late String? _exerciseId;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _splitId = widget.initialSplitId;
    _exerciseId = widget.initialExerciseId;
  }

  void _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? _startDate ?? DateTime.now().subtract(const Duration(days: 30))
        : _endDate ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.velvetMist,
              onPrimary: Colors.white,
              surface: AppColors.royalVelvet,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.deepVelvet,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before start date, adjust it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // If start date is after end date, adjust it
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final splitProvider = Provider.of<SplitProvider>(context);

    final exercises = exerciseProvider.exercises;
    final splits = splitProvider.splits;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          const Text(
            'Filter Workouts',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Date range filters
          const Text(
            'Date Range',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      _startDate == null
                          ? 'Select'
                          : DateFormat('MMM d, y').format(_startDate!),
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        color: _startDate == null
                            ? Colors.white.withOpacity(0.7)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      _endDate == null
                          ? 'Select'
                          : DateFormat('MMM d, y').format(_endDate!),
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        color: _endDate == null
                            ? Colors.white.withOpacity(0.7)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Split filter
          const Text(
            'Workout Split',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: _splitId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            dropdownColor: AppColors.deepVelvet,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  'All Splits',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    color: Colors.white,
                  ),
                ),
              ),
              ...splits.map((split) => DropdownMenuItem<String?>(
                    value: split.id,
                    child: Text(
                      split.name,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        color: Colors.white,
                      ),
                    ),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _splitId = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Exercise filter
          const Text(
            'Exercise',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: _exerciseId,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            dropdownColor: AppColors.deepVelvet,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  'All Exercises',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    color: Colors.white,
                  ),
                ),
              ),
              ...exercises.map((exercise) => DropdownMenuItem<String?>(
                    value: exercise.id,
                    child: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _exerciseId = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    color: AppColors.velvetLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(
                    startDate: _startDate,
                    endDate: _endDate,
                    splitId: _splitId,
                    exerciseId: _exerciseId,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.velvetMist,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
