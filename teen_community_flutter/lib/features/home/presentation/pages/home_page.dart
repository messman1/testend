import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../location/providers/location_provider.dart';

/// 홈 페이지
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locationState = ref.watch(currentLocationProvider);

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

          // 인기 장소
          _buildPopularPlaces(ref, theme, locationState),
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

  /// 인기 장소
  Widget _buildPopularPlaces(
    WidgetRef ref,
    ThemeData theme,
    LocationState locationState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '📍 ${locationState.address ?? "내 주변"} 인기 장소',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: locationState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('🔄', style: TextStyle(fontSize: 20)),
                onPressed: locationState.isLoading
                    ? null
                    : () {
                        ref
                            .read(locationControllerProvider.notifier)
                            .refreshLocation();
                      },
                tooltip: '위치 새로고침',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 위치 오류 표시
        if (locationState.error != null)
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '위치 정보를 가져올 수 없습니다.\n기본 위치(서울)로 표시됩니다.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        // 위치 정보 카드
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('📍', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '현재 위치',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            locationState.address ?? '위치 정보 없음',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (locationState.hasLocation) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLocationInfo(
                          theme,
                          '위도',
                          locationState.latitude?.toStringAsFixed(4) ?? '-',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLocationInfo(
                          theme,
                          '경도',
                          locationState.longitude?.toStringAsFixed(4) ?? '-',
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        '🏪',
                        style: theme.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '인기 장소 목록은 카카오 API 연동 후 표시됩니다',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 위치 정보 표시 위젯
  Widget _buildLocationInfo(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
