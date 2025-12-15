import 'package:supabase_flutter/supabase_flutter.dart';
import '../../places/domain/models/place_model.dart';

/// 북마크 Repository
class BookmarksRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 북마크한 장소 목록 조회
  Future<List<PlaceModel>> getBookmarkedPlaces() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      final response = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((bookmark) {
        return PlaceModel.fromJson(bookmark);
      }).toList();
    } catch (e) {
      throw Exception('북마크 목록을 불러올 수 없습니다: $e');
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
      if (userId == null) throw Exception('로그인이 필요합니다');

      await _supabase.from('bookmarks').insert({
        'user_id': userId,
        'place_name': placeName,
        'place_url': placeUrl,
        'category': category,
        'location': location,
        'address': address,
        'phone': phone,
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
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
