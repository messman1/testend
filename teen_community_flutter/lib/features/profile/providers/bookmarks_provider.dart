import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/bookmarks_repository.dart';
import '../../places/domain/models/place_model.dart';

/// BookmarksRepository Provider
final bookmarksRepositoryProvider = Provider<BookmarksRepository>((ref) {
  return BookmarksRepository();
});

/// 북마크 목록 Provider
final bookmarkedPlacesProvider = FutureProvider<List<PlaceModel>>((ref) async {
  final repository = ref.watch(bookmarksRepositoryProvider);
  return await repository.getBookmarkedPlaces();
});

/// 북마크 Controller
class BookmarksController extends StateNotifier<AsyncValue<void>> {
  final BookmarksRepository _repository;
  final Ref _ref;

  BookmarksController(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// 북마크 추가
  Future<void> addBookmark({
    required String placeName,
    required String placeUrl,
    required String category,
    required String location,
    required String address,
    required String phone,
    required double latitude,
    required double longitude,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addBookmark(
        placeName: placeName,
        placeUrl: placeUrl,
        category: category,
        location: location,
        address: address,
        phone: phone,
        latitude: latitude,
        longitude: longitude,
      );
      // 북마크 목록 새로고침
      _ref.invalidate(bookmarkedPlacesProvider);
    });
  }

  /// 북마크 삭제
  Future<void> removeBookmark(String placeUrl) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.removeBookmark(placeUrl);
      // 북마크 목록 새로고침
      _ref.invalidate(bookmarkedPlacesProvider);
    });
  }

  /// 북마크 토글
  Future<bool> toggleBookmark({
    required String placeName,
    required String placeUrl,
    required String category,
    required String location,
    required String address,
    required String phone,
    required double latitude,
    required double longitude,
  }) async {
    final isBookmarked = await _repository.isBookmarked(placeUrl);

    if (isBookmarked) {
      await removeBookmark(placeUrl);
      return false;
    } else {
      await addBookmark(
        placeName: placeName,
        placeUrl: placeUrl,
        category: category,
        location: location,
        address: address,
        phone: phone,
        latitude: latitude,
        longitude: longitude,
      );
      return true;
    }
  }
}

/// BookmarksController Provider
final bookmarksControllerProvider = StateNotifierProvider<BookmarksController, AsyncValue<void>>((ref) {
  final repository = ref.watch(bookmarksRepositoryProvider);
  return BookmarksController(repository, ref);
});

/// 북마크 여부 확인 Provider
final isBookmarkedProvider = FutureProvider.family<bool, String>((ref, placeUrl) async {
  final repository = ref.watch(bookmarksRepositoryProvider);
  return await repository.isBookmarked(placeUrl);
});
