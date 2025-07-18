// lib/features/auth/presentation/controllers/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repo.dart';
import '../../../core/provider/user.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  
  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.signInWithEmailAndPassword(email, password),
    );
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.createUserWithEmailAndPassword(email, password),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signOut());
  }
}

// Provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});