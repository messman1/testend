import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';
import '../domain/models/user_model.dart';

/// AuthRepository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// 인증 상태 Provider (로그인 여부)
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// 현재 사용자 프로필 Provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  // 인증 상태 변경 감지
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) async {
      if (state.session == null) return null;

      final repository = ref.read(authRepositoryProvider);
      return await repository.getCurrentUserProfile();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// 로그인 상태 Controller
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.data(null));

  /// 회원가입
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        nickname: nickname,
      );
      state = const AsyncValue.data(null);
      return user;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// 로그인
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.signIn(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
      return user;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// 비밀번호 재설정
  Future<void> resetPassword({required String email}) async {
    state = const AsyncValue.loading();

    try {
      await _repository.resetPassword(email: email);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// AuthController Provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
