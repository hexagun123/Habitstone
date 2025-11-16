// lib/core/model/reward.dart
// This file defines the data model for a 'Reward'.
// It includes properties for the reward's details, Hive type adapters for local
// persistence, and serialization methods for remote database synchronization (e.g., Firebase).

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// Specifies the file where Hive's code generator will place the TypeAdapter.
part 'reward.g.dart';

/// Represents a user-definable reward within the application.
///
/// This class is a `HiveObject`, allowing instances to be stored directly
/// in a Hive box for efficient local data persistence.
@HiveType(typeId: 2) // Unique ID for the Hive TypeAdapter.
class Reward extends HiveObject {
  /// The title or name of the reward.
  @HiveField(0)
  String title;

  /// A detailed description of the reward.
  @HiveField(1)
  String description;

  /// An associated value, often representing the "cost" or "time" required to earn it.
  @HiveField(2)
  int time;

  /// A value indicating the rarity or significance of the reward.
  @HiveField(3)
  int rarity;

  /// A unique identifier for the reward instance.
  @HiveField(4)
  late String id;

  /// Private constructor for internal use by factories and the `copyWith` method.
  Reward._({
    required this.title,
    required this.description,
    required this.time,
    required this.rarity,
    required this.id,
  });

  /// Creates a new `Reward` instance.
  ///
  /// If an `id` is not provided, a unique v4 UUID is automatically generated.
  /// This is the primary constructor for creating new rewards.
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

  // --- Methods for Serialization ---

  /// Creates a `Reward` instance from a JSON map (e.g., data from Firebase).
  ///
  /// This factory is essential for deserializing data from a remote data source.
  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward._(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      time: json['time'],
      rarity: json['rarity'],
    );
  }

  /// Converts the `Reward` instance into a JSON map.
  ///
  /// This method is used for serializing the object to be stored in a remote
  /// database like Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'rarity': rarity,
    };
  }

  /// Creates a new `Reward` instance with updated values.
  ///
  /// This method is useful for immutable state management, allowing for the
  /// creation of a modified copy without altering the original object.
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