// lib/core/provider/hive_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hive.dart';

final hiveRepositoryProvider = Provider<HiveRepository>((ref) {
  throw UnimplementedError('hiveRepositoryProvider must be overridden');
});
