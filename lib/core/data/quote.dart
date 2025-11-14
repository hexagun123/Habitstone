import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../model/quote.dart';

const String quotesBoxName = 'quotes';

List<List<dynamic>> _parseCsvInBackground(String rawCsv) {
  final result = const CsvToListConverter(eol: '\n').convert(rawCsv);
  return result;
}

final quoteProvider = AsyncNotifierProvider<QuoteNotifier, List<Quote>>(() {
  return QuoteNotifier();
});

class QuoteNotifier extends AsyncNotifier<List<Quote>> {
  @override
  Future<List<Quote>> build() async {
    try {
      final box = await Hive.openBox<Quote>(quotesBoxName);

      if (box.isEmpty) {
        // The await here is crucial. Execution will pause until _load() completes or throws an error.
        final loadedQuotes = await _load(box);
        return loadedQuotes;
      } else {
        final quotesFromHive = box.values.toList();
        return quotesFromHive;
      }
    } catch (e) {
      rethrow; // Rethrow to put the provider in an error state.
    }
  }

  Future<List<Quote>> _load(Box<Quote> box) async {
    try {
      final rawData = await rootBundle.loadString('assets/quotes.csv');
      final listData = await compute(_parseCsvInBackground, rawData);

      final List<Quote> quotesToStore = [];
      for (var i = 1; i < listData.length; i++) {
        final row = listData[i];
        if (row.length >= 2) {
          quotesToStore.add(
            Quote(quote: row[0].toString(), title: row[1].toString()),
          );
        }
      }

      await box.addAll(quotesToStore);
      return quotesToStore;
    } catch (e) {
      // Consider logging the error to a service.
      rethrow;
    }
  }

  String? getRandomQuote() {
    final quotes = state.value;
    if (quotes == null || quotes.isEmpty) {
      return null;
    }
    final random = Random();
    final index = random.nextInt(quotes.length);
    return quotes[index].toString();
  }
}
