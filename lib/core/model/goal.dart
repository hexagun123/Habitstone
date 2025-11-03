import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/util.dart';

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

  @HiveField(5) // New field
  late String id;

  // Private constructor for internal use by the factory.
  Goal._({
    required this.title,
    required this.description,
    required this.streak,
    required this.lastUpdate,
    required this.updated,
    required this.id,
  });

  // Public factory constructor for creating instances.
  factory Goal({
    required String title,
    required String description,
    int streak = 0,
    DateTime? lastUpdate,
    bool updated = false,
    String? id,
  }) {
    // Handle default values and ID generation here.
    final newId = id ?? const Uuid().v4();
    final newLastUpdate = lastUpdate ?? DateUtil.now().subtract(const Duration(days: 10));

    // Call the private constructor to create the instance.
    return Goal._(
      title: title,
      description: description,
      streak: streak,
      lastUpdate: newLastUpdate,
      updated: updated,
      id: newId,
    );
  }
  
  // --- Methods for Firebase ---
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal._(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      streak: json['streak'],
      lastUpdate: (json['lastUpdate'] as Timestamp).toDate(),
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'streak': streak,
      'lastUpdate': lastUpdate,
      'updated': updated,
    };
  }
  
  Goal copyWith({
    String? title,
    String? description,
    int? streak,
    DateTime? lastUpdate,
    bool? updated,
    String? id,
  }) {
    return Goal._(
      title: title ?? this.title,
      description: description ?? this.description,
      streak: streak ?? this.streak,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      updated: updated ?? this.updated,
      id: id ?? this.id,
    );
  }

  @override
  String toString() {
    return 'Goal{id: $id, title: $title, streak: $streak}';
  }
}