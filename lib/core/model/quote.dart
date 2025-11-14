import 'package:hive/hive.dart';

part 'quote.g.dart';

@HiveType(typeId: 10)
class Quote extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String quote;

  Quote({
    required this.title,
    required this.quote,
  });

  Quote copyWith({
    String? title,
    String? quote,
  }) {
    return Quote(
      title: title ?? this.title,
      quote: quote ?? this.quote,
    );
  }

  @override
  String toString() {
    return quote + " - " + title;
  }
}
