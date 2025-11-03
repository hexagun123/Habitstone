import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  List<String> goalIds; // Changed to List<String>

  @HiveField(3)
  late int appearanceCount;

  @HiveField(4)
  late int importance;

  @HiveField(5)
  late bool display;

  @HiveField(6) // New field
  late String id;

  // Private constructor
  Task._({
    required this.title,
    required this.description,
    required this.goalIds,
    required this.appearanceCount,
    required this.importance,
    required this.display,
    required this.id,
  });

  // Public factory constructor
  factory Task({
    required String title,
    required String description,
    List<String>? goalIds,
    required int appearanceCount,
    required int importance,
    required bool display,
    String? id,
  }) {
    final newId = id ?? const Uuid().v4();
    final newGoalIds = goalIds ?? [];

    return Task._(
      title: title,
      description: description,
      goalIds: newGoalIds,
      appearanceCount: appearanceCount,
      importance: importance,
      display: display,
      id: newId,
    );
  }

  // --- Methods for Firebase ---
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task._(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      goalIds: List<String>.from(json['goalIds']),
      appearanceCount: json['appearanceCount'],
      importance: json['importance'],
      display: json['display'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goalIds': goalIds,
      'appearanceCount': appearanceCount,
      'importance': importance,
      'display': display,
    };
  }

  void addGoal(String goalId) {
    if (!goalIds.contains(goalId)) {
      goalIds.add(goalId);
    }
  }

  void removeGoal(String goalId) {
    goalIds.remove(goalId);
  }

  Task copyWith({
    String? title,
    String? description,
    List<String>? goalIds,
    int? appearanceCount,
    int? importance,
    bool? display,
    String? id,
  }) {
    return Task._(
      title: title ?? this.title,
      description: description ?? this.description,
      goalIds: goalIds ?? List<String>.from(this.goalIds),
      appearanceCount: appearanceCount ?? this.appearanceCount,
      importance: importance ?? this.importance,
      display: display ?? this.display,
      id: id ?? this.id,
    );
  }

  bool decrementAppearance() {
    if (appearanceCount > 0) {
      appearanceCount--;
      return true;
    }
    return false;
  }

  bool get shouldBeDeleted => appearanceCount <= 0;

  bool activate() {
    if (appearanceCount > 0 && !display) {
      display = true;
      appearanceCount--;
      return true;
    }
    return false;
  }
}
