// core/model/task.dart
import 'package:hive/hive.dart';

// auto build
part 'task.g.dart';

// hive template for task
// definition of task: something short and easy to complete and tick off
// eg: go for a run
// gets ticked off when completed
// has zero or more goals that it satisfies

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  List<int> goalIds;

  // constructor
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

  // adding goals to the list
  void addGoal(int goalId) {
    if (!goalIds.contains(goalId)) {
      goalIds.add(goalId);
    }
  }

  // removing goals from the list
  void removeGoal(int goalId) {
    goalIds.remove(goalId);
  }
}
