import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/post_model.dart';
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
  final List<CommentModel> _comments = [];
  bool _isLiked = false;
  int _likesCount = 0;

  // 샘플 게시글 (실제로는 Supabase에서 가져와야 함)
  late PostModel _post;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  void _loadPost() {
    // TODO: Supabase에서 게시글 및 댓글 로드
    setState(() {
      _post = PostModel(
        id: widget.postId,
        userId: 'sample1',
        userNickname: '청소년1',
        title: '오늘 강남에서 보드게임 할 사람!',
        content: '시험 끝나고 친구들이랑 보드게임 하려고 하는데 같이 하실 분 구해요~\n'
            '시간은 오후 3시쯤 생각하고 있어요.\n'
            '장소는 강남역 근처 보드게임 카페로 갈 예정입니다!',
        type: 'meetup',
        imageUrl: null,
        likesCount: 12,
        commentsCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      _likesCount = _post.likesCount;

      // 샘플 댓글
      _comments.addAll([
        CommentModel(
          id: '1',
          postId: widget.postId,
          userId: 'user1',
          userNickname: '댓글러1',
          content: '저도 참여하고 싶어요!',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        CommentModel(
          id: '2',
          postId: widget.postId,
          userId: 'user2',
          userNickname: '댓글러2',
          content: '몇 명 정도 모집하시나요?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ]);
    });
  }

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

    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    // TODO: Supabase에 좋아요 토글
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

    // TODO: Supabase에 댓글 저장
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.postId,
      userId: user.id,
      userNickname: user.nickname,
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('댓글이 작성되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postType = PostType.fromCode(_post.type);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
      ),
      body: Column(
        children: [
          // 게시글 내용
          Expanded(
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
                                style: theme.textTheme.bodyMedium?.copyWith(
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
                          _post.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 작성자 및 시간
                        Row(
                          children: [
                            Text(
                              _post.userNickname,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '· ${_getTimeAgo(_post.createdAt)}',
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
                          _post.content,
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
                        InkWell(
                          onTap: _toggleLike,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _isLiked
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.1)
                                  : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isLiked
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isLiked ? '❤️' : '🤍',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _likesCount.toString(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _isLiked
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '댓글 ${_comments.length}',
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
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _comments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildCommentItem(theme, _comments[index]);
                    },
                  ),
                ],
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
}
