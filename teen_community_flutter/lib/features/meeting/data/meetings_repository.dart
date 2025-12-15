import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/meeting_model.dart';

/// 모임 Repository
class MeetingsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 모임 목록 조회 (카테고리별 필터링)
  Future<List<MeetingModel>> getMeetings({String? category}) async {
    try {
      var query = _supabase
          .from('meetings')
          .select();

      if (category != null && category != 'all') {
        query = query.eq('category', category);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((meeting) {
        return MeetingModel.fromJson(meeting);
      }).toList();
    } catch (e) {
      throw Exception('모임 목록을 불러올 수 없습니다: $e');
    }
  }

  /// 모임 생성
  Future<MeetingModel> createMeeting({
    required String title,
    required String description,
    required String category,
    required String location,
    required DateTime meetingDate,
    required int maxParticipants,
    required String creatorNickname,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      final response = await _supabase
          .from('meetings')
          .insert({
            'title': title,
            'description': description,
            'category': category,
            'location': location,
            'meeting_date': meetingDate.toIso8601String(),
            'max_participants': maxParticipants,
            'participants': [userId],
            'creator_id': userId,
            'creator_nickname': creatorNickname,
          })
          .select()
          .single();

      return MeetingModel.fromJson(response);
    } catch (e) {
      throw Exception('모임 생성에 실패했습니다: $e');
    }
  }

  /// 모임 참가
  Future<MeetingModel> joinMeeting(String meetingId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      // 현재 모임 정보 조회
      final meeting = await _supabase
          .from('meetings')
          .select()
          .eq('id', meetingId)
          .single();

      final participants = List<String>.from(meeting['participants'] ?? []);

      // 이미 참가했는지 확인
      if (participants.contains(userId)) {
        throw Exception('이미 참가한 모임입니다');
      }

      // 인원이 가득 찼는지 확인
      if (participants.length >= meeting['max_participants']) {
        throw Exception('참가 인원이 가득 찼습니다');
      }

      // 참가자 추가
      participants.add(userId);

      final response = await _supabase
          .from('meetings')
          .update({'participants': participants})
          .eq('id', meetingId)
          .select()
          .single();

      return MeetingModel.fromJson(response);
    } catch (e) {
      throw Exception('모임 참가에 실패했습니다: $e');
    }
  }

  /// 모임 탈퇴
  Future<MeetingModel> leaveMeeting(String meetingId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      // 현재 모임 정보 조회
      final meeting = await _supabase
          .from('meetings')
          .select()
          .eq('id', meetingId)
          .single();

      final participants = List<String>.from(meeting['participants'] ?? []);

      // 참가자에서 제거
      participants.remove(userId);

      final response = await _supabase
          .from('meetings')
          .update({'participants': participants})
          .eq('id', meetingId)
          .select()
          .single();

      return MeetingModel.fromJson(response);
    } catch (e) {
      throw Exception('모임 탈퇴에 실패했습니다: $e');
    }
  }

  /// 모임 삭제 (주최자만 가능)
  Future<void> deleteMeeting(String meetingId) async {
    try {
      await _supabase.from('meetings').delete().eq('id', meetingId);
    } catch (e) {
      throw Exception('모임 삭제에 실패했습니다: $e');
    }
  }
}
