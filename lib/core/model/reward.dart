// lib/core/model/reward.dart
// This file stores the reward model

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// Specifies the file where Hive's code generator will place the TypeAdapter.
part 'reward.g.dart';

/// Represents a user-definable reward within the application.
@HiveType(typeId: 2) 
class Reward extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  // How long the reward lasts
  @HiveField(2)
  int time;

  /// A value indicating the rarity or significance of the reward.
  @HiveField(3)
  int rarity;

  @HiveField(4)
  late String id;

  Reward._({
    required this.title,
    required this.description,
    required this.time,
    required this.rarity,
    required this.id,
  });

  /// If an `id` is not provided, a unique v4 UUID is automatically generated.
  factory Reward({
    required String title,
    required String description,
    required int time,
    required int rarity,
    String? id,
  }) {
    final newId = id ?? const Uuid().v4(); // Generate a new ID if one isn't provided.
    return Reward._(
      title: title,
      description: description,
      time: time,
      rarity: rarity,
      id: newId,
    );
  }

  /// Creates a `Reward` instance from a JSON map (e.g., data from Firebase).
  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward._(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      time: json['time'],
      rarity: json['rarity'],
    );
  }

  /// serializing for json usage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'rarity': rarity,
    };
  }

  Reward copyWith({
    String? title,
    String? description,
    int? time,
    int? rarity,
    String? id,
  }) {
    return Reward._(
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      rarity: rarity ?? this.rarity,
      id: id ?? this.id,
    );
  }
}