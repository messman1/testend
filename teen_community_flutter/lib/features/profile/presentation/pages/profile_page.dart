import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../auth/providers/auth_provider.dart';

/// 프로필 페이지
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return authState.when(
      data: (state) {
        // 로그인 안 된 상태
        if (state.session == null) {
          return _buildLoginRequired(context, theme);
        }

        // 로그인된 상태 - 프로필 데이터 로드
        return currentUserAsync.when(
          data: (user) {
            if (user == null) {
              return _buildLoginRequired(context, theme);
            }
            return _buildProfile(context, ref, theme, user);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('프로필 로드 실패: $error'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('오류 발생: $error')),
    );
  }

  /// 로그인 필요 화면
  Widget _buildLoginRequired(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👤', style: TextStyle(fontSize: 50)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '로그인이 필요합니다',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '커뮤니티에 참여하려면 로그인하세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.push(RouteNames.login),
                child: const Text('로그인'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => context.push(RouteNames.signup),
                child: const Text('회원가입'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 프로필 화면
  Widget _buildProfile(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    dynamic user,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 프로필 헤더
          _buildProfileHeader(theme, user),
          const SizedBox(height: 24),

          // 포인트 카드
          _buildPointsCard(theme, user),
          const SizedBox(height: 24),

          // 뱃지 섹션
          if (user.badges.isNotEmpty) ...[
            _buildBadgesSection(theme, user),
            const SizedBox(height: 24),
          ],

          // 활동 통계
          _buildStatsSection(theme),
          const SizedBox(height: 24),

          // 메뉴 섹션
          _buildMenuSection(context, ref, theme),
        ],
      ),
    );
  }

  /// 프로필 헤더
  Widget _buildProfileHeader(ThemeData theme, dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👤', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.nickname,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@${user.nickname}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Lv. ${user.level}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 포인트 카드
  Widget _buildPointsCard(ThemeData theme, dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('⭐', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '포인트',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.points}P',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 뱃지 섹션
  Widget _buildBadgesSection(ThemeData theme, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '내 뱃지',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user.badges.map<Widget>((badge) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                badge,
                style: theme.textTheme.bodyLarge,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 활동 통계
  Widget _buildStatsSection(ThemeData theme) {
    final stats = [
      {'label': '찜한 장소', 'value': 0, 'icon': '🔖'},
      {'label': '참여한 모임', 'value': 0, 'icon': '👥'},
      {'label': '작성한 글', 'value': 0, 'icon': '✏️'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '활동 통계',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: stats.map((stat) {
            return Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        stat['icon'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stat['value']}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat['label'] as String,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 메뉴 섹션
  Widget _buildMenuSection(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Card(
      child: Column(
        children: [
          _buildMenuItem(
            context: context,
            icon: '📋',
            label: '찜한 장소',
            onTap: () => context.push(RouteNames.bookmarked),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context: context,
            icon: '👥',
            label: '친구 관리',
            onTap: () => context.push(RouteNames.friends),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context: context,
            icon: '⚙️',
            label: '설정',
            onTap: () => context.push(RouteNames.settings),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context: context,
            icon: '🚪',
            label: '로그아웃',
            isDestructive: true,
            onTap: () async {
              final authController = ref.read(authControllerProvider.notifier);
              await authController.signOut();
              if (context.mounted) {
                context.go(RouteNames.home);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃 되었습니다')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// 메뉴 아이템
  Widget _buildMenuItem({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDestructive ? Colors.red : null,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
