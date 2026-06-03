import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/car_rental_repository.dart';

final authTokenProvider = StateProvider<String?>((_) => null);

class AuthState {
  const AuthState({required this.token, required this.user});
  final String token;
  final RentalUser user;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState?>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState?> {
  AuthNotifier(this._ref) : super(null) {
    _restore();
  }

  final Ref _ref;

  Future<void> _restore() async {
    final token = await _ref.read(tokenStorageProvider).read();
    if (token == null) return;
    _ref.read(authTokenProvider.notifier).state = token;
    try {
      final user = await _ref.read(carRentalRepositoryProvider).me();
      state = AuthState(token: token, user: user);
    } catch (_) {
      await _ref.read(tokenStorageProvider).clear();
      _ref.read(authTokenProvider.notifier).state = null;
    }
  }

  Future<void> login(String phone, String password) async {
    final repo = _ref.read(carRentalRepositoryProvider);
    final result = await repo.login(phone, password);
    await _ref.read(tokenStorageProvider).write(result.token);
    _ref.read(authTokenProvider.notifier).state = result.token;
    state = AuthState(token: result.token, user: result.user);
  }

  Future<void> logout() async {
    try {
      await _ref.read(carRentalRepositoryProvider).logout();
    } catch (_) {}
    await _ref.read(tokenStorageProvider).clear();
    _ref.read(authTokenProvider.notifier).state = null;
    state = null;
  }
}
