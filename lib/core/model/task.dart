// models/task.dart
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  List<int> goalIds; // Changed from List<String> to List<int>

  Task({
    required this.title,
    required this.description,
    List<int>? goalIds,
  }) : goalIds = goalIds ?? [];

  Task copyWith({
    String? title,
    String? description,
    List<int>? goalIds,
  }) {
    return Task(
      title: title ?? this.title,
      description: description ?? this.description,
      goalIds: goalIds ?? List<int>.from(this.goalIds),
    );
  }

  void addGoal(int goalId) {
    if (!goalIds.contains(goalId)) {
      goalIds.add(goalId);
    }
  }

  void removeGoal(int goalId) {
    goalIds.remove(goalId);
  }
}
