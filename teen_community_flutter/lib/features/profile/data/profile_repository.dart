import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      // 1. Get Post Count
      final postResponse = await _supabase
          .from('posts')
          .select('*')
          .eq('user_id', userId)
          .count(CountOption.exact);
      
      final postCount = postResponse.count;

      // 2. Get Meeting Count (where participants array contains userId)
      final meetingResponse = await _supabase
          .from('meetings')
          .select('*')
          .contains('participants', [userId])
          .count(CountOption.exact);

      final meetingCount = meetingResponse.count;

      // 3. Get Bookmark Count
      final bookmarkResponse = await _supabase
          .from('bookmarks')
          .select('*')
          .eq('user_id', userId)
          .count(CountOption.exact);

      final bookmarkCount = bookmarkResponse.count;

      return {
        'postCount': postCount,
        'meetingCount': meetingCount,
        'bookmarkCount': bookmarkCount,
      };
    } catch (e) {
      print('Stats fetch error: $e');
      return {
        'postCount': 0,
        'meetingCount': 0,
        'bookmarkCount': 0,
      };
    }
  }
}
