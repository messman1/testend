import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/post_model.dart';
import '../../providers/posts_provider.dart';
import '../../data/posts_repository.dart';
import '../../../auth/providers/auth_provider.dart';

/// 게시글 상세 페이지
class PostDetailPage extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailPage({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    try {
      await ref.read(postsControllerProvider.notifier).toggleLike(widget.postId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 처리에 실패했습니다: $e')),
      );
    }
  }

  Future<void> _submitComment() async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      return;
    }

    try {
      await ref.read(postsControllerProvider.notifier).createComment(
            postId: widget.postId,
            content: _commentController.text.trim(),
          );

      _commentController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글이 작성되었습니다')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 작성에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postAsync = ref.watch(postProvider(widget.postId));
    final commentsAsync = ref.watch(commentsProvider(widget.postId));
    final likeStatusAsync = ref.watch(likeStatusProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
      ),
      body: postAsync.when(
        data: (post) {
          final postType = PostType.fromCode(post.type);

          return Column(
            children: [
              // 게시글 내용
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(postProvider(widget.postId));
                    ref.invalidate(commentsProvider(widget.postId));
                    ref.invalidate(likeStatusProvider(widget.postId));
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 게시글 헤더
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 타입
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      postType?.icon ?? '💬',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      postType?.label ?? '일반',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 제목
                              Text(
                                post.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 작성자 및 시간
                              Row(
                                children: [
                                  Text(
                                    post.userNickname,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '· ${_getTimeAgo(post.createdAt)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // 내용
                              Text(
                                post.content,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // 좋아요 버튼
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              likeStatusAsync.when(
                                data: (isLiked) => InkWell(
                                  onTap: _toggleLike,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLiked
                                          ? theme.colorScheme.primary
                                              .withValues(alpha: 0.1)
                                          : theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isLiked
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outline
                                                .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          isLiked ? '❤️' : '🤍',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          post.likesCount.toString(),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isLiked
                                                ? theme.colorScheme.primary
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                loading: () => const SizedBox(
                                  width: 80,
                                  height: 36,
                                  child: Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                ),
                                error: (_, __) => const SizedBox(),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '댓글 ${post.commentsCount}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // 댓글 목록
                        commentsAsync.when(
                          data: (comments) => ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: comments.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildCommentItem(theme, comments[index]);
                            },
                          ),
                          loading: () => const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stack) => Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                '댓글을 불러올 수 없습니다',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 댓글 입력
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: '댓글을 입력하세요',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _submitComment,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('⚠️', style: theme.textTheme.displayLarge),
              const SizedBox(height: 16),
              Text(
                '게시글을 불러올 수 없습니다',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(postProvider(widget.postId));
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 댓글 아이템
  Widget _buildCommentItem(ThemeData theme, CommentModel comment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.userNickname,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getTimeAgo(comment.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// 시간 경과 표시
  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inDays > 0) {
      return '${diff.inDays}일 전';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 전';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
