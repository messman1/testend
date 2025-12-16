import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../location/providers/location_provider.dart';
import '../../../places/providers/places_provider.dart';
import '../../../places/domain/models/place_model.dart';
import '../widgets/web_image_stub.dart'
    if (dart.library.html) '../widgets/web_image_web.dart';

/// 탐색 페이지
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all'; // 'all' or PlaceCategory code
  String _searchTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationState = ref.watch(currentLocationProvider);

    return Column(
      children: [
        // 검색 섹션
        _buildSearchSection(ref, theme, locationState),

        // 카테고리 탭
        _buildCategoryTabs(theme),

        // 장소 목록
        Expanded(
          child: _buildPlacesList(ref, theme, locationState),
        ),
      ],
    );
  }

  /// 검색 섹션
  Widget _buildSearchSection(
    WidgetRef ref,
    ThemeData theme,
    LocationState locationState,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // 검색바
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '장소, 음식, 활동 검색...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchTerm.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchTerm = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchTerm = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // 위치 태그
          InkWell(
            onTap: () {
              ref.read(locationControllerProvider.notifier).refreshLocation();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '📍 ${locationState.address ?? "현재 위치"}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (locationState.isLoading) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 탭
  Widget _buildCategoryTabs(ThemeData theme) {
    final categories = [
      {'id': 'all', 'icon': '🌟', 'name': '전체'},
      {'id': PlaceCategory.karaoke.code, 'icon': PlaceCategory.karaoke.icon, 'name': PlaceCategory.karaoke.label},
      {'id': PlaceCategory.escape.code, 'icon': PlaceCategory.escape.icon, 'name': PlaceCategory.escape.label},
      {'id': PlaceCategory.board.code, 'icon': PlaceCategory.board.icon, 'name': PlaceCategory.board.label},
      {'id': PlaceCategory.movie.code, 'icon': PlaceCategory.movie.icon, 'name': PlaceCategory.movie.label},
      {'id': PlaceCategory.cafe.code, 'icon': PlaceCategory.cafe.icon, 'name': PlaceCategory.cafe.label},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category['icon'] as String,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  Text(category['name'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category['id'] as String;
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

  /// 장소 목록
  Widget _buildPlacesList(
    WidgetRef ref,
    ThemeData theme,
    LocationState locationState,
  ) {
    if (!locationState.hasLocation) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '위치 정보를 가져오는 중...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    // 카테고리별 또는 전체 장소 가져오기
    final placesAsync = _selectedCategory == 'all'
        ? ref.watch(popularPlacesProvider(LocationParams(
            latitude: locationState.latitude!,
            longitude: locationState.longitude!,
            sizePerCategory: 5,
          )))
        : ref.watch(categoryPlacesProvider(CategoryParams(
            category: PlaceCategory.fromCode(_selectedCategory)!,
            latitude: locationState.latitude!,
            longitude: locationState.longitude!,
            size: 15,
          )));

    return placesAsync.when(
      data: (places) {
        // 검색어 필터링
        final filteredPlaces = _searchTerm.isEmpty
            ? places
            : places.where((place) {
                final searchLower = _searchTerm.toLowerCase();
                return place.name.toLowerCase().contains(searchLower) ||
                    place.location.toLowerCase().contains(searchLower);
              }).toList();

        if (filteredPlaces.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🔍', style: theme.textTheme.displayLarge),
                const SizedBox(height: 16),
                Text(
                  '검색 결과가 없습니다',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredPlaces.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildPlaceCard(theme, filteredPlaces[index]);
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
              '장소 정보를 불러오는데 실패했습니다',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 장소 카드
  Widget _buildPlaceCard(ThemeData theme, PlaceModel place) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push(
            '${RouteNames.placeDetail}?url=${Uri.encodeComponent(place.url)}&name=${Uri.encodeComponent(place.name)}',
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            SizedBox(
              width: double.infinity,
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 썸네일 이미지 또는 카테고리 아이콘
                  if (place.thumbnail != null && place.thumbnail!.isNotEmpty)
                    WebImage(
                      imageUrl: place.thumbnail!,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                              theme.colorScheme.secondary.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                              theme.colorScheme.secondary.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            place.category.icon,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                            theme.colorScheme.secondary.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          place.category.icon,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),

                  // 카테고리 라벨
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        place.category.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 정보 영역
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 장소명
                  Text(
                    place.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 위치
                  Row(
                    children: [
                      const Text('📍', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 주소
                  Text(
                    place.address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 거리 및 전화번호
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '🚶 ${place.distance}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (place.phone.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Text('📞', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.phone,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
