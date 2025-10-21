import 'package:hive/hive.dart';

// auto build
part 'reward.g.dart';

// hive template for a reward
@HiveType(typeId: 2) // Changed typeId to 2 since the enum is removed
class Reward extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  int time;

  @HiveField(3)
  int rarity; // Changed to int

  // constructor
  Reward({
    required this.title,
    required this.description,
    required this.time,
    required this.rarity,
  });

  Reward copyWith({
    String? title,
    String? description,
    int? time,
    int? rarity, // Changed to int
  }) {
    return Reward(
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      rarity: rarity ?? this.rarity,
    );
  }
}
