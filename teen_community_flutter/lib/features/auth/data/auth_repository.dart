import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/user_model.dart';

/// 인증 관련 데이터 처리 리포지토리
class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 현재 로그인된 사용자 가져오기
  User? get currentUser => _supabase.auth.currentUser;

  /// 인증 상태 변경 스트림
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// 이메일/비밀번호로 회원가입
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      // 1. Supabase Auth에 회원가입
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('회원가입에 실패했습니다.');
      }

      final userId = authResponse.user!.id;

      // 2. profiles 테이블에 프로필 생성
      final profileData = {
        'id': userId,
        'email': email,
        'nickname': nickname,
        'level': 1,
        'points': 0,
        'badges': [],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('profiles').insert(profileData);

      // 3. 생성된 프로필 반환
      return UserModel.fromJson(profileData);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } on PostgrestException catch (e) {
      throw Exception('프로필 생성 실패: ${e.message}');
    } catch (e) {
      throw Exception('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  /// 이메일/비밀번호로 로그인
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Supabase Auth로 로그인
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('로그인에 실패했습니다.');
      }

      // 2. profiles 테이블에서 사용자 프로필 가져오기
      final userId = authResponse.user!.id;
      final profileResponse = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(profileResponse);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } on PostgrestException catch (e) {
      throw Exception('프로필 조회 실패: ${e.message}');
    } catch (e) {
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  /// 현재 사용자 프로필 가져오기
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final profileResponse = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(profileResponse);
    } on PostgrestException catch (e) {
      throw Exception('프로필 조회 실패: ${e.message}');
    } catch (e) {
      throw Exception('프로필 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 프로필 업데이트
  Future<UserModel> updateProfile({
    required String userId,
    String? nickname,
    int? level,
    int? points,
    List<String>? badges,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (nickname != null) updateData['nickname'] = nickname;
      if (level != null) updateData['level'] = level;
      if (points != null) updateData['points'] = points;
      if (badges != null) updateData['badges'] = badges;

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('프로필 업데이트 실패: ${e.message}');
    } catch (e) {
      throw Exception('프로필 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('비밀번호 재설정 중 오류가 발생했습니다: $e');
    }
  }

  /// AuthException 처리 (사용자 친화적인 에러 메시지로 변환)
  String _handleAuthException(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('Invalid login credentials')) {
          return '이메일 또는 비밀번호가 올바르지 않습니다.';
        }
        return '잘못된 요청입니다.';
      case '422':
        if (e.message.contains('User already registered')) {
          return '이미 등록된 이메일입니다.';
        }
        return '입력 정보를 확인해주세요.';
      case '429':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      default:
        return e.message;
    }
  }
}
