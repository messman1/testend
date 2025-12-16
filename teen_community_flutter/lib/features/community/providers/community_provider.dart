import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/community_repository.dart';
import '../domain/models/post_model.dart';
import '../domain/models/comment_model.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository();
});

final communityPostsProvider = FutureProvider.family<List<PostModel>, PostType?>((ref, type) async {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getPosts(type: type);
});

final postDetailProvider = FutureProvider.family<PostModel, String>((ref, postId) async {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getPostById(postId);
});

final commentsProvider = FutureProvider.family<List<CommentModel>, String>((ref, postId) async {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getComments(postId);
});

class CommunityController extends StateNotifier<AsyncValue<void>> {
  final CommunityRepository _repository;
  final Ref _ref;

  CommunityController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> createPost(PostModel post) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createPost(post);
      _ref.invalidate(communityPostsProvider);
    });
  }
  
  Future<void> createComment(String postId, String content) async {
    // Note: We don't set global loading state for comment to avoid blocking entire UI,
    // or we can handle it locally in the UI. 
    // Here we just await and invalidate.
    await _repository.createComment(postId, content);
    _ref.invalidate(commentsProvider(postId));
    _ref.invalidate(postDetailProvider(postId)); // Update comment count
  }
  
  Future<void> toggleLike(String postId) async {
     await _repository.toggleLike(postId);
     _ref.invalidate(postDetailProvider(postId));
     _ref.invalidate(communityPostsProvider);
  }
}

final communityControllerProvider = StateNotifierProvider<CommunityController, AsyncValue<void>>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return CommunityController(repository, ref);
});
