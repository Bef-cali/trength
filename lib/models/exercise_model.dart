import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'exercise_model.g.dart';

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  List<String> primaryMuscles;

  @HiveField(4)
  List<String> secondaryMuscles;

  @HiveField(5)
  bool isCustom;

  @HiveField(6)
  String? userId;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  String? equipment;

  @HiveField(9)
  String? description;

  Exercise({
    String? id,
    required this.name,
    required this.category,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    this.isCustom = false,
    this.userId,
    DateTime? createdAt,
    this.equipment,
    this.description,
  }) :
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now();

  Exercise copyWith({
    String? name,
    String? category,
    List<String>? primaryMuscles,
    List<String>? secondaryMuscles,
    bool? isCustom,
    String? userId,
    String? equipment,
    String? description,
  }) {
    return Exercise(
      id: this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      isCustom: isCustom ?? this.isCustom,
      userId: userId ?? this.userId,
      createdAt: this.createdAt,
      equipment: equipment ?? this.equipment,
      description: description ?? this.description,
    );
  }

  // Helper method to create from JSON (for initial data loading)
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      primaryMuscles: List<String>.from(json['primaryMuscles']),
      secondaryMuscles: json['secondaryMuscles'] != null
          ? List<String>.from(json['secondaryMuscles'])
          : [],
      isCustom: json['isCustom'] ?? false,
      userId: json['userId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      equipment: json['equipment'],
      description: json['description'],
    );
  }

  // Convert to JSON (for export functionality)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'isCustom': isCustom,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'equipment': equipment,
      'description': description,
    };
  }

  static String mapMuscleGroupToGeneral(String muscleGroup) {
    final muscle = muscleGroup.toLowerCase().trim();
    
    switch (muscle) {
      // CHEST
      case 'pectoralis major':
      case 'upper pectoralis major':
      case 'lower pectoralis major':
      case 'pectoral':
      case 'pectorals':
      case 'pecs':
      case 'chest muscles':
        return 'Chest';
      
      // SHOULDERS
      case 'anterior deltoid':
      case 'posterior deltoid':
      case 'lateral deltoid':
      case 'middle deltoid':
      case 'deltoids':
      case 'delts':
      case 'deltoid':
      case 'supraspinatus':
        return 'Shoulders';
      
      // TRICEPS
      case 'triceps brachii':
      case 'tricep':
      case 'back of arms':
        return 'Triceps';
      
      // BICEPS/ARMS
      case 'biceps brachii':
      case 'brachialis':
      case 'brachioradialis':
      case 'bicep':
      case 'upper arms':
        return 'Arms';
      
      // QUADS/LEGS
      case 'quadriceps femoris':
      case 'quadriceps':
      case 'quad':
      case 'front thigh':
      case 'thighs':
      case 'upper legs':
        return 'Legs';
      
      // HAMSTRINGS
      case 'biceps femoris':
      case 'hamstring':
      case 'hams':
      case 'back thigh':
      case 'rear thigh':
        return 'Hamstrings';
      
      // CALVES
      case 'gastrocnemius':
      case 'soleus':
      case 'calf':
      case 'lower legs':
      case 'calf muscles':
        return 'Calves';
      
      // GLUTES
      case 'gluteus maximus':
      case 'gluteus medius':
      case 'gluteus minimus':
      case 'gluteus':
      case 'glute':
      case 'butt':
      case 'buttocks':
      case 'hips':
        return 'Glutes';
      
      // ABS/CORE
      case 'rectus abdominis':
      case 'lower rectus abdominis':
      case 'upper rectus abdominis':
      case 'abdominals':
      case 'abdominal':
      case 'six pack':
      case 'stomach':
      case 'midsection':
      case 'obliques':
      case 'transverse abdominis':
      case 'hip flexors':
      case 'quadratus lumborum':
        return 'Abs';
      
      // FOREARMS
      case 'forearm flexors':
      case 'flexor carpi radialis':
      case 'flexor carpi ulnaris':
      case 'extensor carpi radialis':
      case 'extensor carpi ulnaris':
      case 'pronator teres':
      case 'pronator quadratus':
      case 'supinator':
      case 'forearm':
      case 'lower arms':
      case 'wrists':
      case 'grip':
        return 'Forearms';
      
      // TRAPS
      case 'trapezius':
      case 'upper trapezius':
      case 'middle trapezius':
      case 'lower trapezius':
      case 'trap':
      case 'upper traps':
      case 'middle traps':
      case 'lower traps':
        return 'Traps';
      
      // LATS
      case 'latissimus dorsi':
      case 'lat':
      case 'side back':
      case 'wings':
      case 'lateral back':
        return 'Lats';
      
      // BACK
      case 'erector spinae':
      case 'rhomboids':
      case 'spinal erectors':
      case 'back extensors':
      case 'lower spine':
      case 'lumbar':
      case 'lower back':
      case 'back muscles':
      case 'rear':
      case 'posterior':
        return 'Back';
      
      // NECK
      case 'sternocleidomastoid':
      case 'scalenes':
      case 'splenius capitis':
      case 'deep cervical flexors':
      case 'cervical':
        return 'Neck';
      
      // CARDIO
      case 'cardiovascular':
      case 'aerobic':
      case 'endurance':
      case 'conditioning':
      case 'heart':
        return 'Cardio';
      
      // If already general or unrecognized, return as-is (capitalized)
      default:
        return muscleGroup.split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : word
        ).join(' ');
    }
  }

  List<String> get generalPrimaryMuscles => primaryMuscles.map(mapMuscleGroupToGeneral).toList();
  
  List<String> get generalSecondaryMuscles => secondaryMuscles.map(mapMuscleGroupToGeneral).toList();
}
