// lib/core/provider/hive_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hive.dart';

// This is the corrected provider.
final hiveRepositoryProvider = Provider<HiveRepository>((ref) {
  return HiveRepository();
});