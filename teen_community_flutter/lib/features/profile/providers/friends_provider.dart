import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/friends_repository.dart';

/// FriendsRepository Provider
final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return FriendsRepository();
});

/// 친구 목록 Provider
final friendsProvider = FutureProvider<List<FriendModel>>((ref) async {
  final repository = ref.watch(friendsRepositoryProvider);
  return await repository.getFriends();
});

/// 친구 Controller
class FriendsController extends StateNotifier<AsyncValue<void>> {
  final FriendsRepository _repository;
  final Ref _ref;

  FriendsController(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// 친구 요청 보내기
  Future<void> sendFriendRequest(String friendId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.sendFriendRequest(friendId);
      // 친구 목록 새로고침
      _ref.invalidate(friendsProvider);
    });
  }

  /// 친구 삭제
  Future<void> removeFriend(String friendId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.removeFriend(friendId);
      // 친구 목록 새로고침
      _ref.invalidate(friendsProvider);
    });
  }

  /// 사용자 검색
  Future<List<FriendModel>> searchUsers(String query) async {
    return await _repository.searchUsers(query);
  }
}

/// FriendsController Provider
final friendsControllerProvider = StateNotifierProvider<FriendsController, AsyncValue<void>>((ref) {
  final repository = ref.watch(friendsRepositoryProvider);
  return FriendsController(repository, ref);
});

/// 친구 여부 확인 Provider
final isFriendProvider = FutureProvider.family<bool, String>((ref, friendId) async {
  final repository = ref.watch(friendsRepositoryProvider);
  return await repository.isFriend(friendId);
});
