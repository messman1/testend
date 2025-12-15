import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/meetings_repository.dart';
import '../domain/models/meeting_model.dart';

/// MeetingsRepository Provider
final meetingsRepositoryProvider = Provider<MeetingsRepository>((ref) {
  return MeetingsRepository();
});

/// 모임 목록 Provider (카테고리별 필터링)
final meetingsProvider = FutureProvider.family<List<MeetingModel>, String?>((ref, category) async {
  final repository = ref.watch(meetingsRepositoryProvider);
  return await repository.getMeetings(category: category);
});

/// 모임 Controller
class MeetingsController extends StateNotifier<AsyncValue<void>> {
  final MeetingsRepository _repository;
  final Ref _ref;

  MeetingsController(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// 모임 생성
  Future<void> createMeeting({
    required String title,
    required String description,
    required String category,
    required String location,
    required DateTime meetingDate,
    required int maxParticipants,
    required String creatorNickname,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createMeeting(
        title: title,
        description: description,
        category: category,
        location: location,
        meetingDate: meetingDate,
        maxParticipants: maxParticipants,
        creatorNickname: creatorNickname,
      );
      // 모임 목록 새로고침
      _ref.invalidate(meetingsProvider);
    });
  }

  /// 모임 참가
  Future<void> joinMeeting(String meetingId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.joinMeeting(meetingId);
      // 모임 목록 새로고침
      _ref.invalidate(meetingsProvider);
    });
  }

  /// 모임 탈퇴
  Future<void> leaveMeeting(String meetingId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.leaveMeeting(meetingId);
      // 모임 목록 새로고침
      _ref.invalidate(meetingsProvider);
    });
  }

  /// 모임 삭제
  Future<void> deleteMeeting(String meetingId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteMeeting(meetingId);
      // 모임 목록 새로고침
      _ref.invalidate(meetingsProvider);
    });
  }
}

/// MeetingsController Provider
final meetingsControllerProvider = StateNotifierProvider<MeetingsController, AsyncValue<void>>((ref) {
  final repository = ref.watch(meetingsRepositoryProvider);
  return MeetingsController(repository, ref);
});
