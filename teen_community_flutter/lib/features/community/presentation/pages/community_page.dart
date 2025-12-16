import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../domain/models/post_model.dart';
import '../../providers/community_provider.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = [
    {'label': '전체', 'type': null},
    {'label': '🆕 신규 오픈', 'type': PostType.newOpen},
    {'label': '💬 후기', 'type': PostType.review},
    {'label': '🎉 이벤트', 'type': PostType.event},
    {'label': '📝 자유', 'type': PostType.normal},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // 배경색을 흰색으로 하고, 아이콘/텍스트 색상을 진하게 설정
        backgroundColor: Colors.white,
        foregroundColor: theme.colorScheme.onSurface, 
        elevation: 0,
        title: TabBar(
          controller: _tabController,
          isScrollable: true,
          // 선택된 탭 스타일
          labelColor: theme.colorScheme.primary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          // 선택되지 않은 탭 스타일
          unselectedLabelColor: Colors.grey[600], // 더 진한 회색 사용
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          
          // 탭 정렬 및 패딩
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          dividerColor: Colors.transparent, // 탭바 하단 선 제거
          
          tabs: _tabs.map((tab) => Tab(text: tab['label'] as String)).toList(),
        ),
        centerTitle: false,
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          return _PostList(filterType: tab['type'] as PostType?);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(RouteNames.communityWrite);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _PostList extends ConsumerWidget {
  final PostType? filterType;

  const _PostList({this.filterType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider(filterType));

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📝', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  '아직 게시글이 없습니다.\n첫 번째 글을 작성해보세요!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _PostCard(post: posts[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('게시글을 불러오는데 실패했습니다.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(communityPostsProvider(filterType)),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
            context.pushNamed(
              RouteNames.postDetail,
              pathParameters: {'postId': post.id},
            );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더: 작성자 정보 및 타입 배지
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: const Text('👤', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorNickname,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(post.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTypeBadge(context, post.type),
                ],
              ),
              const SizedBox(height: 12),

              // 내용: 제목 및 본문
              Text(
                post.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post.content,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(); // 이미지 로드 실패 시 숨김
                    },
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // 액션 버튼 (좋아요, 댓글)
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.favorite_border,
                    label: '${post.likesCount}',
                    onTap: () {
                         // 좋아요 (Repository 연동 필요, 현재는 UI만)
                    },
                  ),
                  const SizedBox(width: 16),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${post.commentsCount}',
                    onTap: () {},
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context, PostType type) {
    if (type == PostType.normal) return const SizedBox();

    final theme = Theme.of(context);
    String label;
    Color color;

    switch (type) {
      case PostType.newOpen:
        label = '🆕 신규';
        color = Colors.blue;
        break;
      case PostType.review:
        label = '💬 후기';
        color = Colors.green;
        break;
      case PostType.event:
        label = '🎉 이벤트';
        color = Colors.orange;
        break;
      default:
        return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${date.month}월 ${date.day}일';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
