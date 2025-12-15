import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/post_model.dart';

/// 게시글 Repository
class PostsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 게시글 목록 조회 (타입별 필터링)
  Future<List<PostModel>> getPosts({String? type}) async {
    try {
      var query = _supabase
          .from('posts')
          .select('''
            *,
            profiles:user_id (nickname)
          ''');

      if (type != null && type != 'all') {
        query = query.eq('type', type);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((post) {
        return PostModel.fromJson({
          ...post,
          'user_nickname': post['profiles']?['nickname'] ?? '익명',
        });
      }).toList();
    } catch (e) {
      throw Exception('게시글을 불러올 수 없습니다: $e');
    }
  }

  /// 게시글 상세 조회
  Future<PostModel> getPost(String postId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles:user_id (nickname)
          ''')
          .eq('id', postId)
          .single();

      return PostModel.fromJson({
        ...response,
        'user_nickname': response['profiles']?['nickname'] ?? '익명',
      });
    } catch (e) {
      throw Exception('게시글을 불러올 수 없습니다: $e');
    }
  }

  /// 게시글 작성
  Future<PostModel> createPost({
    required String title,
    required String content,
    required String type,
    String? imageUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      final response = await _supabase
          .from('posts')
          .insert({
            'user_id': userId,
            'title': title,
            'content': content,
            'type': type,
            'image_url': imageUrl,
          })
          .select('''
            *,
            profiles:user_id (nickname)
          ''')
          .single();

      return PostModel.fromJson({
        ...response,
        'user_nickname': response['profiles']?['nickname'] ?? '익명',
      });
    } catch (e) {
      throw Exception('게시글 작성에 실패했습니다: $e');
    }
  }

  /// 게시글 삭제
  Future<void> deletePost(String postId) async {
    try {
      await _supabase.from('posts').delete().eq('id', postId);
    } catch (e) {
      throw Exception('게시글 삭제에 실패했습니다: $e');
    }
  }

  /// 댓글 목록 조회
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('''
            *,
            profiles:user_id (nickname)
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: false);

      return (response as List).map((comment) {
        return CommentModel.fromJson({
          ...comment,
          'user_nickname': comment['profiles']?['nickname'] ?? '익명',
        });
      }).toList();
    } catch (e) {
      throw Exception('댓글을 불러올 수 없습니다: $e');
    }
  }

  /// 댓글 작성
  Future<CommentModel> createComment({
    required String postId,
    required String content,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      final response = await _supabase
          .from('comments')
          .insert({
            'post_id': postId,
            'user_id': userId,
            'content': content,
          })
          .select('''
            *,
            profiles:user_id (nickname)
          ''')
          .single();

      // 게시글의 댓글 수 증가
      await _supabase.rpc('increment_comments_count', params: {
        'post_id': postId,
      });

      return CommentModel.fromJson({
        ...response,
        'user_nickname': response['profiles']?['nickname'] ?? '익명',
      });
    } catch (e) {
      throw Exception('댓글 작성에 실패했습니다: $e');
    }
  }

  /// 댓글 삭제
  Future<void> deleteComment(String commentId, String postId) async {
    try {
      await _supabase.from('comments').delete().eq('id', commentId);

      // 게시글의 댓글 수 감소
      await _supabase.rpc('decrement_comments_count', params: {
        'post_id': postId,
      });
    } catch (e) {
      throw Exception('댓글 삭제에 실패했습니다: $e');
    }
  }

  /// 좋아요 토글
  Future<bool> toggleLike(String postId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      // 이미 좋아요 했는지 확인
      final existing = await _supabase
          .from('likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // 좋아요 취소
        await _supabase
            .from('likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);

        // 게시글의 좋아요 수 감소
        await _supabase.rpc('decrement_likes_count', params: {
          'post_id': postId,
        });

        return false;
      } else {
        // 좋아요 추가
        await _supabase.from('likes').insert({
          'post_id': postId,
          'user_id': userId,
        });

        // 게시글의 좋아요 수 증가
        await _supabase.rpc('increment_likes_count', params: {
          'post_id': postId,
        });

        return true;
      }
    } catch (e) {
      throw Exception('좋아요 처리에 실패했습니다: $e');
    }
  }

  /// 사용자가 좋아요 했는지 확인
  Future<bool> isLiked(String postId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}

/// 댓글 모델
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userNickname;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userNickname,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      userNickname: json['user_nickname'] as String? ?? '익명',
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
