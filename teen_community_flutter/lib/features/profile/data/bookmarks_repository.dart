import 'package:supabase_flutter/supabase_flutter.dart';
import '../../places/domain/models/place_model.dart';

/// 북마크 Repository
class BookmarksRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 북마크한 장소 목록 조회
  Future<List<PlaceModel>> getBookmarkedPlaces() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((bookmark) {
        // DB 컬럼을 PlaceModel 필드로 매핑 (최소한의 컬럼만 사용)
        return PlaceModel(
          id: bookmark['place_url'] ?? '',
          name: bookmark['place_name'] ?? '',
          category: PlaceCategory.cafe, // 기본값 사용
          location: '',
          address: '',
          phone: '',
          distance: '',
          url: bookmark['place_url'] ?? '',
          x: 0.0,
          y: 0.0,
        );
      }).toList();
    } catch (e) {
      print('북마크 목록 로드 실패: $e');
      return [];
    }
  }

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
    try {
      final userId = _supabase.auth.currentUser?.id;
      print('📌 addBookmark 호출: userId=$userId, placeName=$placeName');
      if (userId == null) throw Exception('로그인이 필요합니다');

      // 최소한의 필수 컬럼만 사용
      await _supabase.from('bookmarks').insert({
        'user_id': userId,
        'place_url': placeUrl,
        'place_name': placeName,
      });
      print('📌 북마크 추가 성공!');
    } catch (e) {
      print('📌 북마크 추가 실패: $e');
      throw Exception('북마크 추가에 실패했습니다: $e');
    }
  }

  /// 북마크 삭제
  Future<void> removeBookmark(String placeUrl) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      await _supabase
          .from('bookmarks')
          .delete()
          .eq('user_id', userId)
          .eq('place_url', placeUrl);
    } catch (e) {
      throw Exception('북마크 삭제에 실패했습니다: $e');
    }
  }

  /// 북마크 여부 확인
  Future<bool> isBookmarked(String placeUrl) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .eq('place_url', placeUrl)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
