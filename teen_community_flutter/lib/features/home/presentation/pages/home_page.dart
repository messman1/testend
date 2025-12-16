import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../location/providers/location_provider.dart';
import '../../../places/providers/places_provider.dart';
import '../../../places/domain/models/place_model.dart';

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
          // 오늘 뭐하지? (히어로 섹션)
          _buildHeroSection(context, theme),
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

  /// 히어로 섹션 (오늘 뭐하지?)
  Widget _buildHeroSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 120, // 더 크게
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(RouteNames.recommend),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '오늘 뭐하지?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI와 함께 만드는 완벽한 하루',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '🎯',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '인기 카테고리',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.push(RouteNames.explore),
                child: const Text('더보기'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12, // Increased spacing
          runSpacing: 12,
          children: categories.map((cat) {
            // 3 items per row approx
            final itemWidth = (MediaQuery.of(context).size.width - 32 - 24) / 3; 
            
            return SizedBox(
              width: itemWidth,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => context.push(
                      '${RouteNames.explore}?category=${cat['category']}',
                    ),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      height: itemWidth,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          cat['icon'] as String,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                     cat['label'] as String,
                     style: theme.textTheme.bodyMedium?.copyWith(
                       fontWeight: FontWeight.w500,
                     ),
                     textAlign: TextAlign.center,
                  ),
                ],
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
              // 세련된 새로고침 버튼
              InkWell(
                onTap: locationState.isLoading
                    ? null
                    : () {
                        ref
                            .read(locationControllerProvider.notifier)
                            .refreshLocation();
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: locationState.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                ),
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

        // 위치 정보 카드 제거됨 - 인기 장소 목록만 표시
        if (locationState.hasLocation)
          _buildPlacesList(ref, theme, locationState)
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '🏪',
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '위치 정보를 가져오는 중...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
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

  /// 인기 장소 목록
  Widget _buildPlacesList(
    WidgetRef ref,
    ThemeData theme,
    LocationState locationState,
  ) {
    final placesAsync = ref.watch(
      popularPlacesProvider(
        LocationParams(
          latitude: locationState.latitude!,
          longitude: locationState.longitude!,
          sizePerCategory: 3, // 카테고리당 3개씩
        ),
      ),
    );

    return placesAsync.when(
      data: (places) {
        if (places.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '주변에 장소가 없습니다',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        }

        // 상위 5개만 표시
        final topPlaces = places.take(5).toList();

        return Column(
          children: topPlaces.asMap().entries.map((entry) {
            final index = entry.key;
            final place = entry.value;
            return _buildPlaceItem(theme, index + 1, place);
          }).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            '장소를 불러올 수 없습니다',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  /// 장소 아이템
  Widget _buildPlaceItem(ThemeData theme, int rank, PlaceModel place) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          // 장소 상세 페이지로 이동
          context.push(
            '${RouteNames.placeDetail}?url=${Uri.encodeComponent(place.url)}&name=${Uri.encodeComponent(place.name)}',
            extra: place,
          );
        },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // 순위
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: rank <= 3
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  place.category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        place.location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        ' | ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      Text(
                        '⭐ ${place.rating}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' (${place.reviewCount})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      Text(
                        ' | ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      Text(
                        '🚶 ${place.distance}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 화살표
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    ));
  }
}
