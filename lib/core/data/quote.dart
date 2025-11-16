/// This file manages the state and loading of inspirational quotes for the application.
/// It uses Riverpod for state management, Hive for local caching, and loads
/// initial data from a CSV file located in the assets folder.

import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../model/quote.dart';

/// The name of the Hive box used to store quote objects locally.
const String quotesBoxName = 'quotes';

/// A top-level function designed to run in a separate isolate via `compute`.
/// It parses a raw CSV string into a list of lists to avoid blocking the UI thread.
List<List<dynamic>> _parseCsvInBackground(String rawCsv) {
  final result = const CsvToListConverter(eol: '\n').convert(rawCsv);
  return result;
}

/// A provider that manages the asynchronous loading and state of the quotes list.
/// UI components can watch this provider to display quotes and handle loading/error states.
final quoteProvider = AsyncNotifierProvider<QuoteNotifier, List<Quote>>(() {
  return QuoteNotifier();
});

/// Manages the state of the quotes list, handling the initial loading from
/// a CSV asset and subsequent retrieval from the local Hive database.
class QuoteNotifier extends AsyncNotifier<List<Quote>> {
  /// The core method of the AsyncNotifier, responsible for initializing the state.
  /// It first checks the local Hive database. If quotes are present, it loads them.
  /// If not, it initiates the process of loading from the CSV asset.
  @override
  Future<List<Quote>> build() async {
    try {
      final box = await Hive.openBox<Quote>(quotesBoxName);

      if (box.isEmpty) {
        // If the local cache is empty, load data from the CSV file.
        final loadedQuotes = await _load(box);
        return loadedQuotes;
      } else {
        // If quotes exist in the cache, load them directly.
        final quotesFromHive = box.values.toList();
        return quotesFromHive;
      }
    } catch (e) {
      // If an error occurs, rethrow it to put the provider in an error state.
      rethrow;
    }
  }

  /// Loads quotes from the 'assets/quotes.csv' file, parses them, and
  /// stores them in the provided Hive box for future use.
  Future<List<Quote>> _load(Box<Quote> box) async {
    try {
      // Load the raw CSV data from the asset bundle.
      final rawData = await rootBundle.loadString('assets/quotes.csv');
      // Parse the CSV data in a background isolate to prevent UI jank.
      final listData = await compute(_parseCsvInBackground, rawData);

      final List<Quote> quotesToStore = [];
      // Iterate from 1 to skip the header row of the CSV.
      for (var i = 1; i < listData.length; i++) {
        final row = listData[i];
        if (row.length >= 2) {
          quotesToStore.add(
            Quote(quote: row[0].toString(), title: row[1].toString()),
          );
        }
      }

      // Store the parsed quotes in the Hive box for persistence.
      await box.addAll(quotesToStore);
      return quotesToStore;
    } catch (e) {
      // Propagate the error up if loading or parsing fails.
      rethrow;
    }
  }

  /// Returns a random quote as a formatted string from the current state.
  /// Returns null if the state has not been successfully loaded or is empty.
  String? getRandomQuote() {
    final quotes = state.value;
    if (quotes == null || quotes.isEmpty) {
      return null; // No quotes available.
    }
    final random = Random();
    final index = random.nextInt(quotes.length);
    return quotes[index].toString();
  }
}
