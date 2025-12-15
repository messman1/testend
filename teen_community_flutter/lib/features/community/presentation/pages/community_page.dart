import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/post_model.dart';
import '../../../../config/routes/route_names.dart';

/// 커뮤니티 페이지 (소식)
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  final List<PostModel> _posts = [];
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _loadSamplePosts();
  }

  void _loadSamplePosts() {
    // 샘플 게시글 (실제로는 Supabase에서 가져와야 함)
    setState(() {
      _posts.addAll([
        PostModel(
          id: const Uuid().v4(),
          userId: 'sample1',
          userNickname: '청소년1',
          title: '오늘 강남에서 보드게임 할 사람!',
          content: '시험 끝나고 친구들이랑 보드게임 하려고 하는데 같이 하실 분 구해요~',
          type: 'meetup',
          imageUrl: null,
          likesCount: 12,
          commentsCount: 5,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        PostModel(
          id: const Uuid().v4(),
          userId: 'sample2',
          userNickname: '청소년2',
          title: '코인노래방 추천해주세요!',
          content: '홍대 근처에서 깨끗하고 괜찮은 코인노래방 아시는 분 있나요?',
          type: 'question',
          imageUrl: null,
          likesCount: 8,
          commentsCount: 3,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        PostModel(
          id: const Uuid().v4(),
          userId: 'sample3',
          userNickname: '청소년3',
          title: '강남역 방탈출 다녀왔어요',
          content: '친구 4명이서 다녀왔는데 진짜 재밌었어요! 난이도도 적당하고 스토리도 좋았습니다 ㅎㅎ',
          type: 'review',
          imageUrl: null,
          likesCount: 15,
          commentsCount: 7,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // 상단 바
        _buildTopBar(theme),

        // 타입 필터
        _buildTypeFilter(theme),

        // 게시글 목록
        Expanded(
          child: _buildPostList(theme),
        ),
      ],
    );
  }

  /// 상단 바
  Widget _buildTopBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '소식',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              context.push(RouteNames.communityWrite);
            },
            icon: const Icon(Icons.edit),
            label: const Text('글쓰기'),
          ),
        ],
      ),
    );
  }

  /// 타입 필터
  Widget _buildTypeFilter(ThemeData theme) {
    final types = [
      {'id': 'all', 'icon': '🌟', 'name': '전체'},
      ...PostType.values.map((type) => {
            'id': type.code,
            'icon': type.icon,
            'name': type.label,
          }),
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = _selectedType == type['id'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    type['icon'] as String,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  Text(type['name'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = type['id'] as String;
                });
              },
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: theme.colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  /// 게시글 목록
  Widget _buildPostList(ThemeData theme) {
    final filteredPosts = _selectedType == 'all'
        ? _posts
        : _posts.where((p) => p.type == _selectedType).toList();

    if (filteredPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📝', style: theme.textTheme.displayLarge),
            const SizedBox(height: 16),
            Text(
              '아직 게시글이 없습니다',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 번째 글을 작성해보세요!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildPostCard(theme, filteredPosts[index]);
      },
    );
  }

  /// 게시글 카드
  Widget _buildPostCard(ThemeData theme, PostModel post) {
    final postType = PostType.fromCode(post.type);
    final timeAgo = _getTimeAgo(post.createdAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('${RouteNames.postDetail}/${post.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  // 타입 아이콘
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          postType?.icon ?? '💬',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          postType?.label ?? '일반',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // 작성자 및 시간
                  Text(
                    post.userNickname,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '· $timeAgo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 제목
              Text(
                post.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // 내용
              Text(
                post.content,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 통계
              Row(
                children: [
                  Row(
                    children: [
                      const Text('❤️', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        post.likesCount.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Text('💬', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        post.commentsCount.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
