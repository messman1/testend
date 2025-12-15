import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';

/// 홈 페이지
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 환영 섹션
          _buildWelcomeSection(theme),
          const SizedBox(height: 24),

          // 빠른 액션
          _buildQuickActions(context, theme),
          const SizedBox(height: 32),

          // 인기 카테고리
          _buildCategoriesSection(context, theme),
          const SizedBox(height: 32),

          // 인기 장소 (추후 구현)
          _buildPopularPlaces(theme),
        ],
      ),
    );
  }

  /// 환영 섹션
  Widget _buildWelcomeSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '환영합니다!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '친구들과 함께 즐거운 시간을 보낼 장소를 찾아보세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 빠른 액션
  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // 오늘 뭐하지? (메인 액션)
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => context.push(RouteNames.recommend),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🎯', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Text('오늘 뭐하지?', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 주변 장소 찾기 & 모임 만들기
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () => context.push(RouteNames.explore),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('📍', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 2),
                      Text('주변 장소 찾기', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () => context.push(RouteNames.meetingCreate),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('👥', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 2),
                      Text('모임 만들기', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 인기 카테고리
  Widget _buildCategoriesSection(BuildContext context, ThemeData theme) {
    final categories = [
      {'icon': '🎤', 'label': '코인노래방', 'category': 'karaoke'},
      {'icon': '🎯', 'label': '방탈출', 'category': 'escape'},
      {'icon': '🎲', 'label': '보드게임', 'category': 'board'},
      {'icon': '🎬', 'label': '영화관', 'category': 'movie'},
      {'icon': '📚', 'label': '북카페', 'category': 'cafe'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '인기 카테고리',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              child: Card(
                child: InkWell(
                  onTap: () => context.push(
                    '${RouteNames.explore}?category=${cat['category']}',
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          cat['icon'] as String,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['label'] as String,
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 인기 장소 (추후 구현)
  Widget _buildPopularPlaces(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                '📍 내 주변 인기 장소',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Text('🔄', style: TextStyle(fontSize: 20)),
                onPressed: () {
                  // 위치 새로고침 (추후 구현)
                },
                tooltip: '위치 새로고침',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Text(
                    '🏪',
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '위치 서비스 구현 예정',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
