import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'reward.g.dart';

@HiveType(typeId: 2)
class Reward extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  int time;

  @HiveField(3)
  int rarity;
  
  @HiveField(4) // New field
  late String id;

  // Private constructor
  Reward._({
    required this.title,
    required this.description,
    required this.time,
    required this.rarity,
    required this.id,
  });
  
  // Public factory constructor
  factory Reward({
    required String title,
    required String description,
    required int time,
    required int rarity,
    String? id,
  }) {
    final newId = id ?? const Uuid().v4();
    return Reward._(
      title: title,
      description: description,
      time: time,
      rarity: rarity,
      id: newId,
    );
  }

  // --- Methods for Firebase ---
  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward._(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      time: json['time'],
      rarity: json['rarity'],
    );
  }

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