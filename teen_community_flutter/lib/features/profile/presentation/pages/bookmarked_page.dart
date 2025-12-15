import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../places/domain/models/place_model.dart';
import '../../../../config/routes/route_names.dart';

/// 북마크한 장소 페이지
class BookmarkedPage extends ConsumerStatefulWidget {
  const BookmarkedPage({super.key});

  @override
  ConsumerState<BookmarkedPage> createState() => _BookmarkedPageState();
}

class _BookmarkedPageState extends ConsumerState<BookmarkedPage> {
  final List<PlaceModel> _bookmarkedPlaces = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    // TODO: Supabase에서 북마크 목록 로드
    // 현재는 빈 상태
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('북마크'),
      ),
      body: _bookmarkedPlaces.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📌', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 16),
                  Text(
                    '북마크한 장소가 없습니다',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '마음에 드는 장소를 북마크해보세요!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _bookmarkedPlaces.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final place = _bookmarkedPlaces[index];
                return _buildPlaceCard(theme, place);
              },
            ),
    );
  }

  /// 장소 카드
  Widget _buildPlaceCard(ThemeData theme, PlaceModel place) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(
            '${RouteNames.placeDetail}?url=${Uri.encodeComponent(place.url)}&name=${Uri.encodeComponent(place.name)}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    place.category.icon,
                    style: const TextStyle(fontSize: 40),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          place.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
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
                  ],
                ),
              ),

              // 북마크 제거 버튼
              IconButton(
                icon: const Icon(Icons.bookmark),
                color: theme.colorScheme.primary,
                onPressed: () {
                  setState(() {
                    _bookmarkedPlaces.remove(place);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('북마크가 해제되었습니다')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
