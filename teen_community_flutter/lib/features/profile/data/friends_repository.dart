import 'package:supabase_flutter/supabase_flutter.dart';

/// 친구 모델
class FriendModel {
  final String id;
  final String nickname;
  final int level;
  final DateTime createdAt;

  const FriendModel({
    required this.id,
    required this.nickname,
    required this.level,
    required this.createdAt,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      level: json['level'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// 친구 Repository
class FriendsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 친구 목록 조회
  Future<List<FriendModel>> getFriends() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      final response = await _supabase
          .from('friends')
          .select('''
            friend_id,
            profiles:friend_id (
              id,
              nickname,
              level,
              created_at
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((friend) {
        final profile = friend['profiles'];
        return FriendModel.fromJson(profile);
      }).toList();
    } catch (e) {
      // 백엔드 테이블이 없거나 오류 발생 시 빈 리스트 반환 (또는 더미 데이터)
      // 앱이 죽지 않도록 예외 처리
      print('친구 목록 로드 실패 (백엔드 오류 무시): $e');
      return []; 
    }
  }

  /// 친구 요청 보내기
  Future<void> sendFriendRequest(String friendId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      // 이미 친구인지 확인
      final existing = await _supabase
          .from('friends')
          .select()
          .eq('user_id', userId)
          .eq('friend_id', friendId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('이미 친구입니다');
      }

      // 양방향 친구 관계 생성
      await _supabase.from('friends').insert([
        {'user_id': userId, 'friend_id': friendId},
        {'user_id': friendId, 'friend_id': userId},
      ]);
    } catch (e) {
      throw Exception('친구 추가에 실패했습니다: $e');
    }
  }

  /// 친구 삭제
  Future<void> removeFriend(String friendId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      // 양방향 친구 관계 삭제
      await _supabase
          .from('friends')
          .delete()
          .or('user_id.eq.$userId,friend_id.eq.$userId')
          .or('user_id.eq.$friendId,friend_id.eq.$friendId');
    } catch (e) {
      throw Exception('친구 삭제에 실패했습니다: $e');
    }
  }

  /// 사용자 검색 (닉네임으로)
  Future<List<FriendModel>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final response = await _supabase
          .from('profiles')
          .select()
          .ilike('nickname', '%$query%')
          .limit(20);

      return (response as List).map((user) {
        return FriendModel.fromJson(user);
      }).toList();
    } catch (e) {
      throw Exception('사용자 검색에 실패했습니다: $e');
    }
  }

  /// 친구 여부 확인
  Future<bool> isFriend(String friendId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('friends')
          .select()
          .eq('user_id', userId)
          .eq('friend_id', friendId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
