import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/friends_repository.dart';
import '../../providers/friends_provider.dart';

/// 친구 목록 페이지
class FriendsPage extends ConsumerStatefulWidget {
  const FriendsPage({super.key});

  @override
  ConsumerState<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends ConsumerState<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final friendsAsync = ref.watch(friendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('친구'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              _showAddFriendDialog();
            },
            tooltip: '친구 추가',
          ),
        ],
      ),
      body: friendsAsync.when(
        data: (friends) {
          if (friends.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('👥', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 16),
                  Text(
                    '아직 친구가 없습니다',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '친구를 추가하고 함께 놀아요!',
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
            itemCount: friends.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return _buildFriendItem(theme, friends[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('⚠️', style: theme.textTheme.displayLarge),
              const SizedBox(height: 16),
              Text(
                '친구 목록을 불러오는데 실패했습니다',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 친구 아이템
  Widget _buildFriendItem(ThemeData theme, FriendModel friend) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        child: Text(
          friend.nickname[0],
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        friend.nickname,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text('Lv.${friend.level}'),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 8),
                Text('프로필 보기'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.person_remove, color: Colors.red),
                SizedBox(width: 8),
                Text('친구 삭제', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 'remove') {
            _removeFriend(friend);
          }
        },
      ),
    );
  }

  /// 친구 추가 다이얼로그
  void _showAddFriendDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('친구 추가'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '닉네임',
            hintText: '친구의 닉네임을 입력하세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              final nickname = controller.text.trim();
              if (nickname.isEmpty) return;

              // 사용자 검색
              final friendsController = ref.read(friendsControllerProvider.notifier);
              final users = await friendsController.searchUsers(nickname);

              if (!mounted) return;
              Navigator.of(dialogContext).pop();

              if (users.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('사용자를 찾을 수 없습니다')),
                );
                return;
              }

              final user = users.first;
              await friendsController.sendFriendRequest(user.id);

              final state = ref.read(friendsControllerProvider);
              if (!mounted) return;

              state.when(
                data: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('친구 요청을 보냈습니다')),
                  );
                },
                loading: () {},
                error: (error, _) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('오류: ${error.toString()}')),
                  );
                },
              );
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  /// 친구 삭제
  void _removeFriend(FriendModel friend) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('친구 삭제'),
        content: Text('${friend.nickname}님을 친구 목록에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              final controller = ref.read(friendsControllerProvider.notifier);
              await controller.removeFriend(friend.id);

              final state = ref.read(friendsControllerProvider);
              if (!mounted) return;

              Navigator.of(dialogContext).pop();

              state.when(
                data: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('친구가 삭제되었습니다')),
                  );
                },
                loading: () {},
                error: (error, _) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('오류: ${error.toString()}')),
                  );
                },
              );
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
