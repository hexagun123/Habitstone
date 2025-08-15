// core/model/goal.dart
import 'package:hive/hive.dart';
import '../data/util.dart'; 

// prompt auto generation
part 'goal.g.dart';

// hive object of goal
// definition of a goal: something long term that one might want to work on
// eg: physical health
// that one is willing to give consistent effort creating tasks to work on

@HiveType(typeId: 0)
class Goal extends HiveObject { 

    // fields
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

    // constructor
  Goal({
    // attributes
    required this.title,
    required this.description,
    this.streak = 0, // streak is automaticlly set to zero
    DateTime? lastUpdate,      
    this.updated = false,

  }) : lastUpdate = lastUpdate ??
    DateUtil.now() // straight into utc
    .subtract(const Duration(days: 10));

  // copywith
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

  // check if streak needs update
  bool get needsUpdate {
    final now = DateUtil.now();
    final today = DateUtil.toMidnight(now);
    final lastUpdateDate = DateUtil.toMidnight(lastUpdate);
    return lastUpdateDate.isBefore(today) || !updated;
  }

  // to string for easy debug
  @override
  String toString() {
    return 'Goal{title: $title, streak: $streak, lastUpdate: $lastUpdate, updated: $updated}';
  }
}
