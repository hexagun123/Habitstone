// models/goal.dart
import 'package:hive/hive.dart';
import '../data/util.dart'; // Added import

part 'goal.g.dart';

@HiveType(typeId: 0)
class Goal extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  int streak;

  @HiveField(3)
  DateTime lastUpdate;

  @HiveField(4)
  bool updated;

  Goal({
    required this.title,
    required this.description,
    this.streak = 0,
    DateTime? lastUpdate,
    this.updated = false,
  }) : lastUpdate = lastUpdate ?? DateTime.now().toUtc(); // Use UTC

  Goal copyWith({
    String? title,
    String? description,
    int? streak,
    DateTime? lastUpdate,
    bool? updated,
  }) {
    return Goal(
      title: title ?? this.title,
      description: description ?? this.description,
      streak: streak ?? this.streak,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      updated: updated ?? this.updated,
    );
  }

  bool get needsUpdate {
    final now = DateTime.now().toUtc();
    final today = DateUtils.toMidnight(now);
    final lastUpdateDate = DateUtils.toMidnight(lastUpdate);
    return lastUpdateDate.isBefore(today) || !updated;
  }
}
