// lib/core/model/quote.dart
// This file defines the data model for a 'Quote'.
// It includes the quote's content and its source (title/author), and is
// configured for local persistence using Hive.

import 'package:hive/hive.dart';

// Specifies the file where Hive's code generator will place the TypeAdapter.
part 'quote.g.dart';

/// Represents a single quote, containing the text and its source.
///
/// This class is a `HiveObject`, which allows instances to be stored
/// directly in a Hive box for local data persistence.
@HiveType(typeId: 10) // Unique ID for the Hive TypeAdapter.
class Quote extends HiveObject {
  /// The source of the quote, such as the author's name or the work it's from.
  @HiveField(0)
  String title;

  /// The main content of the quote.
  @HiveField(1)
  String quote;

  /// Creates a new `Quote` instance.
  Quote({
    required this.title,
    required this.quote,
  });

  /// Creates a new `Quote` instance with updated values.
  ///
  /// This method supports immutable updates by creating a copy of the
  /// current object with any specified fields replaced with new values.
  Quote copyWith({
    String? title,
    String? quote,
  }) {
    return Quote(
      title: title ?? this.title,
      quote: quote ?? this.quote,
    );
  }

  /// Provides a user-friendly string representation of the `Quote`.
  ///
  /// Overriding this method is useful for debugging and logging, as it
  /// formats the output as "quote - title".
  @override
  String toString() {
    return "$quote - $title";
  }
}