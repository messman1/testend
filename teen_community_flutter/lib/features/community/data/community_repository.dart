import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/post_model.dart';
import '../domain/models/comment_model.dart';

class CommunityRepository {
  final SupabaseClient _supabase;

  CommunityRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 게시글 목록 가져오기 (JS Logic: Posts -> Profiles -> Join)
  Future<List<PostModel>> getPosts({PostType? type}) async {
    try {
      // 1. Fetch Posts
      var query = _supabase.from('posts').select();

      if (type != null && type != PostType.normal) {
        query = query.eq('type', PostModel.typeToString(type));
      }

      final response = await query.order('created_at', ascending: false);
      final List<dynamic> postsData = response as List<dynamic>;

      if (postsData.isEmpty) return [];

      // 2. Fetch Profiles map
      final userIds = postsData.map((p) => p['user_id'] as String).toSet().toList();
      final profilesResponse = await _supabase
          .from('profiles')
          .select('id, nickname')
          .inFilter('id', userIds);
      
      final Map<String, String> profileMap = {};
      for (var p in (profilesResponse as List<dynamic>)) {
        profileMap[p['id']] = p['nickname'] ?? '익명';
      }

      // 3. Merge
      return postsData.map((json) {
        final userId = json['user_id'];
        final nickname = profileMap[userId] ?? '익명';
        // Inject nickname into json before parsing
        final newJson = Map<String, dynamic>.from(json);
        newJson['author_nickname'] = nickname;
        return PostModel.fromJson(newJson);
      }).toList();

    } catch (e) {
      throw Exception('게시글을 불러오는데 실패했습니다: $e');
    }
  }
  
  /// 게시글 상세 조회
  Future<PostModel> getPostById(String postId) async {
    try {
      // 1. Fetch Post
      final postData = await _supabase
          .from('posts')
          .select()
          .eq('id', postId)
          .single();
          
      // 2. Fetch Profile
      final userId = postData['user_id'];
      final profileData = await _supabase
          .from('profiles')
          .select('nickname')
          .eq('id', userId)
          .single();
          
      final nickname = profileData['nickname'] ?? '익명';

      // 3. Merge
      final newJson = Map<String, dynamic>.from(postData);
      newJson['author_nickname'] = nickname;
      
      return PostModel.fromJson(newJson);
    } catch (e) {
      throw Exception('게시글 상세 정보를 불러오는데 실패했습니다: $e');
    }
  }

  /// 좋아요 토글
  Future<bool> toggleLike(String postId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    try {
      // 좋아요 여부 확인
      final existingLike = await _supabase
          .from('likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        // 이미 좋아요 누름 -> 삭제
        await _supabase
            .from('likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
        
        // 게시글 좋아요 수 감소 (트리거가 없다면 수동 업데이트 필요)
        await _supabase.rpc('decrement_likes', params: {'post_id': postId});
        
        return false; // 좋아요 취소됨
      } else {
        // 좋아요 안 누름 -> 추가
        await _supabase.from('likes').insert({
          'post_id': postId,
          'user_id': userId,
        });

        // 게시글 좋아요 수 증가
        await _supabase.rpc('increment_likes', params: {'post_id': postId});

        return true; // 좋아요 됨
      }
    } catch (e) {
      return false; 
    }
  }
    
  /// 게시글 작성
  Future<void> createPost(PostModel post) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다.');

      // insert post ONLY (Match JS: No author_nickname)
      await _supabase.from('posts').insert({
        'title': post.title,
        'content': post.content,
        'type': PostModel.typeToString(post.type),
        'image_url': post.imageUrl,
        'user_id': userId,
      });
    } catch (e) {
      throw Exception('게시글 작성에 실패했습니다: $e');
    }
  }

  /// 댓글 목록 조회
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);
          
      // Need to fetch author nicknames for comments too?
      // JS Logic does fetch them. Let's do the same safe manual fetch.
      final List<dynamic> commentsData = response as List<dynamic>;
      if (commentsData.isEmpty) return [];

      final userIds = commentsData.map((c) => c['user_id'] as String).toSet().toList();
      final profilesResponse = await _supabase
          .from('profiles')
          .select('id, nickname')
          .inFilter('id', userIds);

      final Map<String, String> profileMap = {};
      for (var p in (profilesResponse as List<dynamic>)) {
        profileMap[p['id']] = p['nickname'] ?? '익명';
      }

      return commentsData.map((json) {
        final userId = json['user_id'];
        final nickname = profileMap[userId] ?? '익명';
        final newJson = Map<String, dynamic>.from(json);
        newJson['author_nickname'] = nickname;
        return CommentModel.fromJson(newJson);
      }).toList();

    } catch (e) {
      print('댓글 로드 실패: $e');
      return [];
    }
  }

  /// 댓글 작성
  Future<void> createComment(String postId, String content) async {
     try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다.');
      
      // JS Logic creates comment with just post_id, user_id, content. 
      // It DOES NOT insert author_nickname.
      
      await _supabase.from('comments').insert({
        'post_id': postId,
        'user_id': userId,
        'content': content,
      });

      // 게시글 댓글 수 업데이트 (RPC)
      await _supabase.rpc('increment_comments', params: {'post_id': postId});

    } catch (e) {
      throw Exception('댓글 작성에 실패했습니다: $e');
    }
  }
}
