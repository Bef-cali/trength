import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/exercise_model.dart';
import 'models/workout_split.dart';
import 'models/workout_session.dart';
import 'models/exercise_reference.dart';
import 'models/active_workout.dart';
import 'models/exercise_set.dart';
import 'models/personal_record.dart';
import 'models/progression_settings.dart';
import 'providers/exercise_provider.dart';
import 'providers/split_provider.dart';
import 'providers/workout_provider.dart';
import 'repositories/exercise_repository.dart';
import 'repositories/split_repository.dart';
import 'repositories/workout_repository.dart';
import 'screens/home_screen.dart';
import 'screens/workout_start_screen.dart';
import 'screens/workout_history_screen.dart';
import 'screens/active_workout_screen.dart';
import 'screens/workout_dashboard_screen.dart';
import 'screens/split_list_screen.dart';
import 'screens/progression_settings_screen.dart';
import 'screens/analytics/analytics_dashboard_screen.dart';
import 'screens/analytics/exercise_analytics_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Register adapters - using typeId to ensure no conflicts
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ExerciseAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(WorkoutSplitAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(WorkoutSessionAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ExerciseReferenceAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ActiveWorkoutAdapter());
  if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(ExerciseSetAdapter());
  if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(PersonalRecordAdapter());
  if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(ProgressionSettingsAdapter());

  // Initialize repositories
  final exerciseRepository = ExerciseRepository();
  await exerciseRepository.initialize();

  final splitRepository = SplitRepository();
  await splitRepository.initialize();

  final workoutRepository = WorkoutRepository();
  await workoutRepository.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.deepVelvet,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(TrengthApp(
    exerciseRepository: exerciseRepository,
    splitRepository: splitRepository,
    workoutRepository: workoutRepository,
  ));
}

class TrengthApp extends StatelessWidget {
  final ExerciseRepository exerciseRepository;
  final SplitRepository splitRepository;
  final WorkoutRepository workoutRepository;

  const TrengthApp({
    Key? key,
    required this.exerciseRepository,
    required this.splitRepository,
    required this.workoutRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExerciseProvider(exerciseRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SplitProvider(splitRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(workoutRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Trength',
        theme: AppColors.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/workout-start': (context) => const WorkoutStartScreen(),
          '/active-workout': (context) => const ActiveWorkoutScreen(),
          '/workout-history': (context) => const WorkoutHistoryScreen(),
          '/workout-dashboard': (context) => const WorkoutDashboardScreen(),
          '/splits': (context) => const SplitListScreen(),
          '/create-split': (context) => const SplitListScreen(),
          '/progression-settings': (context) => const ProgressionSettingsScreen(),
          '/analytics': (context) => const AnalyticsDashboardScreen(),
          '/exercise-analytics': (context) => const ExerciseAnalyticsScreen(),
        },
      ),
    );
  }
}

// Splash screen to handle initialization and recategorization
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Get the exercise provider and recategorize exercises if needed
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);

    // Recategorize exercises (this will update the database)
    await exerciseProvider.recategorizeExercises();

    setState(() {
      _isInitializing = false;
    });

    // Navigate to the main screen after initialization
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or title
            Text(
              'TRENGTH',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.velvetMist,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),

            // Loading indicator
            if (_isInitializing)
              Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.velvetPale),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Organizing exercises...',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
