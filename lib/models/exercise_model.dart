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
}
