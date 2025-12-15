import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/posts_repository.dart';
import '../domain/models/post_model.dart';

/// PostsRepository Provider
final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepository();
});

/// 게시글 목록 Provider (타입별 필터링)
final postsProvider = FutureProvider.family<List<PostModel>, String?>((ref, type) async {
  final repository = ref.watch(postsRepositoryProvider);
  return await repository.getPosts(type: type);
});

/// 특정 게시글 Provider
final postProvider = FutureProvider.family<PostModel, String>((ref, postId) async {
  final repository = ref.watch(postsRepositoryProvider);
  return await repository.getPost(postId);
});

/// 댓글 목록 Provider
final commentsProvider = FutureProvider.family<List<CommentModel>, String>((ref, postId) async {
  final repository = ref.watch(postsRepositoryProvider);
  return await repository.getComments(postId);
});

/// 좋아요 상태 Provider
final likeStatusProvider = FutureProvider.family<bool, String>((ref, postId) async {
  final repository = ref.watch(postsRepositoryProvider);
  return await repository.isLiked(postId);
});

/// 게시글 작성 Controller
class PostsController extends StateNotifier<AsyncValue<void>> {
  final PostsRepository _repository;
  final Ref _ref;

  PostsController(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// 게시글 작성
  Future<void> createPost({
    required String title,
    required String content,
    required String type,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createPost(
        title: title,
        content: content,
        type: type,
        imageUrl: imageUrl,
      );
      // 게시글 목록 새로고침
      _ref.invalidate(postsProvider);
    });
  }

  /// 게시글 삭제
  Future<void> deletePost(String postId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deletePost(postId);
      // 게시글 목록 새로고침
      _ref.invalidate(postsProvider);
    });
  }

  /// 댓글 작성
  Future<void> createComment({
    required String postId,
    required String content,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createComment(
        postId: postId,
        content: content,
      );
      // 댓글 목록 새로고침
      _ref.invalidate(commentsProvider(postId));
      _ref.invalidate(postProvider(postId));
    });
  }

  /// 댓글 삭제
  Future<void> deleteComment(String commentId, String postId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteComment(commentId, postId);
      // 댓글 목록 새로고침
      _ref.invalidate(commentsProvider(postId));
      _ref.invalidate(postProvider(postId));
    });
  }

  /// 좋아요 토글
  Future<bool> toggleLike(String postId) async {
    try {
      final isLiked = await _repository.toggleLike(postId);
      // 좋아요 상태 및 게시글 정보 새로고침
      _ref.invalidate(likeStatusProvider(postId));
      _ref.invalidate(postProvider(postId));
      return isLiked;
    } catch (e) {
      throw Exception('좋아요 처리에 실패했습니다: $e');
    }
  }
}

/// PostsController Provider
final postsControllerProvider = StateNotifierProvider<PostsController, AsyncValue<void>>((ref) {
  final repository = ref.watch(postsRepositoryProvider);
  return PostsController(repository, ref);
});
