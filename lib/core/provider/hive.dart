// lib/core/provider/hive_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hive.dart';
import '../../main.dart';

final hiveRepositoryProvider = Provider<HiveRepository>((ref) => repository);
