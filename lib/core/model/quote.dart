// lib/core/model/quote.dart
// quote model

import 'package:hive/hive.dart';

part 'quote.g.dart';

@HiveType(typeId: 10)
class Quote extends HiveObject {
  @HiveField(0)
  String author;

  @HiveField(1)
  String quote;

  /// Creates a new `Quote` instance.
  Quote({
    required this.author,
    required this.quote,
  });

  /// basic functions
  Quote copyWith({
    String? author,
    String? quote,
  }) {
    return Quote(
      author: author ?? this.author,
      quote: quote ?? this.quote,
    );
  }

  @override
  String toString() {
    return "$quote - $author";
  }
}
