// lib/features/auth/presentation/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repo.dart';
import '../model/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).user;
});
