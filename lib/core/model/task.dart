import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  List<int> goalIds;

  @HiveField(3)
  late int appearanceCount; // How many times task appears before completion

  @HiveField(4)
  late int importance; // How important this task is (1-10 scale)

  @HiveField(5)
  late bool display; // Whether task is displayed in the task list

  // constructor
  Task({
    required this.title,
    required this.description,
    List<int>? goalIds,
    required this.appearanceCount,
    required this.importance,
    required this.display,
  }) : goalIds = goalIds ?? [];

  Task copyWith({
    String? title,
    String? description,
    List<int>? goalIds,
    int? appearanceCount,
    int? importance,
    bool? display,
  }) {
    return Task(
      title: title ?? this.title,
      description: description ?? this.description,
      goalIds: goalIds ?? List<int>.from(this.goalIds),
      appearanceCount: appearanceCount ?? this.appearanceCount,
      importance: importance ?? this.importance,
      display: display ?? this.display,
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

  // Decrement appearance count
  bool decrementAppearance() {
    if (appearanceCount > 0) {
      appearanceCount--;
      return true;
    }
    return false;
  }

  // Check if task should be deleted
  bool get shouldBeDeleted => appearanceCount <= 0;

  // Activate task for display
  bool activate() {
    if (appearanceCount > 0 && !display) {
      display = true;
      appearanceCount--;
      return true;
    }
    return false;
  }
}
